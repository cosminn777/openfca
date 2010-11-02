package com.adobe.flex.extras.controls.forcelayout {

public interface IDataProvider {
	function forAllNodes(fen: IForEachNode): void;
	function forAllEdges(fee: IForEachEdge): void;
	function forAllNodePairs(fenp: IForEachNodePair): void;
	function get verticalRepulsionFactor(): Number;
	function get defaultVerticalRepulsion(): Number;
	}
}