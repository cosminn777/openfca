using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;

namespace libconexplore
{
    public class AndrewsConceptProcessor : IConceptProcessor
    {
        List<HashSet<int>> lhsA = new List<HashSet<int>>();
        List<HashSet<int>> lhsB = new List<HashSet<int>>();

        int iNewR = 0;

        private void InClose(int iR, int iY, bool[][] bValues)
        {
            int j = 0;

            iNewR = iNewR + 1;
            lhsA.Add(new HashSet<int>());
            lhsB.Add(new HashSet<int>());

            for (j = iY; j <= bValues[0].Length - 1; ++j)
            {
                lhsA[iNewR].Clear();

                foreach (int i in lhsA[iR])
                {
                    if (bValues[i][j])
                    {
                        lhsA[iNewR].Add(i);
                    }
                }
                if (lhsA[iNewR].Count > 0)
                {
                    if (lhsA[iNewR].Count == lhsA[iR].Count)
                    {
                        lhsB[iR].Add(j);
                    }
                    else
                    {
                        if (IsCannonical(iR, j - 1, bValues))
                        {
                            lhsB[iNewR].Clear();
                            lhsB[iNewR].UnionWith(lhsB[iR]);
                            lhsB[iNewR].Add(j);
                            //Debug.WriteLine(string.Format("[{0} < {1}]", iNewR + 1, iR + 1));
                            InClose(iNewR, j + 1, bValues);
                        }

                    }
                }
            }
        }

        private bool IsCannonical(int iR, int iY, bool[][] bValues)
        {
            int k = 0, j = 0, h = 0;

            int[] aB = new int[lhsB[iR].Count];
            lhsB[iR].CopyTo(aB);

            int[] aA = new int[lhsA[iNewR].Count];
            lhsA[iNewR].CopyTo(aA);

            for (k = aB.Length - 1; k >= 0; --k)
            {
                for (j = iY; j >= aB[k] + 1; --j)
                {
                    for (h = 0; h <= aA.Length - 1; ++h)
                    {
                        if (!bValues[aA[h]][j])
                        {
                            break;
                        }
                    }
                    if (h == aA.Length)
                    {
                        return false;
                    }
                }
                iY = aB[k] - 1;
            }

            for (j = iY; j >= 0; --j)
            {
                for (h = 0; h <= aA.Length - 1; ++h)
                {
                    if (!bValues[aA[h]][j])
                    {
                        break;
                    }
                }
                if (h == aA.Length)
                {
                    return false;
                }
            }

            return true;
        }

        public Graph Process(string[] sObjects, string[] sAttributes, bool[][] bValues)
        {
            int i = 0;

            HashSet<int> hsSupremumObjects = new HashSet<int>();
            HashSet<int> hsSupremumAttributes = new HashSet<int>();

            for (i = 0; i < sObjects.Length; ++i)
            {
                hsSupremumObjects.Add(i);
            }

            lhsA.Clear();
            lhsB.Clear();
            lhsA.Add(hsSupremumObjects);
            lhsB.Add(hsSupremumAttributes);

            iNewR = 0;
            InClose(0, 0, bValues);

            int iInfimum = -1;
            for (i = 0; i < lhsA.Count; ++i)
            {
                if ((lhsA[i].Count == 0)/* && (lhsB[i].Count == 0)*/)
                {
                    iInfimum = i;
                }
            }

            //if (iInfimum == -1)
            //{
            //    lhsA.Add(new HashSet<int>());
            //    lhsB.Add(new HashSet<int>());
            //}

            if (iInfimum > -1)
            {
                // The infimum does not contain attributes, so correct that
                for (i = 0; i < sAttributes.Length; ++i)
                {
                    lhsB[iInfimum].Add(i);
                }
            }

            Debug.Assert(lhsA.Count == lhsB.Count);
            Debug.WriteLine(string.Format("Total formal concepts: {0}", lhsA.Count));

            for (i = 0; i < lhsA.Count; ++i)
            {
                Debug.Write(string.Format("{0:00}: [", i + 1));
                foreach (int j in lhsA[i])
                {
                    Debug.Write(string.Format("{0} ", j + 1));
                }
                Debug.Write("] {");
                foreach (int j in lhsB[i])
                {
                    Debug.Write(string.Format("{0} ", j + 1));
                }
                Debug.WriteLine("}");
            }

            // Create concepts
            List<Concept> lConcepts = new List<Concept>();
            for (i = 0; i < lhsA.Count; ++i)
            {
                lConcepts.Add(new Concept(lhsA[i], lhsB[i], sObjects, sAttributes));
            }

            return new Graph() { Concepts = lConcepts, Links = new FloydWarshallLinker().Link(lConcepts) };
        }
    }
}
