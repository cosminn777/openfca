package logic
{
	import com.adobe.flex.extras.controls.springgraph.Graph;
	
	import mx.collections.ArrayCollection;
	
	public interface IConceptProcessor
	{
		function computeConcept(objects:Array, attributes:Array, data:ArrayCollection): Graph;
	}
}