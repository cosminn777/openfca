package logic
{
	import com.adobe.flex.extras.controls.springgraph.Graph;
	import com.adobe.flex.extras.controls.springgraph.Item;
	
	import dataclasses.ConceptItem;
	
	import mx.collections.ArrayCollection;
	
	public class BorkedConceptProcessor implements IConceptProcessor
	{
		private var g: Graph;
		private var prevItem: Item;
		private var itemCount: int;
		
		public function BorkedConceptProcessor()
		{
		}

		public function computeConcept(objects:Array, attributes:Array, data:ArrayCollection): Graph
		{
			g = new Graph();
			itemCount = 0;
			var firstObjects:Array = new Array();
			var endConcepts:Array = new Array();
			for (var index:String in objects) firstObjects.push(index);
			var firstConcept:Object = {obj:firstObjects, attr:[], id:"0", parents:[]};
			var prevConcepts:Array = [firstConcept];
			var allConcepts:Array = prevConcepts.concat();
			var newConcept:Boolean = true;
			newItem(firstConcept, 5.0);
			while (newConcept)
			{
				newConcept=false;
				var newConcepts:Array = new Array();
				for (var conceptIndex:Object in prevConcepts)
				{
					var concept:Object = prevConcepts[conceptIndex];
					var endConcept:Boolean = true;
					for each (var attribute:String in attributes)
					{
						var attr:Array = concept["attr"] as Array;
						if (attr.indexOf(attribute) != -1)
						{
							continue;
						}
						var newObjects:Array = new Array();
						var conceptObjs:Array = (concept["obj"] as Array);
						for each (var o:String in conceptObjs)
						{
							if (data[o][attribute] == true)
							{
								newObjects.push(o);
							}
						}
						if (newObjects.length == 0)
						{
							continue;
						}
						var oldAttrs:Array = (concept["attr"] as Array);
						var newAttr:Array = oldAttrs.concat(attribute);
						for each (var extraAttr:String in attributes)
						{
							if (newAttr.indexOf(extraAttr) != -1)
							{
								continue;
							}
							if (newObjects.every(
									function(o:String, i:int, a:Array): Boolean {
										return data[o][extraAttr] == true;
									}))
								{
									newAttr.push(extraAttr);
								}
						}
						newAttr = newAttr.sort();
						newConcept = true;
						endConcept = false;
						var updateData:Object = {obj:newObjects, 
												 attr:newAttr,
												 parents:[concept["id"]],
												 id:itemCount.toString()};
						newConcepts = updateConcepts(allConcepts, newConcepts, updateData);
					}
					if (endConcept)
					{
						endConcepts.push(concept);
					}
				}
				prevConcepts = newConcepts;
			}
			newItem({obj:[], attr:attributes}, 5.0);
			for each (concept in endConcepts)
			{
				linkItems(concept["id"], (itemCount-1).toString());
			}
			return g;
		}

		private function newItem(concept:Object, extraRepulsion:Number = 1.0): void {
			var item: ConceptItem = new ConceptItem(new Number(itemCount++).toString(),
													concept["attr"],
													concept["obj"], extraRepulsion);
			g.add(item);
			prevItem = item;
		}	
		
		private function linkItems(fromId: String, toId: String): void {
			var fromItem: Item = g.find(fromId);
			var toItem: Item = g.find(toId);
			g.link(fromItem, toItem);
		}		
		
		private function updateConcepts(allConcepts:Array, concepts:Array, data:Object): Array
		{
			var newConcepts:Array = concepts.concat();
			var found:Boolean = false;
			var dataObj:Array = data["obj"] as Array;
			var dataAttr:Array = data["attr"] as Array;
			for each (var c:Object in allConcepts.concat(concepts))
			{
				var attrArr:Array = c["attr"] as Array;
				if (attrArr.length != dataAttr.length)
				{
					continue;
				}
				if (attrArr.every(function (a:String, index:int, arr:Array):Boolean
								  {
									  return a == dataAttr[index];
								  }))
				{
					found = true;
					var newObjects:Object = {};
					for each (var obj:String in (c["obj"] as Array))
					{
						newObjects[obj] = 0;
					}
					for each (obj in dataObj)
					{
						newObjects[obj] = 0;
					}
					var newObjectsArr:Array = new Array();
					for (obj in newObjects)
					{
						newObjectsArr.push(obj);
					}
					c["obj"] = newObjectsArr;
					var id:String = c["id"];
					var oldParents:Array = c["parents"] as Array;
					c["parents"] = oldParents.concat(data["parents"] as Array);
					for each (var parent:String in data["parents"] as Array)
					{
						linkItems(id, parent);
					}
					break;
				}
			}
			if (!found)
			{
				allConcepts.push(data);
				newConcepts.push(data);
				newItem(data);
				linkItems(data["id"], (data["parents"] as Array)[0]);
			}
			
			return newConcepts;
		}
	}
}