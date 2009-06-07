package logic
{
	import com.adobe.flex.extras.controls.springgraph.Graph;
	import com.adobe.flex.extras.controls.springgraph.Item;
	
	import mx.collections.ArrayCollection;

	public class NaiveConceptProcessor implements IConceptProcessor
	{
		
		private var sObjects: Array;
		private var sAttributes: Array;
		
		private	var extents: ArrayCollection = new ArrayCollection(); // will contain all extents
		private	var intents:ArrayCollection = new ArrayCollection();

		public function NaiveConceptProcessor(objects:Array, attributes:Array)
		{
			sObjects = objects;
			sAttributes = attributes;
		}
		
		public function getConceptList(): Array
		{
			var conceptList: Array = new Array();
			var i:int = 0;
			for (i = 0; i < extents.length; ++i)
			{
				var j:int = 0;
				// convert extent index to name
				var conceptObjects:Array = new Array();
				var conceptExtents:Array = extents[i];
				for (j = 0; j < conceptExtents.length; ++j)
				{
					conceptObjects.push(conceptExtents[j]);
				}
				
				// convert intent index to name
				var conceptAttributes:Array = new Array();
				var conceptIntents:Array = intents[i];
				for (j = 0; j < conceptIntents.length; ++j)
				{
					conceptAttributes.push(conceptIntents[j]);
				}
				
				conceptList[i.toString()] = new Concept(conceptObjects, conceptAttributes); // use the same id's that are in Graph nodes	
			}
			 
			return conceptList;
		}

		private function getAttributeExtent(data:ArrayCollection, attribute:int):Array
		{
			var objects:Array = new Array();
			var i:int = 0;
			for (i = 0; i < data.length; ++i)
			{
				if (data[i][attribute] == true)
				{
					objects.push(i);
				}	
			}
			return objects;
		}
		
		private function getIntent(data:ArrayCollection, attributes:Array, extent:Array):Array
		{
			var intent:Array = new Array();
			var i:int = 0;
			for (i = 0; i < attributes.length; ++i)
			{
				var j:int = 0;
				for (j = 0; j < extent.length; ++j)
				{
					if (data[extent[j]][i] == false)
					{
						break;
					}
				}
				if (j == extent.length)
				{
					intent.push(i);
				}
			}
			return intent;
		}
		
		private function getIntersection(set1:Array, set2:Array):Array
		{
			var intersection:Array = new Array();
			var i:int = 0;
			for (i = 0; i < set1.length; ++i)
			{
				if (set2.indexOf(set1[i],0) > -1) // exists in set2
				{
					intersection.push(set1[i]);	
				}
			}
			return intersection;
		}
		
		private function equalArray(set1:Array, set2:Array):Boolean
		{
			if (set1.length != set2.length)
			{
				return false;
			}
			if (set1.length == 0) // empty arrays are considered to be equal
			{
				return true;
			}
			
			var j:int = 0;
			for (j = 0; j < set1.length; ++j)
			{
				if (set2.indexOf(set1[j], 0) == -1) // not in the array
				{
					return false;
				}
			}	
			return true;
		}
		
		private function containsArray(sets: ArrayCollection, containedSet:Array):Boolean
		{
			var i:int = 0;
			for (i = 0; i < sets.length; ++i)
			{
				if (equalArray(sets[i], containedSet))
				{
					return true;
				}		
			}
			return false;
		}
		
		public function computeConcept(data:ArrayCollection):Graph
		{
			var g:Graph = new Graph();
			
			extents = new ArrayCollection(); // will contain all extents
			intents = new ArrayCollection();
			var j: int = 0;
			var i:int = 0;
			var k:int = 0;
			
			// for each attribute, write their extents
			for (j = 0; j < sAttributes.length; ++j)
			{
				var attributeExtent: Array = getAttributeExtent(data, j);
				if (!containsArray(extents, attributeExtent))
				{
					extents.addItem(attributeExtent);
				}
			}
			// while the extents set changes, compute all pairwise intersections
			var changed:Boolean = true;
			while (changed)
			{
				changed = false;
				var len:int = extents.length;
				
				for (i = 0; i < len - 1; ++i)
				{
					for (k = i + 1; k < len; ++k)
					{
						var intersection:Array = getIntersection(extents[i], extents[k]);
						if (!containsArray(extents, intersection))
						{
							extents.addItem(intersection);
							changed = true;
						}
					}
				}
			}
			// add the set of all objects if it's not already in the list
			var allObjects:Array = new Array();
			for (j = 0; j < sObjects.length; ++j)
			{
				allObjects.push(j);
			} 
			if (!containsArray(extents, allObjects))
			{
				extents.addItem(allObjects);
			}
			
			
			// initialize levels for each concept
			var level: Array = new Array();
			for (i = 0; i < extents.length; ++i)
			{
				level.push(0); // initialize all to level 0
			}
			
			// sort extents by their leghth, number of objects
			var set1:Array;
			var set2:Array;
			for (i = 0; i < extents.length - 1; ++i)
			{
				for (j = i + 1; j < extents.length; ++j)
				{
					set1 = extents[i];
					set2 = extents[j];
					if (set1.length < set2.length)
					{
						extents[i] = set2;
						extents[j] = set1;
					}
				}
			}
			
			// compute the levels for each concept
			for (i = 0; i < extents.length; ++i)
			{
				var max:int = 0;
				for (j = i - 1; j >= 0; --j)
				{
					set1 = extents[i];
					set2 = extents[j];
					if (getIntersection(set1, set2).length == set1.length) // set1 is all included in set2
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
			for (i = 0; i < extents.length; ++i)
			{
				intents.addItem(getIntent(data, sAttributes, extents[i]));
			}
			
			var concepts: Array = new Array();
			// create graph nodes
			for (i = 0; i < extents.length; ++i)
			{
				// convert extent index to name
				/*
				var conceptObjects:Array = new Array();
				var conceptExtents:Array = extents[i];
				for (j = 0; j < conceptExtents.length; ++j)
				{
					conceptObjects.push(sObjects[conceptExtents[j]]);
				}
				*/
				
				// convert intent index to name
				/*
				var conceptAttributes:Array = new Array();
				var conceptIntents:Array = intents[i];
				for (j = 0; j < conceptIntents.length; ++j)
				{
					conceptAttributes.push(sAttributes[conceptIntents[j]]);
				}
				*/
				
				var concept:Item = new ConceptItem(i.toString(), "A: " + intents[i].length, "O: " + extents[i].length.toString());
				concepts.push(concept);
				g.add(concept);
			}

			var links:int = 0;
			// connect concepts
			var linked: Array = new Array();
			for (i = 0; i < extents.length; ++i)
			{
				for (j = i - 1; j >= 0; --j)
				{
					set1 = extents[i];
					set2 = extents[j];
					if (getIntersection(set1, set2).length == set1.length) // set1 is all included in set2
					{
						if (level[i] - level[j] == 1) // has to be on the next level
						{
							g.link(g.find(j.toString()), g.find(i.toString()));
							++links;
							// keep track of nodes that act as targets
							if (linked.indexOf(j, 0) == -1)
							{ 
								linked.push(j);
							}
						}
					}	
				}
			}
			
			// connect remaining concepts to the bottom one (a.k.a. covaseala)
			for (i = 0; i < extents.length - 1; ++i)
			{
				if (linked.indexOf(i,0) == -1)
				{
					// connect a node that has never been used as a source to the concept with empty objects and all attributes
					g.link(g.find(i.toString()), g.find((extents.length - 1).toString()));
					++links;
				}
			}
						
			return g;
		}
		
	}
}