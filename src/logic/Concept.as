package logic
{
	import mx.utils.StringUtil;
	
	public class Concept
	{
		private var _objects:Array;
		private var _attributes:Array;
		
		private var _lineOfObjects:String;
		private var _lineOfAttributes:String;
		
		public function Concept(objects:Array, attributes:Array, lineOfObjects:String = null, lineOfAttributes:String = null)
		{
			_objects = objects;
			_attributes = attributes;
			_lineOfObjects = lineOfObjects;
			_lineOfAttributes = lineOfAttributes;
		}
		
		public function get attributes(): Array
		{
			if (_lineOfAttributes != null)
			{
				var conceptAttributes:Array = StringUtil.trim(_lineOfAttributes).split(",");
				if (conceptAttributes[0] == "")
				{
					conceptAttributes = new Array();
				}
				return conceptAttributes;
			}
			return _attributes;
		}

		public function get objects(): Array
		{
			if (_lineOfObjects != null)
			{
				var conceptObjects:Array = StringUtil.trim(_lineOfObjects).split(",");
				if (conceptObjects[0] == "")
				{
					conceptObjects = new Array();
				}
				return conceptObjects;
			}
			return _objects;
		}
	}
}