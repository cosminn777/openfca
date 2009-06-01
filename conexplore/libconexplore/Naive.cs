using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;

namespace libconexplore
{
    public class Naive
    {
        public Naive()
        {

        }

        private HashSet<int> getAttributeExtent(bool[][] data, int attribute)
        {
            HashSet<int> objects = new HashSet<int>();
            int i = 0;
            for (i = 0; i < data.Length; ++i)
            {
                if (data[i][attribute])
                {
                    objects.Add(i);
                }
            }
            return objects;
        }


        private HashSet<int> getIntent(bool[][] data, string[] attributes, HashSet<int> extent)
        {
            HashSet<int> intent = new HashSet<int>();
            int i = 0;
            for (i = 0; i < attributes.Length; ++i)
            {
                bool bOk = true;
                foreach (int j in extent)
                {
                    if (data[j][i] == false)
                    {
                        bOk = false;
                        break;
                    }
                }
                if (bOk)
                {
                    intent.Add(i);
                }
            }
            return intent;
        }

        //private bool contains(Dictionary<string, HashSet<int>> lSets, HashSet<int> containedSet)
        //{
        //    return lSets.ContainsKey(getKey(containedSet));

        //    //int i = 0;
        //    //for (i = 0; i < lSets.Count; ++i)
        //    //{
        //    //    if ((lSets[i].IsSubsetOf(containedSet)) && (lSets[i].IsSupersetOf(containedSet)))
        //    //    {
        //    //        return true;
        //    //    }
        //    //}
        //    //return false;
        //}

        //private string getKey(HashSet<int> set)
        //{
        //    StringBuilder sb = new StringBuilder();
        //    sb.Append(set.Count.ToString() + ":");

        //    foreach (int i in set)
        //    {
        //        sb.Append(i.ToString());
        //    }

        //    //Debug.WriteLine(sb.ToString());

        //    return sb.ToString();
        //}

        public void Compute(string[] objects, string[] attributes, bool[][] data)
        {
            HashSet<HashSet<int>> extents = new HashSet<HashSet<int>>(new NaiveComparer()); // will contain all extents
            List<HashSet<int>> intents = new List<HashSet<int>>();

            int j = 0;
            int i = 0;
            //int k = 0;

            // for each attribute, write their extents
            for (j = 0; j < attributes.Length; ++j)
            {
                HashSet<int> attributeExtent = getAttributeExtent(data, j);
                //if (!contains(extents, attributeExtent))
                //{
                extents.Add(attributeExtent);
                //}
            }
            // while the extents set changes, compute all pairwise intersections
            bool changed = true;
            while (changed)
            {
                changed = false;
                
                List<HashSet<int>> ll = new List<HashSet<int>>(extents);
                int len = ll.Count;

                for (i = 0; i < len - 1; ++i)
                {
                    for (j = i + 1; j < len; ++j)
                    {
                        HashSet<int> intersection = new HashSet<int>(ll[i]);
                        intersection.IntersectWith(ll[j]);
                        //if (!contains(extents, intersection))
                        //{
                        if (extents.Add(intersection))
                        {
                            changed = true;
                        }
                        //}
                    }
                }
            }
            // add the set of all objects if it's not already in the list
            HashSet<int> allObjects = new HashSet<int>();
            for (j = 0; j < objects.Length; ++j)
            {
                allObjects.Add(j);
            }
            //if (!contains(extents, allObjects))
            //{
            extents.Add(allObjects);
            //}


            // initialize levels for each concept
            List<int> level = new List<int>();
            for (i = 0; i < extents.Count; ++i)
            {
                level.Add(0); // initialize all to level 0
            }

            // sort extents by their leghth, number of objects
            //HashSet<int> set1;
            //HashSet<int> set2;
            //for (i = 0; i < extents.Count - 1; ++i)
            //{
            //    for (j = i + 1; j < extents.Count; ++j)
            //    {
            //        set1 = extents[i];
            //        set2 = extents[j];
            //        if (set1.Count < set2.Count)
            //        {
            //            extents[i] = set2;
            //            extents[j] = set1;
            //        }
            //    }
            //}

            // compute the levels for each concept
            //for (i = 0; i < extents.Count; ++i)
            //{
            //    int max = 0;
            //    for (j = i - 1; j >= 0; --j)
            //    {
            //        set1 = extents[i];
            //        set2 = extents[j];
            //        if (set1.IsSubsetOf(set2)) // set1 is all included in set2
            //        {
            //            if (max < level[j])
            //            {
            //                max = level[j];
            //            }
            //        }
            //    }
            //    level[i] = max + 1;
            //}

            // compute intents for all extents
            //for (i = 0; i < extents.Count; ++i)
            //{
            //    intents.Add(getIntent(data, attributes, extents[i]));
            //}

            Debug.WriteLine(string.Format("Formal concepts: {0}", extents.Count));

            //List<int> concepts: Array = new Array();
            //// create graph nodes
            //for (i = 0; i < extents.length; ++i)
            //{
            //    // convert extent index to name
            //    var conceptObjects:Array = new Array();
            //    var conceptExtents:Array = extents[i];
            //    for (j = 0; j < conceptExtents.length; ++j)
            //    {
            //        conceptObjects.push(objects[conceptExtents[j]]);
            //    }
            //    // convert intent index to name
            //    var conceptAttributes:Array = new Array();
            //    var conceptIntents:Array = intents[i];
            //    for (j = 0; j < conceptIntents.length; ++j)
            //    {
            //        conceptAttributes.push(attributes[conceptIntents[j]]);
            //    }

            //    var concept:ConceptItem = new ConceptItem(i.toString(), conceptAttributes, conceptObjects); 
            //    concepts.push(concept);
            //    g.add(concept);
            //}

            //var links:int = 0;
            //// connect concepts
            //var linked: Array = new Array();
            //for (i = 0; i < extents.length; ++i)
            //{
            //    for (j = i - 1; j >= 0; --j)
            //    {
            //        set1 = extents[i];
            //        set2 = extents[j];
            //        if (getIntersection(set1, set2).length == set1.length) // set1 is all included in set2
            //        {
            //            if (level[i] - level[j] == 1) // has to be on the next level
            //            {
            //                g.link(g.find(j.toString()), g.find(i.toString()));
            //                ++links;
            //                // keep track of nodes that act as targets
            //                if (linked.indexOf(j, 0) == -1)
            //                { 
            //                    linked.push(j);
            //                }
            //            }
            //        }	
            //    }
            //}

            //// connect remaining concepts to the bottom one (a.k.a. covaseala)
            //for (i = 0; i < extents.length - 1; ++i)
            //{
            //    if (linked.indexOf(i,0) == -1)
            //    {
            //        // connect a node that has never been used as a source to the concept with empty objects and all attributes
            //        g.link(g.find(i.toString()), g.find((extents.length - 1).toString()));
            //        ++links;
            //    }
            //}
        }
    }
}
