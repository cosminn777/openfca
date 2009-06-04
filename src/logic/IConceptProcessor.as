package logic
{
	import com.adobe.flex.extras.controls.springgraph.Graph;
	
	import mx.collections.ArrayCollection;
	
	public interface IConceptProcessor
	{
		function IConceptProcessor(objects:Array, attributes:Array);
		function computeConcept(data:ArrayCollection): Graph;
		function getConceptList(): Array;
	}
}