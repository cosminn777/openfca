package com.adobe.flex.extras.controls.springgraph
{
	import com.adobe.flex.extras.controls.forcelayout.AbstractEdge;
	
	public class GraphEdge extends AbstractEdge
	{
		public static var traversedMap: Object = new Object();
		
		public function get traversed(): Boolean {
			var fromId: String = GraphNode(getFrom()).item.id;
			var toId: String = GraphNode(getTo()).item.id;
			var key: String = fromId + "--" + toId;
			var result: Boolean = traversedMap.hasOwnProperty(key);
			if(result)
				result = result;
			return result;
		}
		
		public function GraphEdge(f: GraphNode, t: GraphNode, len: int) {
			super(f, t, len);
		}
		
	    public override function getLength(): int {
	    	var result: int = (GraphNode(to).view.width + GraphNode(to).view.height +
	       		GraphNode(from).view.width + GraphNode(from).view.height) / 4;
	       	if(result > 0)
	       		return result;
	       	else
	       		return 50; // !!@
	    }
	}
}