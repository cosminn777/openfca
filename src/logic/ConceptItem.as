package logic
{
	import com.adobe.flex.extras.controls.springgraph.Item;

	public class ConceptItem extends Item
	{
		[Bindable]
		public var attributes:String;

		[Bindable]
		public var objects:String;

		public function ConceptItem(id:String, attributes:String, objects:String)
		{
			super(id);
			this.attributes = attributes;
			this.objects = objects;
		}
		
	}
}