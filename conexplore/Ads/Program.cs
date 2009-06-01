using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.IO;

namespace Ads
{
    class Program
    {
        static void Main(string[] args)
        {
            int cAttributes = 0;
            List<string> lAttributeNames = new List<string>();
            string[] lineNames = File.ReadAllLines("ad.names");
            List<string> lLineNames = new List<string>(lineNames);
            lLineNames.RemoveRange(0, 3); // Ignore continuous attributes
            lineNames = lLineNames.ToArray();

            foreach (string lineName in lineNames)
            {
                string[] head = lineName.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);
                Debug.Assert(head.Length == 2);
                string[] sepName = head[0].Split(new char[] { '*' }, StringSplitOptions.RemoveEmptyEntries);

                lAttributeNames.Add(string.Format("{0}: {1}", sepName[0].ToUpper(), ((sepName.Length > 1) ? sepName[1] : string.Empty)));
                ++cAttributes;
            }
            Debug.WriteLine(string.Format("Total number of attributes: {0}", cAttributes));

            string[] lines = File.ReadAllLines("ad.data");
            List<string> lLines = new List<string>(lines);
            //lLines.RemoveRange(0, 7000);
            lines = lLines.ToArray();

            string[][] values = new string[lines.Length][];

            int i = 0;
            for (i = 0; i < lines.Length; ++i)
            {
                values[i] = lines[i].Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            }
            Debug.WriteLine(string.Format("Total number of objects: {0}", values.Length));

            StreamWriter fs = File.CreateText("ads.xml");
            fs.WriteLine("<?xml version=\"1.0\"?><conflexplore>");
            for (i = 0; i < lAttributeNames.Count; ++i)
            {
                fs.WriteLine(string.Format("<a>{0}</a>", lAttributeNames[i]));
            }

            for (i = 0; i < values.Length; ++i)
            {
                fs.WriteLine(string.Format("<o>Ad {0}</o>", i + 1));
            }

            for (i = 0; i < values.Length; ++i)
            {
                fs.Write("<r>");
                int j = 0;
                for (j = 0; j < lAttributeNames.Count; ++j)
                {
                    fs.Write(string.Format("<c>{0}</c>", (values[i][j] == "1") ? "true" : "false"));
                }
                fs.WriteLine("</r>");
            }

            fs.WriteLine("</conflexplore>");
            fs.Close();
        }
    }
}
