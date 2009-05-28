package events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;

	public class NewContextEvent extends Event
	{
		public var objects:Array;
		public var attributes:Array;
		public var rows:ArrayCollection;

		public function NewContextEvent(type:String, objects:Array = null, attributes:Array = null, rows:ArrayCollection = null)
		{
			super(type);
			this.objects = objects;
			this.attributes = attributes;
			this.rows = rows;
		}
		
	}
}