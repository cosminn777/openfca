using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace libconexplore
{
    public class Concept
    {
        public List<string> Objects { get; private set; }
        public List<string> Attributes { get; private set; }

        public HashSet<int> Extent { get; private set; }
        public HashSet<int> Intent { get; private set; }

        public Concept(HashSet<int> hsExtent, HashSet<int> hsIntent, string[] sObjects, string[] sAttributes)
        {
            Extent = hsExtent;
            Intent = hsIntent;

            // Convert extent index to name
            Objects = new List<string>();
            foreach (int iObject in Extent)
            {
                Objects.Add(sObjects[iObject]);
            }

            // Convert intent index to name
            Attributes = new List<string>();
            foreach (int iAttribute in Intent)
            {
                Attributes.Add(sAttributes[iAttribute]);
            }
        }

        public string ObjectsToId()
        {
            StringBuilder sb = new StringBuilder();
            foreach (int i in Extent)
            {
                sb.Append(string.Format("{0},", i));
            }
            return sb.ToString();
        }

        public string ObjectsToString()
        {
            StringBuilder sb = new StringBuilder();
            foreach (string sObject in Objects)
            {
                sb.Append(string.Format("{0}; ", sObject));
            }
            return sb.ToString();
        }

        public string AttributesToString()
        {
            StringBuilder sb = new StringBuilder();
            foreach (string sAttibute in Attributes)
            {
                sb.Append(string.Format("{0}; ", sAttibute));
            }
            return sb.ToString();
        }

        public string AttributesToId()
        {
            StringBuilder sb = new StringBuilder();
            foreach (int i in Intent)
            {
                sb.Append(string.Format("{0},", i));
            }
            return sb.ToString();
        }

    }
}
