using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using libconexplore;

namespace winconexplore
{
    class Program
    {
        static void Main(string[] args)
        {
            Loader cLoader = new Loader();
            //cLoader.Load("triangles.xml");
            //cLoader.Load("numbers.xml");
            //cLoader.Load("mushrooms.xml");
            cLoader.Load("ads.xml");

            //NaiveConceptProcessor cNaive = new NaiveConceptProcessor();
            //cNaive.Process(cLoader.Objects, cLoader.Attributes, cLoader.Values);
            
            AndrewsConceptProcessor cAndrews = new AndrewsConceptProcessor();
            Graph cGraph = cAndrews.Process(cLoader.Objects, cLoader.Attributes, cLoader.Values);

            //new Saver().Save("triangles-graph.xml", cGraph, cLoader.Objects, cLoader.Attributes, cLoader.Values);
            //new Saver().Save("numbers-graph.xml", cGraph, cLoader.Objects, cLoader.Attributes, cLoader.Values);
            new Saver().Save("ads-graph.xml", cGraph, cLoader.Objects, cLoader.Attributes, cLoader.Values);
        }
    }
}
