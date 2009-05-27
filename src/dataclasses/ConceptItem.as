package dataclasses
{
	import com.adobe.flex.extras.controls.springgraph.Item;

	public class ConceptItem extends Item
	{
		[Bindable]
		public var attributes:String;

		[Bindable]
		public var objects:String;

		public function ConceptItem(id:String, attributes:Array, objects:Array, extraRepulsion: Number = 1.0)
		{
			super(id);
			this.attributes = "{" + attributes.join(", ") + "}";
			this.objects = "[" + objects.join(", ") + "]";
		}
		
	}
}