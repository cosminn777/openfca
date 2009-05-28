package logic
{
	import com.adobe.flex.extras.controls.springgraph.Graph;
	
	import mx.collections.ArrayCollection;

	public class NaiveConceptProcessor implements IConceptProcessor
	{
		public function NaiveConceptProcessor()
		{
		}

		public function computeConcept(objects:Array, attributes:Array, data:ArrayCollection):Graph
		{
			
			
			return new Graph();
		}
		
	}
}