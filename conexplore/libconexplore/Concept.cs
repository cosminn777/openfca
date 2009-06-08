using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace libconexplore
{
    public class Concept
    {
        /* public int Id { get; private set; } */

        public List<string> Objects { get; private set; }
        public List<string> Attributes { get; private set; }

        public HashSet<int> Extent { get; private set; }
        public HashSet<int> Intent { get; private set; }

        public Concept(/*int iId, */HashSet<int> hsExtent, HashSet<int> hsIntent, string[] sObjects, string[] sAttributes)
        {
            /*Id = iId;*/
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
            int[] iExtent = Extent.ToArray();
            string[] sExtent = new string[iExtent.Length];
            int i = 0;
            for (i = 0; i < iExtent.Length; ++i)
            {
                sExtent[i] = iExtent[i].ToString();
            }
            return string.Join(",", sExtent);
        }

        public string ObjectsToString()
        {
            return string.Join(",", Objects.ToArray());
        }

        public string AttributesToString()
        {
            return string.Join(",", Attributes.ToArray());
        }

        public string AttributesToId()
        {
            int[] iIntent = Intent.ToArray();
            string[] sIntent = new string[iIntent.Length];
            int i = 0;
            for (i = 0; i < iIntent.Length; ++i)
            {
                sIntent[i] = iIntent[i].ToString();
            }
            return string.Join(",", sIntent);
        }

    }
}
