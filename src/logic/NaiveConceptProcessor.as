package logic
{
	import com.adobe.flex.extras.controls.springgraph.Graph;
	
	import mx.collections.ArrayCollection;

	public class NaiveConceptProcessor implements IConceptProcessor
	{
		
		private var sObjects: Array;
		private var sAttributes: Array;
		
		private	var extents: ArrayCollection = new ArrayCollection(); // will contain all extents
		private	var intents:ArrayCollection = new ArrayCollection();

		private var concepts:Array = new Array();
		private var labelsAttribute:Array = new Array();
		private var labelsObject:Array = new Array();
		
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
				
				var c:Concept = new Concept(conceptObjects, conceptAttributes); // use the same id's that are in Graph nodes
				
				c.attachedObject = (labelsObject[i] != -1) ? labelsObject[i].toString() : null;
				c.attachedAttribute = (labelsAttribute[i] != -1) ? labelsAttribute[i].toString() : null;
				
				conceptList[i.toString()] = c;
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
		
		private function getObjectIntent(data:ArrayCollection, object:int):Array
		{
			var attributes:Array = new Array();
			var i:int = 0;
			for (i = 0; i < data[0].length; ++i)
			{
				if (data[object][i] == true)
				{
					attributes.push(i);
				}	
			}
			return attributes;
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
		
		private function findArray(sets: ArrayCollection, containedSet:Array):int
		{
			var i:int = 0;
			for (i = 0; i < sets.length; ++i)
			{
				if (equalArray(sets[i], containedSet))
				{
					return i;
				}		
			}
			return -1;
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
			
			// find supremum and put it on the first position
			var iFind: int = findArray(extents, allObjects);
			if (iFind > -1)
			{
				var aux: Array = extents[0];
				extents[0] = extents[iFind];
				extents[iFind] = aux;
			}
									
			// compute intents for all extents
			for (i = 0; i < extents.length; ++i)
			{
				intents.addItem(getIntent(data, sAttributes, extents[i]));
			}
			
			var labelAttributeExtent:Array = new Array();
			for (i = 0; i < sAttributes.length; ++i)
			{
				labelAttributeExtent.push(getAttributeExtent(data, i));
			}
			var labelObjectIntent:Array = new Array();
			for (i = 0; i < sObjects.length; ++i)
			{
				labelObjectIntent.push(getObjectIntent(data, i));
			}
			
			concepts = new Array();
			labelsAttribute = new Array();
			labelsObject = new Array();
			
			// create graph nodes
			for (i = 0; i < extents.length; ++i)
			{
				var iAttribute: int = -1;
				for (j = 0; j < sAttributes.length; ++j)
				{
					if (equalArray(extents[i], labelAttributeExtent[j]))
					{
						iAttribute = j;
					}
				}
				var iObject: int = -1;
				for (j = 0; j < sObjects.length; ++j)
				{
					if (equalArray(intents[i], labelObjectIntent[j]))
					{
						iObject = j;
					}
				}
				
				labelsAttribute.push(iAttribute);
				labelsObject.push(iObject);
				
				var sLabelAttribute:String = ((iAttribute != -1) ? sAttributes[iAttribute] : null); 
				var sLabelObject:String = ((iObject != -1) ? sObjects[iObject] : null);
				
				var concept:ConceptItem = new ConceptItem(i.toString(), intents[i].length, extents[i].length);
					
				concept.attachedAttribute = sLabelAttribute;
				concept.attachedObject = sLabelObject;
				
				concepts.push(concept);
				g.add(concept);
			}

			// Init for Floyd-Warshall
			var bIncluded:ArrayCollection = new ArrayCollection();
			for (i = 0; i < extents.length; ++i)
			{
				bIncluded.addItem(new Array());
				for (j = 0; j < extents.length; ++j)
                {
                	var ein: Array = getIntersection(extents[i], extents[j]);
                	
                	// i is included in j, strict/proper inclusion
                	bIncluded[i].push(((ein.length == extents[i].length) && (ein.length != extents[j].length)) ? true : false);
                }	
			}

			// Floyd-Warshall
			for (k = 0; k < bIncluded.length; ++k)
            {
                for (i = 0; i < bIncluded.length; ++i)
                {
                    for (j = 0; j < bIncluded.length; ++j)
                    {
                        if (bIncluded[i][j] == true)
                        {
                            if ((bIncluded[i][k] == true) && (bIncluded[k][j] == true))
                            {
                                bIncluded[i][j] = false;
                            }
                        }
                    }
                }
            }        
                
			// connect concepts
			var iLinks: int = 0;
			for (i = 0; i < bIncluded.length; ++i)
			{
				for (j = 0; j < bIncluded.length; ++j)
				{
					if (bIncluded[i][j] == true)
					{
						g.link(g.find(j.toString()), g.find(i.toString()), j.toString());
						++iLinks;
					}	
				}
			}
								
			trace("Done with " + concepts.length + " and with " + iLinks + " edges.");	
			return g;
		}
		
	}
}