package logic
{
	public class Concept
	{
		private var _objects:Array;
		private var _attributes:Array;
		
		public function Concept(objects:Array, attributes:Array)
		{
			_objects = objects;
			_attributes = attributes;
		}
		
		public function get attributes(): Array
		{
			return _attributes;
		}

		public function get objects(): Array
		{
			return _objects;
		}
	}
}