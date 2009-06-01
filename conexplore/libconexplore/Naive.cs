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

        private List<int> getAttributeExtent(bool[][] data, int attribute)
		{
			List<int> objects = new List<int>();
			int i = 0;
			for (i = 0; i < data.Length; ++i)
			{
				if (data[i][attribute] == true)
				{
					objects.Add(i);
				}	
			}
			return objects;
		}

        
		private List<int> getIntent(bool[][] data, string[] attributes, List<int> extent)
		{
			List<int> intent = new List<int>();
			int i = 0;
			for (i = 0; i < attributes.Length; ++i)
			{
				int j = 0;
				for (j = 0; j < extent.Count; ++j)
				{
					if (data[extent[j]][i] == false)
					{
						break;
					}
				}
				if (j == extent.Count)
				{
					intent.Add(i);
				}
			}
			return intent;
		}
		

        private List<int> getIntersection(List<int> set1, List<int> set2)
		{
			List<int> intersection = new List<int>();
			int i = 0;
			for (i = 0; i < set1.Count; ++i)
			{
				if (set2.IndexOf(set1[i],0) > -1) // exists in set2
				{
					intersection.Add(set1[i]);	
				}
			}
			return intersection;
		}

        private bool equalArray(List<int> set1, List<int> set2)
		{
			if (set1.Count != set2.Count)
			{
				return false;
			}
			if (set1.Count == 0) // empty arrays are considered to be equal
			{
				return true;
			}
			
			int j = 0;
			for (j = 0; j < set1.Count; ++j)
			{
				if (set2.IndexOf(set1[j], 0) == -1) // not in the array
				{
					return false;
				}
			}	
			return true;
		}
		

        private bool containsArray(List<List<int>> sets, List<int> containedSet)
		{
			int i = 0;
			for (i = 0; i < sets.Count; ++i)
			{
				if (equalArray(sets[i], containedSet))
				{
					return true;
				}		
			}
			return false;
		}

        public void Compute(string[] objects, string[] attributes, bool[][] data)
        {
            List<List<int>> extents = new List<List<int>>(); // will contain all extents
			List<List<int>> intents = new List<List<int>>();

			int j = 0;
			int i = 0;
			int k = 0;
			
			// for each attribute, write their extents
			for (j = 0; j < attributes.Length; ++j)
			{
				List<int> attributeExtent = getAttributeExtent(data, j);
				if (!containsArray(extents, attributeExtent))
				{
					extents.Add(attributeExtent);
				}
			}
			// while the extents set changes, compute all pairwise intersections
			bool changed = false;
			while (!changed)
			{
				changed = false;
				int len = extents.Count;
				
				for (i = 0; i < len - 1; ++i)
				{
					for (k = i + 1; k < len; ++k)
					{
						List<int> intersection = getIntersection(extents[i], extents[k]);
						if (!containsArray(extents, intersection))
						{
							extents.Add(intersection);
							changed = true;
						}
					}
				}
			}
			// add the set of all objects if it's not already in the list
			List<int> allObjects = new List<int>();
			for (j = 0; j < objects.Length; ++j)
			{
				allObjects.Add(j);
			} 
			if (!containsArray(extents, allObjects))
			{
				extents.Add(allObjects);
			}
			
			
			// initialize levels for each concept
			List<int> level = new List<int>();
			for (i = 0; i < extents.Count; ++i)
			{
				level.Add(0); // initialize all to level 0
			}
			
			// sort extents by their leghth, number of objects
			List<int> set1;
			List<int> set2;
			for (i = 0; i < extents.Count - 1; ++i)
			{
				for (j = i + 1; j < extents.Count; ++j)
				{
					set1 = extents[i];
					set2 = extents[j];
					if (set1.Count < set2.Count)
					{
						extents[i] = set2;
						extents[j] = set1;
					}
				}
			}
			
			// compute the levels for each concept
			for (i = 0; i < extents.Count; ++i)
			{
				int max = 0;
				for (j = i - 1; j >= 0; --j)
				{
					set1 = extents[i];
					set2 = extents[j];
					if (getIntersection(set1, set2).Count == set1.Count) // set1 is all included in set2
					{
						if (max < level[j])
						{
							max = level[j]; 
						}
					}	
				}
				level[i] = max + 1;
			}
			
			// compute intents for all extents
			for (i = 0; i < extents.Count; ++i)
			{
				intents.Add(getIntent(data, attributes, extents[i]));
			}

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
