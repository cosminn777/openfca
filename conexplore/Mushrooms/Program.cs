using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Diagnostics;

namespace Mushrooms
{
    class Program
    {
        static void Main(string[] args)
        {
            int cSuppAttributes = 0;
            List<Dictionary<char, string>> lAttributeNames = new List<Dictionary<char, string>>();
            string[] lineNames = File.ReadAllLines("agaricus-lepiota.names");
            foreach (string lineName in lineNames)
            {
                lAttributeNames.Add(new Dictionary<char, string>());
                string[] head = lineName.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);
                Debug.Assert(head.Length == 2);
                foreach (string valName in head[1].Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    string[] sepName = valName.Split(new char[] {'='}, StringSplitOptions.RemoveEmptyEntries);
                    Debug.Assert(sepName.Length == 2);

                    char[] cName = sepName[0].ToCharArray();
                    cName[0] = char.ToUpper(cName[0]);
                    lAttributeNames[lAttributeNames.Count - 1].Add(sepName[1][0], string.Format("{0}: {1}", head[0].ToUpper(), new string(cName)));
                    ++cSuppAttributes;
                }
            }
            Debug.WriteLine(string.Format("Supposed total number of attributes: {0}", cSuppAttributes));

            string[] lines = File.ReadAllLines("agaricus-lepiota.data");
            List<string> lLines = new List<string>(lines);
            //lLines.RemoveRange(0, 7000);
            lines = lLines.ToArray();

            string[][] values = new string[lines.Length][];

            int i = 0;
            for (i = 0; i < lines.Length; ++i)
            {
                values[i] = lines[i].Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            }

            int cAttributes = 0;
            List<List<string>> llAttributes = new List<List<string>>(values[0].Length);

            for (i = 0; i < values[0].Length; ++i)
            {
                llAttributes.Add(new List<string>());
                int j = 0;
                for (j = 0; j < values.Length; ++j)
                {
                    if (!llAttributes[i].Contains(values[j][i]))
                    {
                        llAttributes[i].Add(values[j][i]);
                        ++cAttributes;
                    }
                }
            }
            Debug.WriteLine(string.Format("Total number of attributes: {0}", cAttributes));

            StreamWriter fs = File.CreateText("mushrooms.xml");
            fs.WriteLine("<?xml version=\"1.0\"?><conflexplore>");
            for (i = 0; i < llAttributes.Count; ++i)
            {
                int j = 0;
                for (j = 0; j < llAttributes[i].Count; ++j)
                {
                    fs.WriteLine(string.Format("<a>{0}</a>", lAttributeNames[i][llAttributes[i][j][0]]));
                }
            }

            for (i = 0; i < values.Length; ++i)
            {
                fs.WriteLine(string.Format("<o>Mushroom {0}</o>", i + 1));
            }

            for (i = 0; i < values.Length; ++i)
            {
                fs.Write("<r>");
                int j = 0;
                for (j = 0; j < llAttributes.Count; ++j)
                {
                    int k = 0;
                    for (k = 0; k < llAttributes[j].Count; ++k)
                    {
                        fs.Write(string.Format("<c>{0}</c>", ((llAttributes[j][k] == values[i][j]) ? "true" : "false")));
                    }
                }
                fs.WriteLine("</r>");
            }

            fs.WriteLine("</conflexplore>");
            fs.Close();
        }
    }
}
