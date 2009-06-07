package logic
{
	import com.adobe.flex.extras.controls.springgraph.Item;

	public class ConceptItem extends Item
	{
		private var _attributeCount:int;
		private var _objectCount:int;
		private var _attributes:String;
		private var _objects:String;

		private function checkEmpty(a:Array): Array
		{
			if (a[0] == "\r" || a[0] == "") return [];
			else return a;
		}
		
		private function getCount(items:String, itemCount:int): int
		{
			if (items == null)
			{
				return itemCount;
			}
			else
			{
				return checkEmpty(items.split(",")).length;
			}
		}
		
		public function get objectCount(): String
		{
			return "O: " + getCount(_objects, _objectCount);
		}

		public function get attributeCount(): String
		{
			return "A: " + getCount(_attributes, _attributeCount);
		}

		public function ConceptItem(id:String, attributeCount:int, objectCount:int, attributes:String = null, objects:String = null)
		{
			super(id);
			_attributeCount = attributeCount;
			_objectCount = objectCount;
			_objects = objects;
			_attributes = attributes;
		}
		
	}
}