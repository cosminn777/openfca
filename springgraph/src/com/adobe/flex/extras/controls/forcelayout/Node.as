package com.adobe.flex.extras.controls.forcelayout {
	
	import com.adobe.flex.extras.controls.springgraph.SpringGraph;
	
public class Node {

		public function Node(): void {}
		public var y: Number = 0;
		public var dy: Number = -80;
		public var repulsion: Number = 0;
		public var seted:Boolean = false;
		//public var verticalRepulsion: Number = 0;
		public var fixed: Boolean = false;
	
		public function refresh(): void {}
		public function commit(): void {}
	
		private var _x: Number = 0;
		public function set x(n: Number): void {
			if(isNaN(n)) {
				n = n;
			}
				
			_x = n;
		}
		public function get x(): Number {
			return _x;
		}
	
		private var _dx: Number = 0;
		public function set dx(n: Number): void {
			if(isNaN(n)) {
				n = n;
			}
				
			_dx = n;
		}
		public function get dx(): Number {
			return _dx;
		}
	}
}