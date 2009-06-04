using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;

namespace libconexplore
{
    public class Linker
    {
        public Linker()
        {

        }

        public List<Link> Link(List<Concept> lConcepts)
        {
            int i = 0, j = 0;

            // Initialize levels for each formal concept
            List<int> lLevels = new List<int>();
            for (i = 0; i < lConcepts.Count; ++i)
            {
                lLevels.Add(0);
            }

            // Sort extents decreasingly by their length
            //lConcepts.Sort(delegate(Concept c1, Concept c2) { return c2.Extent.Count.CompareTo(c1.Extent.Count); });
            lConcepts.Sort(delegate(Concept c1, Concept c2) { return c1.Intent.Count.CompareTo(c2.Intent.Count); });

            //for (i = 0; i < lConcepts.Count; ++i)
            //{
            //    Debug.Write(string.Format("{0}: [", i + 1));
            //    foreach (int k in lConcepts[i].Extent)
            //    {
            //        Debug.Write(string.Format("{0} ", k + 1));
            //    }
            //    Debug.Write("] {");
            //    foreach (int k in lConcepts[i].Intent)
            //    {
            //        Debug.Write(string.Format("{0} ", k + 1));
            //    }
            //    Debug.WriteLine("}");
            //}

            //Debug.Assert(lConcepts[0].Attributes.Count == 0);
            //Debug.Assert(lConcepts[lConcepts.Count - 1].Objects.Count == 0);

            // Compute level for each concept
            for (i = 1; i < lConcepts.Count; ++i)
            {
                int iMax = 0;
                int cMin = -1;
                for (j = i - 1; j >= 0; --j)
                {
                    //if (lConcepts[i].Extent.IsProperSubsetOf(lConcepts[lSortedByLevel[j].Value].Extent)) // set1 is all included in set2
                    if (lConcepts[i].Intent.IsProperSupersetOf(lConcepts[j].Intent))
                    {
                        if (cMin == -1)
                        {
                            cMin = lConcepts[j].Extent.Count;
                        }
                        if (cMin != lConcepts[j].Extent.Count)
                        {
                            break;
                        }
                        if (iMax < lLevels[j])
                        {
                            iMax = lLevels[j];
                        }
                    }
                }
                Debug.Assert(cMin > -1);

                lLevels[i] = iMax + 1;
            }

            for (i = 0; i < lConcepts.Count; ++i)
            {
                Debug.WriteLine(string.Format("{0}: {1}", i + 1, lLevels[i]));
            }

            // Connect concepts
            List<Link> lLinks = new List<Link>();
            HashSet<int> hsLinked = new HashSet<int>();
            for (i = 0; i < lConcepts.Count; ++i)
            {
                for (j = i - 1; j >= 0; --j)
                {
                    if (lLevels[i] - lLevels[j] == 1)
                    {
                        //if (lConcepts[i].Extent.IsProperSubsetOf(lConcepts[lSortedByLevel[j].Value].Extent)) // set1 is all included in set2
                        if (lConcepts[i].Intent.IsProperSupersetOf(lConcepts[j].Intent))
                        {
                            lLinks.Add(new Link(lConcepts[j], lConcepts[i], j, i));
                            Debug.WriteLine(string.Format("[F:{0} T:{1}]", lLinks[lLinks.Count - 1].From + 1, lLinks[lLinks.Count - 1].To + 1));

                            // Keep track of nodes that act as targets
                            hsLinked.Add(j);
                        }
                    }
                }
            }

            // Connect remaining concepts to the bottom one
            for (i = 0; i < lConcepts.Count - 1; ++i)
            {
                if (!hsLinked.Overlaps(new int[] { i }))
                {
                    // Connect a node that has never been used as a source to the concept with empty objects and all attributes
                    lLinks.Add(new Link(lConcepts[i], lConcepts[lConcepts.Count - 1], i, lConcepts.Count - 1));
                    Debug.WriteLine(string.Format("[F:{0} T:{1}]", lLinks[lLinks.Count - 1].From + 1, lLinks[lLinks.Count - 1].To + 1));

                    hsLinked.Add(i);
                }
            }

            Debug.WriteLine(string.Format("Total links: {0}", lLinks.Count));

            return lLinks;
        }
    }
}
