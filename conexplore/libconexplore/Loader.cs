using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Diagnostics;

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

            StreamReader fs = new StreamReader(FileName);
            string sizes = fs.ReadLine();
            string[] size = sizes.Split(new char[] { ' ' });
            Debug.Assert(size.Length == 2);

            int cObjects = int.Parse(size[0]);
            int cAttributes = int.Parse(size[1]);

            Objects = new string[cObjects];
            Attributes = new string[cAttributes];
            Values = new bool[cObjects][];

            int i = 0;
            for (i = 0; i < cObjects; ++i)
            {
                Objects[i] = fs.ReadLine();
            }

            for (i = 0; i < cAttributes; ++i)
            {
                Attributes[i] = fs.ReadLine();
            }

            for (i = 0; i < cObjects; ++i)
            {
                string line = fs.ReadLine();
                Debug.Assert(line.Length == cAttributes);
                Values[i] = new bool[cAttributes];
                int j = 0;
                for (j = 0; j < cAttributes; ++j)
                {
                    Values[i][j] = ((line[j] == '1') ? true : false);
                }
            }

            fs.Close();
        }

    }
}
