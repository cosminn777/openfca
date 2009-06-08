package renderers
{
	import com.adobe.flex.extras.controls.springgraph.Graph;
	import com.adobe.flex.extras.controls.springgraph.IEdgeRenderer;
	import com.adobe.flex.extras.controls.springgraph.Item;
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.core.UIComponent;

	public class ConceptEdgeRenderer implements IEdgeRenderer
	{
		public function draw(g:Graphics, fromView:UIComponent, toView:UIComponent, fromX:int, fromY:int, toX:int, toY:int, graph:Graph):Boolean
		{
			var color: uint = 0x8888ff;
			var alpha: Number = 1.0;
			var thickness: int = 1;
			var m:Matrix = new Matrix;
			var center:Point = new Point((fromX + toX)/2, (fromY + toY)/2);
			var pivot:Point = new Point(toX, toY);
			var item1:Item = (fromView as Object).data;
			var item2:Item = (toView as Object).data;
			var fromId:String = graph.getLinkData(item1, item2).toString();
			if (item1.id != fromId) {
				var aux:int = fromX;
				fromX = toX;
				toX = aux;
				aux = fromY;
				fromY = toY;
				toY = aux;
			}
			pivot = pivot.subtract(center);
			pivot.normalize(10.0);
			m.rotate(Math.PI*0.85);
			var arrowPoint1:Point = m.transformPoint(pivot).add(center);
			m.rotate(Math.PI*0.3);
			var arrowPoint2:Point = m.transformPoint(pivot).add(center);

			g.lineStyle(thickness,color,alpha);
			g.beginFill(color);
			g.moveTo(fromX, fromY);
			g.lineTo(toX, toY);
			g.moveTo(center.x, center.y);
			g.lineTo(arrowPoint1.x, arrowPoint1.y);
			g.lineTo(arrowPoint2.x, arrowPoint2.y);
			g.lineTo(center.x, center.y);
			g.endFill();
			return true;
		}
	}
}