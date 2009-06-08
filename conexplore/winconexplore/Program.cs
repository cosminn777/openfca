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
            //cLoader.Load("triangles.con");
            //cLoader.Load("numbers.con");
            cLoader.Load("mushrooms.con");
            //cLoader.Load("ads.con");
            //cLoader.Load("random.con");

            //NaiveConceptProcessor cNaive = new NaiveConceptProcessor();
            //Graph cGraph = cNaive.Process(cLoader.Objects, cLoader.Attributes, cLoader.Values);
            
            AndrewsConceptProcessor cAndrews = new AndrewsConceptProcessor();
            Graph cGraph = cAndrews.Process(cLoader.Objects, cLoader.Attributes, cLoader.Values);

            Console.WriteLine("Graph: {0} Concepts and {1} Edges", cGraph.Concepts.Count, cGraph.Links.Count);

            //new Saver().Save("triangles-graph.con", cGraph, cLoader.Objects, cLoader.Attributes, cLoader.Values);
            //new Saver().Save("numbers-graph.con", cGraph, cLoader.Objects, cLoader.Attributes, cLoader.Values);
            new Saver().Save("mushrooms-graph.con", cGraph, cLoader.Objects, cLoader.Attributes, cLoader.Values);
            //new Saver().Save("ads-graph.con", cGraph, cLoader.Objects, cLoader.Attributes, cLoader.Values);
            //new Saver().Save("random-graph.con", cGraph, cLoader.Objects, cLoader.Attributes, cLoader.Values);

            Console.WriteLine("Done.");
            Console.ReadLine();
        }
    }
}
