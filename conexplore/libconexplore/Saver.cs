using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Diagnostics;

namespace libconexplore
{
    public class Saver
    {
        public void Save(string sFileName, Graph cGraph, string[] sObjects, string[] sAttributes, bool[][] bValues)
        {
            StreamWriter fs = File.CreateText(sFileName);
            fs.WriteLine("<?xml version=\"1.0\"?><conflexplore>");

            int i = 0;

            for (i = 0; i < sAttributes.Length; ++i)
            {
                fs.WriteLine(string.Format("<a>{0}</a>", sAttributes[i]));

            }

            for (i = 0; i < sObjects.Length; ++i)
            {
                fs.WriteLine(string.Format("<o>{0}</o>", sObjects[i]));
            }

            for (i = 0; i < bValues.Length; ++i)
            {
                fs.Write("<r>");
                int j = 0;
                for (j = 0; j < bValues[i].Length; ++j)
                {
                    fs.Write(string.Format("<c>{0}</c>", ((bValues[i][j]) ? "true" : "false")));
                }
                fs.WriteLine("</r>");
            }

            fs.WriteLine("<graph>");
            for (i = 0; i < cGraph.Concepts.Count; ++i)
            {
                fs.WriteLine(string.Format("<n id=\"{0}\" o=\"{1}\" a=\"{2}\" />", i, cGraph.Concepts[i].ObjectsToString(), cGraph.Concepts[i].AttributesToString()));
            }

            for (i = 0; i < cGraph.Links.Count; ++i)
            {
                fs.WriteLine(string.Format("<e f=\"{0}\" t=\"{1}\" />", cGraph.Links[i].From, cGraph.Links[i].To));
            }
            fs.Write("</graph>");

            fs.WriteLine("</conflexplore>");
            fs.Close();
        }
    }
}
