package events
{
	import flash.events.Event;

	public class NewContextEvent extends Event
	{
		public var objects:Array;
		public var attributes:Array;

		public function NewContextEvent(type:String, objects:Array = null, attributes:Array = null)
		{
			super(type);
			this.objects = objects;
			this.attributes = attributes;
		}
		
	}
}