using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.XPath;

namespace libconexplore
{
    public class Loader
    {
        public string FileName { get; private set; }

        public string[] Attributes { get; private set; }
        public string[] Objects { get; private set; }
        public bool[][] Values { get; private set; }

        public void Load(string sFileName)
        {
            FileName = sFileName;

            List<string> lAttributes = new List<string>();
            List<string> lObjects = new List<string>();
            List<List<bool>> llValues = new List<List<bool>>();

            XmlDocument xDoc = new XmlDocument();
            xDoc.Load(FileName);

            foreach (XmlNode xAttributeNode in xDoc.SelectNodes("/conflexplore/a"))
            {
                lAttributes.Add(xAttributeNode.InnerText);
            }

            foreach (XmlNode xObjectNode in xDoc.SelectNodes("/conflexplore/o"))
            {
                lObjects.Add(xObjectNode.InnerText);
            }

            foreach (XmlNode xRowNode in xDoc.SelectNodes("/conflexplore/r"))
            {
                llValues.Add(new List<bool>());
                foreach (XmlNode xColNode in xRowNode.SelectNodes("c"))
                {
                    llValues[llValues.Count - 1].Add(bool.Parse(xColNode.InnerText));
                }
            }

            Attributes = lAttributes.ToArray();
            Objects = lObjects.ToArray();
            
            Values = new bool[Objects.Length][];
            int i, j;
            for (i = 0; i < Objects.Length; ++i)
            {
                Values[i] = new bool[Attributes.Length];
                for (j = 0; j < Attributes.Length; ++j)
                {
                    Values[i][j] = llValues[i][j];
                }
            }
        }

    }
}
