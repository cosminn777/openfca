using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;

namespace libconexplore
{
    public class NaiveConceptProcessor : IConceptProcessor
    {
        public NaiveConceptProcessor()
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

        public Graph Process(string[] sObjects, string[] sAttributes, bool[][] bValues)
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
            HashSet<int> hsSupremum = new HashSet<int>();
            for (i = 0; i < sObjects.Length; ++i)
            {
                hsSupremum.Add(i);
            }
            hshsExtents.Add(hsSupremum);

            // Done
            List<HashSet<int>> lhsFinalExtents = new List<HashSet<int>>(hshsExtents);
            List<HashSet<int>> lhsFinalIntents = new List<HashSet<int>>();

            // Compute intent for every extent
            for (i = 0; i < lhsFinalExtents.Count; ++i)
            {
                lhsFinalIntents.Add(IntentForMultipleObjects(bValues, sAttributes, lhsFinalExtents[i]));
            }

            Debug.WriteLine(string.Format("Total formal concepts: {0}", lhsFinalExtents.Count));

            // Create concepts
            List<Concept> lConcepts = new List<Concept>();
            for (i = 0; i < lhsFinalExtents.Count; ++i)
            {
                lConcepts.Add(new Concept(/*i, */lhsFinalExtents[i], lhsFinalIntents[i], sObjects, sAttributes));
            }

            return new Graph() { Concepts = lConcepts, Links = new FloydWarshallLinker().Link(lConcepts) };
        }
    }
}
