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
            fs.WriteLine(string.Format("{0} {1} {2} {3}", sObjects.Length, sAttributes.Length, cGraph.Concepts.Count, cGraph.Links.Count));

            int i = 0;

            for (i = 0; i < sObjects.Length; ++i)
            {
                fs.WriteLine(string.Format("{0}", sObjects[i]));
            }

            for (i = 0; i < sAttributes.Length; ++i)
            {
                fs.WriteLine(string.Format("{0}", sAttributes[i]));

            }

            for (i = 0; i < bValues.Length; ++i)
            {
                int j = 0;
                for (j = 0; j < bValues[i].Length; ++j)
                {
                    fs.Write(string.Format("{0}", ((bValues[i][j]) ? "1" : "0")));
                }
                fs.WriteLine("");
            }

            for (i = 0; i < cGraph.Concepts.Count; ++i)
            {
                fs.WriteLine(string.Format("{0}", i));
                fs.WriteLine(string.Format("{0}", cGraph.Concepts[i].ObjectsToId()));
                fs.WriteLine(string.Format("{0}", cGraph.Concepts[i].AttributesToId()));
            }

            for (i = 0; i < cGraph.Links.Count; ++i)
            {
                fs.WriteLine(string.Format("{0},{1}", cGraph.Links[i].From, cGraph.Links[i].To));
            }

            fs.Close();
        }
    }
}
