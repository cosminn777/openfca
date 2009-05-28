package controls
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	
	import mx.controls.CheckBox;
	
	public class CenteredCheckBox extends CheckBox
	{
		public function CenteredCheckBox()
		{
			super();
		}
	
		/**
		 *  center the contentHolder
		 */
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
	
			var n:int = numChildren;
			for (var i:int = 0; i < n; i++)
			{
				var c:DisplayObject = getChildAt(i);
				if (!(c is TextField))
				{
					c.x = (w - c.width) / 2;
					c.y = 0;
				}
			}
		}
	}
}
