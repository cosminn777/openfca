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
            lConcepts.Sort(delegate(Concept c1, Concept c2) { return c2.Extent.Count.CompareTo(c1.Extent.Count); });

            //Debug.Assert(lConcepts[0].Attributes.Count == 0);
            //Debug.Assert(lConcepts[lConcepts.Count - 1].Objects.Count == 0);

            // Compute level for each concept
            for (i = 0; i < lConcepts.Count; ++i)
            {
                int iMax = 0;
                for (j = i - 1; j >= 0; --j)
                {
                    if (lConcepts[i].Extent.IsSubsetOf(lConcepts[j].Extent)) // set1 is all included in set2
                    {
                        if (iMax < lLevels[j])
                        {
                            iMax = lLevels[j];
                        }
                    }
                }
                lLevels[i] = iMax + 1;
            }

            // Connect concepts
            List<Link> lLinks = new List<Link>();
            HashSet<int> hsLinked = new HashSet<int>();
            for (i = 0; i < lConcepts.Count; ++i)
            {
                for (j = i - 1; j >= 0; --j)
                {
                    if (lConcepts[i].Extent.IsSubsetOf(lConcepts[j].Extent)) // set1 is all included in set2
                    {
                        if (lLevels[i] - lLevels[j] == 1) // Is on the next level
                        {
                            lLinks.Add(new Link(lConcepts[j], lConcepts[i], j, i));
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
                    hsLinked.Add(i);
                }
            }

            Debug.WriteLine(string.Format("Total links: {0}", lLinks.Count));

            return lLinks;
        }
    }
}
