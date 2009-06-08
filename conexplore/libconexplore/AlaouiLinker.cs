using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;

namespace libconexplore
{
    class AlaouiLinker
    {
        public List<Link> Link(List<Concept> lConcepts, string[] sAttributes)
        {
            int i = 0, j = 0;

            // Sort concepts lectically
            lConcepts.Sort(delegate(Concept c1, Concept c2)
            {
                bool[] b1 = new bool[sAttributes.Length];
                bool[] b2 = new bool[sAttributes.Length];
                foreach (int k in c1.Intent)
                {
                    b1[k] = true;
                }
                foreach (int k in c2.Intent)
                {
                    b2[k] = true;
                }

                int l = 0;
                while ((l < sAttributes.Length) && (b1[l] == b2[l]))
                {
                    ++l;
                }

                if (l == sAttributes.Length)
                {
                    return 0;
                }
                else
                {
                    Debug.Assert(b1[l] != b2[l]);
                    if (b1[l]) // b1[l] == true
                    {
                        return +1; // c1 > c2
                    }
                    else // b2[l] == true
                    {
                        return -1; // c1 < c2
                    }
                }
            });

            Debug.WriteLine("");
            for (i = 0; i < lConcepts.Count; ++i)
            {
                Debug.WriteLine(string.Format("{0:00}: [{1}] [{2}]", i + 1 /*lConcepts[i].Id*/, lConcepts[i].ObjectsToString(), lConcepts[i].AttributesToString()));
            }

            // Connect concepts
            List<Link> lLinks = new List<Link>();
            for (i = 0; i < lConcepts.Count - 1; ++i)
            {
                List<Link> lLocalLinks = new List<Link>();
                for (j = i + 1; j < lConcepts.Count; ++j)
                {
                    if (lConcepts[i].Intent.IsProperSubsetOf(lConcepts[j].Intent))
                    {
                        int k = 0;
                        for (k = 0; k < lLocalLinks.Count; ++k)
                        {
                            if (lLocalLinks[k].Target.Intent.IsProperSubsetOf(lConcepts[j].Intent))
                            {
                                break;
                            }
                        }
                        if (k == lLocalLinks.Count)
                        {
                            lLocalLinks.Add(new Link(lConcepts[i], lConcepts[j], i, j));
                        }
                    }
                }
                lLinks.AddRange(lLocalLinks);
            }

            Debug.WriteLine(string.Format("Total links: {0}", lLinks.Count));

            return lLinks;
        }
    }
}
