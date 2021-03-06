package renderers {
	
	import flash.events.*;
	
	import mx.containers.Panel;
	import mx.core.ScrollPolicy;
	import mx.core.FlexGlobals;
	import mx.effects.AnimateProperty;
	import mx.events.*;
		
	/**
	 * The icon designating a "closed" state
	 */
	[Style(name="closedIcon", property="closedIcon", type="Object")]
	
	/**
	 * The icon designating an "open" state
	 */
	[Style(name="openIcon", property="openIcon", type="Object")]
	
	/**
	 * This is a Panel that can be collapsed and expanded by clicking on the header.
	 *
	 * @author Ali Rantakari
	 */
	public class CustomCollapsiblePanel extends Panel {
		
		private var _creationComplete:Boolean = false;
		private var _open:Boolean = true;
		private var _openAnim:AnimateProperty;
				
		/**
		 * Constructor
		 *
		 */
		public function CustomCollapsiblePanel(aOpen:Boolean = true):void
		{
			super();
			open = aOpen;
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		// BEGIN: event handlers                ------------------------------------------------------------
		private function creationCompleteHandler(event:FlexEvent):void
		{
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			this.verticalScrollPolicy = ScrollPolicy.OFF;	
			_openAnim = new AnimateProperty(this);
			_openAnim.duration = 300;
			_openAnim.property = "height";
			titleBar.addEventListener(MouseEvent.CLICK, headerClickHandler);
			_creationComplete = true;
			//this.addEventListener(MouseEvent.MOUSE_OVER, doOpen);
			//super.addEventListener(MouseEvent.MOUSE_OUT, doClose);
			//FlexGlobals.topLevelApplication.getChildByName("ccp").addEventListener(MouseEvent.MOUSE_OUT, resizeOutHandler);
			//this.titleBar.buttonMode = true;
			//this.titleBar.useHandCursor=true;
		}
		
		public function doOpen():void {
			if (_creationComplete && !_openAnim.isPlaying) {
				
				_openAnim.fromValue = _openAnim.target.height;
				if (!_open) {
					_openAnim.toValue = openHeight;
					_open = true;
					dispatchEvent(new Event(Event.OPEN));
				}
				setTitleIcon();
				_openAnim.play();
				//this.parent.addEventListener(MouseEvent.MOUSE_OUT, resizeOutHandler);
				
			}
		}
		
		public function doClose():void {
			if (_creationComplete && !_openAnim.isPlaying) {
				
				_openAnim.fromValue = _openAnim.target.height;
				if (_open) {
					_openAnim.toValue = _openAnim.target.closedHeight;
					_open = false;
					dispatchEvent(new Event(Event.CLOSE));
				}
				setTitleIcon();
				_openAnim.play();
				
			}
		}
			
		private function headerClickHandler(event:MouseEvent):void { toggleOpen(); }
		
		private function callUpdateOpenOnCreationComplete(event:FlexEvent):void { updateOpen(); }
		
		// --end--: event handlers          - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		
		// BEGIN: private methods               ------------------------------------------------------------
		// sets the height of the component without animation, based
		// on the _open variable
		private function updateOpen():void
		{
			if (!_open) height = closedHeight;
			else height = openHeight;
			setTitleIcon();
		}
		
		// the height that the component should be when open
		private function get openHeight():Number {
			return measuredHeight;
		}
		
		// the height that the component should be when closed
		private function get closedHeight():Number {
			var hh:Number = getStyle("headerHeight");
			if (hh <= 0 || isNaN(hh)) hh = titleBar.height;
			return hh;
		}
		
		// sets the correct title icon
		private function setTitleIcon():void
		{
			if (!_open) this.titleIcon = getStyle("closedIcon");
			else this.titleIcon = getStyle("openIcon");
		}
		
		// --end--: private methods         - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		
		// BEGIN: public methods                ------------------------------------------------------------
		/**
		 * Collapses / expands this block (with animation)
		 */
		public function toggleOpen():void
		{
			if (_creationComplete && !_openAnim.isPlaying) {
				
				_openAnim.fromValue = _openAnim.target.height;
				if (!_open) {
					_openAnim.toValue = openHeight;
					_open = true;
					dispatchEvent(new Event(Event.OPEN));
				}else{
					_openAnim.toValue = _openAnim.target.closedHeight;
					_open = false;
					dispatchEvent(new Event(Event.CLOSE));
				}
				setTitleIcon();
				_openAnim.play();
				
			}
			
		}

		/**
		 * Whether the block is in a expanded (open) state or not
		 */
		public function get open():Boolean {
			return _open;
		}
		/**
		 * @private
		 */
		public function set open(aValue:Boolean):void {
			_open = aValue;
			if (_creationComplete) updateOpen();
			else this.addEventListener(FlexEvent.CREATION_COMPLETE, callUpdateOpenOnCreationComplete, false, 0, true);
		}

		/**
		 * @private
		 */
		override public function invalidateSize():void {
			super.invalidateSize();
			if (_creationComplete)
				if (_open && !_openAnim.isPlaying) this.height = openHeight;
		}
		// --end--: public methods          - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	}
}