package com.adobe.flex.extras.controls.forcelayout {

public class AbstractEdge implements IEdge {
	
	    public function AbstractEdge(f: Node, t: Node, len: int) {
	        from = f;
	        to = t;
	        length = len;
	    }
	
		// from
	    public var from: Node;
		public function getFrom(): Node {
			return from;
		}
	
		// to
	    public var to: Node;
		public function getTo(): Node {
			return to;
		}
		
		// length
	    public var length: int;
	    public function getLength(): int {
	        return length;
	    }
	}
}