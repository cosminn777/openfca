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
		private function computeLinePoint(x0:int, y0:int, t:UIComponent, x:int, y:int): Point
		{
			var aspect:Number = Number(x0-x)/Number(y0-y);
			var realX: int, realY: int;
			var tx:int = t.x-5;
			var ty:int = t.y-5;
			var w:int = t.width + 10;
			var h:int = t.height + 10;
			
			if ((w / h) > Math.abs(aspect)) {
				if (y > ty+h)
					realY = ty + h;
				else
					realY = ty;
				realX = (realY - y0)*(x-x0)/(y-y0)+x0;
			} else {
				if (x > tx+w)
					realX = tx + w;
				else
					realX = tx;
				realY = (realX - x0)*(y-y0)/(x-x0)+y0;
			}
			return new Point(realX, realY);
		} 
		
		public function draw(g:Graphics, fromView:UIComponent, toView:UIComponent, fromX:int, fromY:int, toX:int, toY:int, graph:Graph):Boolean
		{
			var color: uint = 0x8888ff;
			var alpha: Number = 1.0;
			var thickness: int = 1;
			var item1:Item = (fromView as Object).data;
			var item2:Item = (toView as Object).data;
			var linePoints:Array = [computeLinePoint(fromX, fromY, fromView, toX, toY),
									computeLinePoint(toX, toY, toView, fromX, fromY)];
			
			// check orientation
			var fromId:String = graph.getLinkData(item1, item2).toString();
			if (item1.id != fromId) {
				linePoints.reverse();
			}
			fromX = linePoints[0].x;
			fromY = linePoints[0].y;
			toX = linePoints[1].x;
			toY = linePoints[1].y;
			
			// compute arrow point coordinates
			var m:Matrix = new Matrix;
			//var target:Point = new Point((fromX + toX)/2, (fromY + toY)/2);
			var target:Point = linePoints[1];
			var pivot:Point = new Point(toX, toY);
			pivot = pivot.subtract(linePoints[0]);
			pivot.normalize(10.0);
			m.rotate(Math.PI*0.85);
			var arrowPoint1:Point = m.transformPoint(pivot).add(target);
			m.rotate(Math.PI*0.3);
			var arrowPoint2:Point = m.transformPoint(pivot).add(target);

			// draw line + arrow
			g.lineStyle(thickness,color,alpha);
			g.beginFill(color);
			g.moveTo(fromX, fromY);
			g.lineTo(toX, toY);
			g.moveTo(target.x, target.y);
			g.lineTo(arrowPoint1.x, arrowPoint1.y);
			g.lineTo(arrowPoint2.x, arrowPoint2.y);
			g.lineTo(target.x, target.y);
			g.endFill();
			return true;
		}
	}
}