using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;

namespace libconexplore
{
    public class FloydWarshallLinker
    {
        public FloydWarshallLinker()
        {

        }

        public List<Link> Link(List<Concept> lConcepts)
        {
            int i = 0, j = 0, k = 0;

            bool[][] bIncluded = new bool[lConcepts.Count][];
            for (i = 0; i < bIncluded.Length; ++i)
            {
                bIncluded[i] = new bool[lConcepts.Count];
            }

            for (i = 0; i < bIncluded.Length; ++i)
            {
                for (j = 0; j < bIncluded.Length; ++j)
                {
                    bIncluded[i][j] = lConcepts[i].Intent.IsProperSupersetOf(lConcepts[j].Intent);
                }
            }

            Debug.WriteLine("");
            for (i = 0; i < bIncluded.Length; ++i)
            {
                Debug.Write(string.Format("{0:00}: ", i + 1));
                for (j = 0; j < bIncluded.Length; ++j)
                {
                    Debug.Write(string.Format("{0} ", (bIncluded[i][j] ? "1" : "0")));
                }
                Debug.WriteLine("");
            }

            for (k = 0; k < bIncluded.Length; ++k)
            {
                for (i = 0; i < bIncluded.Length; ++i)
                {
                    for (j = 0; j < bIncluded.Length; ++j)
                    {
                        if (bIncluded[i][j])
                        {
                            if ((bIncluded[i][k]) && (bIncluded[k][j]))
                            {
                                bIncluded[i][j] = false;
                            }
                        }
                    }
                }
            }

            Debug.WriteLine("");
            for (i = 0; i < bIncluded.Length; ++i)
            {
                Debug.Write(string.Format("{0:00}: ", i + 1));
                for (j = 0; j < bIncluded.Length; ++j)
                {
                    Debug.Write(string.Format("{0} ", (bIncluded[i][j] ? "1" : "0")));
                }
                Debug.WriteLine("");
            }

            Debug.WriteLine("");
            for (i = 0; i < lConcepts.Count; ++i)
            {
                Debug.Write(string.Format("{0:00}: [", i + 1));
                foreach (int q in lConcepts[i].Extent)
                {
                    Debug.Write(string.Format("{0} ", q + 1));
                }
                Debug.Write("] {");
                foreach (int q in lConcepts[i].Intent)
                {
                    Debug.Write(string.Format("{0} ", q + 1));
                }
                Debug.WriteLine("}");
            }

            //Debug.Assert(lConcepts[0].Attributes.Count == 0);
            //Debug.Assert(lConcepts[lConcepts.Count - 1].Objects.Count == 0);

            // Connect concepts
            List<Link> lLinks = new List<Link>();
            for (i = 0; i < bIncluded.Length; ++i)
            {
                for (j = 0; j < bIncluded.Length; ++j)
                {
                    if (bIncluded[i][j])
                    {
                        lLinks.Add(new Link(lConcepts[i], lConcepts[j], i, j));
                        Debug.WriteLine(string.Format("[F:{0} T:{1}]", lLinks[lLinks.Count - 1].From + 1, lLinks[lLinks.Count - 1].To + 1));
                    }
                }
            }

            Debug.WriteLine(string.Format("Total links: {0}", lLinks.Count));

            return lLinks;
        }
    }
}
