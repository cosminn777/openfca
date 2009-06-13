using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;

namespace libconexplore
{
    class Labeler
    {
        public string[] sObjects { get; private set; }
        public string[] sAttributes { get; private set; }
        public bool[][] bValues { get; private set; }

        public Labeler(string[] sObjects, string[] sAttributes, bool[][] bValues)
        {
            this.sObjects = sObjects;
            this.sAttributes = sAttributes;
            this.bValues = bValues;
        }

        private HashSet<int> getAttributeExtent(int iAttribute)
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

        private HashSet<int> getObjectIntent(int iObject)
        {
            HashSet<int> hsAttributes = new HashSet<int>();
            int i = 0;
            for (i = 0; i < bValues[0].Length; ++i)
            {
                if (bValues[iObject][i])
                {
                    hsAttributes.Add(i);
                }
            }
            return hsAttributes;
        }

        public List<Concept> Label(List<Concept> lConcepts)
        {
            int i = 0;

            List<HashSet<int>> lhsAttributeExtent = new List<HashSet<int>>();
            for (i = 0; i < sAttributes.Length; ++i)
            {
                lhsAttributeExtent.Add(getAttributeExtent(i));
            }
            List<HashSet<int>> lhsObjectIntent = new List<HashSet<int>>();
            for (i = 0; i < sObjects.Length; ++i)
            {
                lhsObjectIntent.Add(getObjectIntent(i));
            }

            for (i = 0; i < lConcepts.Count; ++i)
            {
                int j = 0;
                for (j = 0; j < sAttributes.Length; ++j)
                {
                    if ((lhsAttributeExtent[j].IsSubsetOf(lConcepts[i].Extent)) &&
                        (lhsAttributeExtent[j].IsSupersetOf(lConcepts[i].Extent)))
                    {
                        lConcepts[i].LabelAttributeRepresentative = j;
                        break;
                    }
                }
                for (j = 0; j < sObjects.Length; ++j)
                {
                    if ((lhsObjectIntent[j].IsSubsetOf(lConcepts[i].Intent)) &&
                        (lhsObjectIntent[j].IsSupersetOf(lConcepts[i].Intent)))
                    {
                        lConcepts[i].LabelObjectRepresentative = j;
                        break;
                    }
                }
            }

            Debug.WriteLine("");
            for (i = 0; i < lConcepts.Count; ++i)
            {
                Debug.WriteLine(string.Format("{0:00}: [{1}] [{2}] ({3}) ({4})", i + 1 /*lConcepts[i].Id*/, lConcepts[i].ObjectsToString(), lConcepts[i].AttributesToString(),
                    ((lConcepts[i].LabelObjectRepresentative != -1) ? sObjects[lConcepts[i].LabelObjectRepresentative].ToString() : ""),
                    ((lConcepts[i].LabelAttributeRepresentative != -1) ? sAttributes[lConcepts[i].LabelAttributeRepresentative].ToString() : "")));
            }

            return lConcepts;
        }
    }
}
