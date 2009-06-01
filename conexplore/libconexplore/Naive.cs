using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;

namespace libconexplore
{
    public class Naive
    {
        public Naive()
        {

        }

        private HashSet<int> ExtentForSingleAttribute(bool[][] bValues, int iAttribute)
        {
            HashSet<int> hsObjects = new HashSet<int>();
            
            int i = 0;
            for (i = 0; i < bValues.Length; ++i)
            {
                if (bValues[i][iAttribute])
                {
                    hsObjects.Add(i);
                }
            }

            return hsObjects;
        }

        private HashSet<int> IntentForMultipleObjects(bool[][] bValues, string[] sAttributes, HashSet<int> hsObjects)
        {
            HashSet<int> hgAttributes = new HashSet<int>();
            
            int i = 0;
            for (i = 0; i < sAttributes.Length; ++i)
            {
                bool bOk = true;
                foreach (int j in hsObjects)
                {
                    if (!bValues[j][i])
                    {
                        bOk = false;
                        break;
                    }
                }
                if (bOk)
                {
                    hgAttributes.Add(i);
                }
            }

            return hgAttributes;
        }

        public void Compute(string[] sObjects, string[] sAttributes, bool[][] bValues)
        {
            HashSet<HashSet<int>> hshsExtents = new HashSet<HashSet<int>>(new NaiveComparer()); // will contain all extents

            int i = 0, j = 0;

            // For each attribute add its extent
            for (j = 0; j < sAttributes.Length; ++j)
            {
                HashSet<int> hsExtent = ExtentForSingleAttribute(bValues, j);
                hshsExtents.Add(hsExtent);
            }

            // While the set of extents changes compute all pairwise intersections
            bool bChanged = true;
            while (bChanged)
            {
                bChanged = false;
                
                List<HashSet<int>> lhsExtents = new List<HashSet<int>>(hshsExtents);
                Debug.WriteLine(string.Format("Formal concepts so far: {0}", lhsExtents.Count));

                for (i = 0; i < lhsExtents.Count - 1; ++i)
                {
                    for (j = i + 1; j < lhsExtents.Count; ++j)
                    {
                        HashSet<int> hsExtentIntersection = new HashSet<int>(lhsExtents[i]);
                        hsExtentIntersection.IntersectWith(lhsExtents[j]);
                        if (hshsExtents.Add(hsExtentIntersection))
                        {
                            bChanged = true;
                        }
                    }
                }
            }

            // Add the set of all objects if it's not already there
            HashSet<int> hsAllObjects = new HashSet<int>();
            for (i = 0; i < sObjects.Length; ++i)
            {
                hsAllObjects.Add(i);
            }
            hshsExtents.Add(hsAllObjects);

            // Done
            List<HashSet<int>> lhsFinalExtents = new List<HashSet<int>>(hshsExtents);
            List<HashSet<int>> lhsFinalIntents = new List<HashSet<int>>();

            // Initialize levels for each formal concept
            List<int> lLevels = new List<int>();
            for (i = 0; i < lhsFinalExtents.Count; ++i)
            {
                lLevels.Add(0);
            }

            // Sort extents by their length
            HashSet<int> hs1;
            HashSet<int> hs2;
            for (i = 0; i < lhsFinalExtents.Count - 1; ++i)
            {
                for (j = i + 1; j < lhsFinalExtents.Count; ++j)
                {
                    hs1 = lhsFinalExtents[i];
                    hs2 = lhsFinalExtents[j];
                    if (hs1.Count < hs2.Count)
                    {
                        lhsFinalExtents[i] = hs2;
                        lhsFinalExtents[j] = hs1;
                    }
                }
            }

            // Compute level for each concept
            for (i = 0; i < lhsFinalExtents.Count; ++i)
            {
                int iMax = 0;
                for (j = i - 1; j >= 0; --j)
                {
                    hs1 = lhsFinalExtents[i];
                    hs2 = lhsFinalExtents[j];
                    if (hs1.IsSubsetOf(hs2)) // set1 is all included in set2
                    {
                        if (iMax < lLevels[j])
                        {
                            iMax = lLevels[j];
                        }
                    }
                }
                lLevels[i] = iMax + 1;
            }

            // Compute intent for every extent
            for (i = 0; i < lhsFinalExtents.Count; ++i)
            {
                lhsFinalIntents.Add(IntentForMultipleObjects(bValues, sAttributes, lhsFinalExtents[i]));
            }

            Debug.WriteLine(string.Format("Total formal concepts: {0}", lhsFinalExtents.Count));

            // Create graph nodes
            List<Concept> lConcepts = new List<Concept>();
            for (i = 0; i < lhsFinalExtents.Count; ++i)
            {
                // Convert extent index to name
                List<string> lConceptObjects = new List<string>();
                foreach (int iObject in lhsFinalExtents[i])
                {
                    lConceptObjects.Add(sObjects[iObject]);
                }

                // Convert intent index to name
                List<string> lConceptAttributes = new List<string>();
                foreach (int iAttribute in lhsFinalIntents[i])
                {
                    lConceptAttributes.Add(sAttributes[iAttribute]);
                }

                lConcepts.Add(new Concept() { Objects = lConceptObjects, Attributes = lConceptAttributes });
            }

            // Connect concepts
            List<Link> lLinks = new List<Link>();
            HashSet<int> hsLinked = new HashSet<int>();
            for (i = 0; i < lhsFinalExtents.Count; ++i)
            {
                for (j = i - 1; j >= 0; --j)
                {
                    hs1 = lhsFinalExtents[i];
                    hs2 = lhsFinalExtents[j];
                    if (hs1.IsSubsetOf(hs2)) // set1 is all included in set2
                    {
                        if (lLevels[i] - lLevels[j] == 1) // Is on the next level
                        {
                            lLinks.Add(new Link() { Source = lConcepts[j], Target = lConcepts[i] });
                            // Keep track of nodes that act as targets
                            hsLinked.Add(j);
                        }
                    }	
                }
            }

            // Connect remaining concepts to the bottom one
            for (i = 0; i < lhsFinalExtents.Count - 1; ++i)
            {
                if (!hsLinked.Overlaps(new int[] { i }))
                {
                    // Connect a node that has never been used as a source to the concept with empty objects and all attributes
                    lLinks.Add(new Link() { Source = lConcepts[i], Target = lConcepts[lConcepts.Count - 1] });
                    hsLinked.Add(i);
                }
            }

            Debug.WriteLine(string.Format("Total links: {0}", lLinks.Count));
        }
    }
}
