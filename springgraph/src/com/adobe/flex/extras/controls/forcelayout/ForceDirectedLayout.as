/*
 * TouchGraph LLC. Apache-Style Software License
 *
 * Copyright (c) 2001-2002 Alexander Shapiro. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer. 
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:  
 *       "This product includes software developed by 
 *        TouchGraph LLC (http://www.touchgraph.com/)."
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 *
 * 4. The names "TouchGraph" or "TouchGraph LLC" must not be used to endorse 
 *    or promote products derived from this software without prior written 
 *    permission.  For written permission, please contact 
 *    alex@touchgraph.com
 *
 * 5. Products derived from this software may not be called "TouchGraph",
 *    nor may "TouchGraph" appear in their name, without prior written
 *    permission of alex@touchgraph.com.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL TOUCHGRAPH OR ITS CONTRIBUTORS BE 
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * ====================================================================
 *
 */

package com.adobe.flex.extras.controls.forcelayout {

import com.adobe.flex.extras.controls.springgraph.GraphNode;
import com.adobe.flex.extras.controls.springgraph.Roamer;
import com.adobe.flex.extras.controls.springgraph.SpringGraph;

/**  TGLayout is the thread responsible for graph layout.  It updates
  *  the real coordinates of the nodes in the graphEltSet object.
  *  TGPanel sends it resetDamper commands whenever the layout needs
  *  to be adjusted.  After every adjustment cycle, TGLayout triggers
  *  a repaint of the TGPanel.
  *
  * ********************************************************************
  *  This is the heart of the TouchGraph application.  Please provide a
  *  Reference to TouchGraph.com if you are influenced by what you see
  *  below.  Your cooperation will insure that this code remains
  *  opensource.
  * ********************************************************************
  *
  * <p><b>
  *  Parts of this code build upon Sun's Graph Layout example.
  *  http://java.sun.com/applets/jdk/1.1/demo/GraphLayout/Graph.java
  * </b></p>
  *
  * Translated and adapted to Flex/ActionScript 
  * from TouchGraph's original java code
  * by Mark Shepherd, Adobe FlexBuilder Engineering, 2006.
  * 
  * @author   Alexander Shapiro
  * @version  1.21  $Id: TGLayout.java,v 1.20 2002/04/01 05:51:55 x_ander Exp $
  * @private
  */
public class ForceDirectedLayout implements IForEachEdge, IForEachNode, IForEachNodePair /*implements Runnable */ {

    /*private*/public var damper: Number=0.0;      // A low damper value causes the graph to move slowly
    /*private*/public var maxMotion: Number=0;     // Keep an eye on the fastest moving node to see if the graph is stabilizing
    /*private*/public var lastMaxMotion: Number=0;
    /*private*/public var motionRatio: Number = 0; // It's sort of a ratio, equal to lastMaxMotion/maxMotion-1
    /*private*/public var damping: Boolean = true; // When damping is true, the damper value decreases
    /*private*/public var rigidity: Number = 0.25;    // Rigidity has the same effect as the damper, except that it's a constant
                                    // a low rigidity value causes things to go slowly.
                                    // a value that's too high will cause oscillation
    /*private*/public var newRigidity: Number = 0.25;
	/*private*/public var dataProvider: IDataProvider;
    /*private*/public var dragNode: Node = null;
	/*private*/public var maxMotionA: Array;
				private var yScale: Number = 0;
				private var upMovement:Boolean = false;
				private var oldVerticalDistance: Number = 110;
				private var vContraction: Boolean = false;
				private var contractionDistance: Number = 0;
				private var vDistance: Number = 110;

  /** Constructor with a supplied TGPanel <tt>tgp</tt>.
    */
    public function ForceDirectedLayout( dataProvider: IDataProvider/*TGPanel tgp */): void {
    	this.dataProvider = dataProvider;
    }

    public function setRigidity(r: Number): void {
        newRigidity = r;  //update rigidity at the end of the relax() thread
    }

    public function setDragNode(n: Node): void {
        dragNode = n;
    }
	
	public function setDragDirection(d:Boolean): void {
		upMovement=d;
	}

    //relaxEdges is more like tense edges up.  All edges pull nodes closes together;
    private /*synchronized*/ function relaxEdges(): void {
    	
         dataProvider.forAllEdges(this);
    }

/*
    private synchronized void avoidLabels() {
        for (int i = 0 ; i < graphEltSet.nodeNum() ; i++) {
            Node n1 = graphEltSet.nodeAt(i);
            Number dx = 0;
            Number dy = 0;

            for (int j = 0 ; j < graphEltSet.nodeNum() ; j++) {
                if (i == j) {
                    continue; // It's kind of dumb to do things this way. j should go from i+1 to nodeNum.
                }
                Node n2 = graphEltSet.nodeAt(j);
                Number vx = n1.x - n2.x;
                Number vy = n1.y - n2.y;
                Number len = vx * vx + vy * vy; // so it's length squared
                if (len == 0) {
                    dx += Math.random(); // If two nodes are right on top of each other, randomly separate
                    dy += Math.random();
                } else if (len <600*600) { //600, because we don't want deleted nodes to fly too far away
                    dx += vx / len;  // If it was sqrt(len) then a single node surrounded by many others will
                    dy += vy / len;  // always look like a circle.  This might look good at first, but I think
                                     // it makes large graphs look ugly + it contributes to oscillation.  A
                                     // linear function does not fall off fast enough, so you get rough edges
                                     // in the 'force field'

                }
            }
            n1.dx += dx*100*rigidity;  // rigidity makes nodes avoid each other more.
            n1.dy += dy*100*rigidity;  // I was surprised to see that this exactly balances multiplying edge tensions
                                       // by the rigidity, and thus has the effect of slowing the graph down, while
                                       // keeping it looking identical.

        }
    }
*/

    private /*synchronized*/ function avoidLabels(): void {
         dataProvider.forAllNodePairs(this);
    }

    public function startDamper(): void {
        damping = true;
    }

    public function stopDamper(): void {
        damping = false;
        damper = 1.0;     //A value of 1.0 means no damping
    }

    public function resetDamper(): void {  //reset the damper, but don't keep damping.
        damping = true;
        damper = 1.0;
    }

    public function stopMotion(): void {  // stabilize the graph, but do so gently by setting the damper to a low value
        damping = true;//aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
        if (damper>0.3) 
            damper = 0.3;
        else
            damper = 0;
    }

	public static var motionLimit: Number = 0.01;
	
    public function damp(): void {
        if (damping) {
            if(motionRatio<=0.001) {  //This is important.  Only damp when the graph starts to move faster
                                      //When there is noise, you damp roughly half the time. (Which is a lot)
                                      //
                                      //If things are slowing down, then you can let them do so on their own,
                                      //without damping.

                //If max motion<0.2, damp away
                //If by the time the damper has ticked down to 0.9, maxMotion is still>1, damp away
                //We never want the damper to be negative though
                if ((maxMotion<0.2 || (maxMotion>1 && damper<0.9)) && damper > 0.01) damper -= 0.01;
                //If we've slowed down significanly, damp more aggresively (then the line two below)
                else if (maxMotion<0.4 && damper > 0.003) damper -= 0.003;
                //If max motion is pretty high, and we just started damping, then only damp slightly
                else if(damper>0.0001) damper -=0.0001;
            }
        }
        if(maxMotion<motionLimit && damping) {
            damper=0;
        }
    }
	
    private /*synchronized*/ function moveNodes(): void {
        lastMaxMotion = maxMotion;
        maxMotionA = new Array(); /* of Number */;
        maxMotionA[0]=0;

        dataProvider.forAllNodes(this);

        maxMotion=maxMotionA[0];
         if (maxMotion>0) motionRatio = lastMaxMotion/maxMotion-1; //subtract 1 to make a positive value mean that
         else motionRatio = 0;                                     //things are moving faster

        damp();
    }
	
    private /*synchronized*/ function relax(): void {
		//var startTime: int = getTimer();
		//trace("relax...");\
		//-------------------------------------------------
		//vDistance = dataProvider.defaultVerticalRepulsion * dataProvider.verticalRepulsionFactor;
    	//if (vDistance < oldVerticalDistance) {
	    //	contractionDistance = oldVerticalDistance - vDistance;
	    //	vContraction = true;
	    	//upMovement=false;
	    //}
	    //-------------------------------------------------

         
    	dataProvider.forAllNodes(new Refresher());
        for (var i: int=0;i<5;i++) {
			//var startTime: int = getTimer();
			relaxEdges();
 			//var endTime: int = getTimer();
			//trace("relaxEdges: " + String(endTime - startTime) + " ms");
			
			//startTime = getTimer();
			avoidLabels();
			//endTime = getTimer();
			//trace("avoidLabels: " + String(endTime - startTime) + " ms");
			
			//startTime = getTimer();
			moveNodes();
			//endTime = getTimer();
			//trace("avoidLabels: " + String(endTime - startTime) + " ms");
        }
        if(rigidity!=newRigidity) rigidity= newRigidity; //update rigidity
        dataProvider.forAllNodes(new Committer());
 		//var endTime: int = getTimer();
		//trace("relax: " + String(endTime - startTime) + " ms");
		
		 //oldVerticalDistance = vDistance;
         //vContraction = false;
         //-------------------------------------------------
         //oldVerticalDistance = vDistance;
         //vContraction = false;
         //upMovement=true;
         //--------------------------------------------------
	}

	public function tick(): Boolean {
		if (!(damper<0.1 && damping && maxMotion<motionLimit)) {
			//trace("relax " + getTimer());
			
			//setting settings for contraction
	    	vDistance = dataProvider.defaultVerticalRepulsion * dataProvider.verticalRepulsionFactor;
			//var tmp:Boolean=upMovement;
			//if (oldVerticalDistance != vDistance) {
	    	//	SpringGraph(Roamer(this.dataProvider)).scroll(0,oldVerticalDistance - vDistance);
	    	//}
    		if (vDistance < oldVerticalDistance) {
	    		contractionDistance = oldVerticalDistance - vDistance;
	    		oldVerticalDistance = vDistance;
	    		vContraction = true;
	    		//upMovement=false;
	    	} else 
	    	{
	    		oldVerticalDistance = vDistance;
	    		vContraction = false;
	    		//upMovement=false;
	    	}
			
			relax();
			
			//oldVerticalDistance = vDistance;
            //vContraction = tmp;
            //vContraction = false;
            //upMovement=true;
			
			//trace("relax done " + getTimer());
			return true;
		} else {
		   	//trace("don't relax");
		   	return false;
		}
	}
	
	public function tickSecond(): Boolean {
		if (!(damper<0.1 && damping && maxMotion<motionLimit)) {
			//trace("relax " + getTimer());
			
			//setting settings for contraction
			vDistance = dataProvider.defaultVerticalRepulsion * dataProvider.verticalRepulsionFactor;
			//var tmp:Boolean=upMovement;
			//if (oldVerticalDistance != vDistance) {
			//	SpringGraph(Roamer(this.dataProvider)).scroll(0,oldVerticalDistance - vDistance);
			//}
			if (vDistance < oldVerticalDistance) {
				contractionDistance = oldVerticalDistance - vDistance;
				oldVerticalDistance = vDistance;
				vContraction = true;
				upMovement=false;
			} else 
			{
				oldVerticalDistance = vDistance;
				vContraction = false;
				upMovement=false;
			}
			
			//relax();
			
			//oldVerticalDistance = vDistance;
			//vContraction = tmp;
			//vContraction = false;
			//upMovement=true;
			
			//trace("relax done " + getTimer());
			return true;
		} else {
			//trace("don't relax");
			return false;
		}
	}
    
	public function forEachEdge(e: IEdge): void {
	
	    var vx: Number = e.getTo().x - e.getFrom().x;
	    var vy: Number = e.getTo().y - e.getFrom().y;
	    var len: Number = Math.sqrt(vx * vx + vy * vy);
	
	    var dx: Number=vx*rigidity;  //rigidity makes edges tighter
		if(isNaN(dx)) {
			dx = dx;
		}
	    var dy: Number=vy*rigidity;
		if(isNaN(dy)) {
			dy = dy;
		}
	
	    dx /=(e.getLength()*100);
		if(isNaN(dx)) {
			dx = dx;
		}
		var length: int = e.getLength();
		var div: int = length * 100;
	    var ddy: Number = dy;
		dy = dy / div;
	    ddy /=(e.getLength()*100);
		if(isNaN(dy)) {
			dy = dy;
		}
	
	    // Edges pull directly in proportion to the distance between the nodes. This is good,
	    // because we want the edges to be stretchy.  The edges are ideal rubberbands.  They
	    // They don't become springs when they are too short.  That only causes the graph to
	    // oscillate.
	    //puse de mine
	    //var todx:Number = e.getTo().dx - dx*len;
	    //var tody:Number = e.getTo().dy - dy*len;
	    //var fromdx:Number = e.getFrom().dx + dx*len;
	    //var fromdy:Number = e.getFrom().dy + dy*len;
	    //if (e.getTo().justMadeLocal || !e.getFrom().justMadeLocal) { always true, because justMadeLocal is always false
	    e.getTo().dx = e.getTo().dx - dx*len;//--------------
	   // e.getTo().dy = e.getTo().dy - dy*len;//--------------
	    //} else {
	    //    e.getTo().dx = e.getTo().dx - dx*len/10;
	    //    e.getTo().dy = e.getTo().dy - dy*len/10;
	    //}
	    //if (e.getFrom().justMadeLocal || !e.getTo().justMadeLocal) { // ditto
	    //var aux:Number = e.getFrom().dy;
	    //var auxx:Number = e.getFrom().dx;
	    e.getFrom().dx = e.getFrom().dx + dx*len;//------------
	    //e.getFrom().dy = e.getFrom().dy + dy*len;//-------------
	   // var repSum: Number = e.getFrom().repulsion * e.getTo().repulsion/100;//Pentru ca Nodurile sa aiba si forta de atractie!!!!!
	    //var factor: Number = repSum*rigidity;//Pentru ca Nodurile sa aiba si forta de atractie!!!!!
	   	//if (Math.abs(e.getTo().y-e.getFrom().y)>factor) {//Pentru ca Nodurile sa aiba si forta de atractie!!!!!
	   		/*if (e.getTo().dy>e.getFrom().dy) 
	   		if (e.getTo().dy<(e.getTo().dy - dy*len)) {
	       //	n1.dy = n1y;
	       //	n2.dy = n2y;
	       	e.getTo().dy = e.getTo().dy - dy*len;
	       //	e.getFrom().dy = e.getFrom().dy + dy*len;
	       	}
	       	else {
		    e.getTo().dy = e.getTo().dy - dy*len;
	       	//e.getFrom().dy = e.getFrom().dy + dy*len;       		
	       	}*/
	       	//e.getTo().dy = e.getTo().dy - dy*len;//----------------------------Pentru ca Nodurile sa aiba si forta de atractie!!!!!
	       	//e.getFrom().dy = e.getFrom().dy + dy*len;//------------------------Pentru ca Nodurile sa aiba si forta de atractie!!!!!
	       	/*if (e.getFrom().y>e.getTo().y) {
	       	e.getTo().dy = e.getTo().dy - dy*len;
	       	e.getFrom().dy = e.getFrom().dy + dy*len;
	       	} else {
	       	e.getTo().dy = e.getTo().dy - dy*len-1;
	       	e.getFrom().dy = e.getFrom().dy + dy*len;	       		
	       	}*/
	    //}Pentru ca Nodurile sa aiba si forta de atractie!!!!!
	    //if (e.getFrom().dy>e.getTo().dy)
	    //	e.getTo().dy = e.getTo().dy+Math.abs(dy*len);
	    //fromdy=e.getFrom().dy;
	    //tody=e.getTo().dy;
	    //var todx:Number = e.getTo().dx - dx*len;
	    //var tody:Number = e.getTo().dy - dy*len;
	    //var fromdx:Number = e.getFrom().dx + dx*len;
	    //var fromdy:Number = e.getFrom().dy + dy*len;//-------------------
	    var fromId: String = SpringGraph._graph.getLinkData(GraphNode(e.getFrom()).item,GraphNode(e.getTo()).item).toString();//(e.getFrom() as GraphNode).id, (e.getTo() as GraphNode).id).toString();
	    /*if (dragNode!=null) {
	    	if (dragNode.y>yScale) {
	    		upMovement=false;
	    		yScale=dragNode.y;
	   		}
	    	if (dragNode.y<yScale) {
	    		upMovement=true;
	    		yScale=dragNode.y;
	    	}
	    }*/
	    //var fromId:String = SpGraph(GraphNode(e.getFrom()).view).getLinkData(GraphNode(e.getFrom()).item,GraphNode(e.getTo()).item).toString();
		//var vDistance:int = 110;
		//var vDistance:int = e.getFrom().verticalRepulsion;
		//var repSum: Number = e.getFrom().verticalRepulsion * e.getTo().verticalRepulsion/100;
	    //var factor: Number = repSum*rigidity;
	    //var vDistance:int = factor;
	    //var vDistance:int = this.dataProvider.
	    /////////////////////////var vDistance: Number = dataProvider.defaultVerticalRepulsion*dataProvider.verticalRepulsionFactor;
	    //SpringGraph._verticalRepulsionFactor*SpringGraph.defaultVerticalRepulsion;
		//if (Roamer._currentItem.id != fromId) 
		//		view.y = 100;//cat de sus sa fie
	    //if ((e.getTo().y<e.getFrom().y)) {
	    	//e.getTo().dx = todx;
	    	//e.getTo().dy = fromdy;
	    	//e.getFrom().dx = fromdx;
	    	//e.getFrom().dy = tody;
	    //	 e.getTo().y = e.getTo().y+(e.getFrom().y-e.getTo().y);
	    	//e.getFrom().y=e.getFrom().y+(e.getTo().y-e.getFrom().y);
	    //}
	    //if (dragNode == e.getFrom()) {
	    //----------------------------------------alterated
	 /*  if (dragNode!=null) {
	    if ((GraphNode(dragNode).item.id==fromId) && (dragNode == e.getFrom())) {
	    if (((e.getFrom().y+50)>e.getTo().y)&&(GraphNode(e.getFrom()).item.id == fromId)) {
	    	 e.getTo().y=e.getTo().y-(e.getTo().y-e.getFrom().y)+50;
	    } 
	    if ((e.getFrom().y<e.getTo().y+50)&&(GraphNode(e.getFrom()).item.id != fromId)) {
	    	  //e.getTo().y = e.getTo().y + (e.getFrom().y-e.getTo().y)-50;
	    	 e.getFrom().y=e.getFrom().y-(e.getFrom().y-e.getTo().y)+50;//+50;
	    	//e.getFrom().y=e.getFrom().y+(e.getTo().y-e.getFrom().y);
	    }
	    } else {
	    	
	    if (((e.getFrom().y+50)>e.getTo().y)&&(GraphNode(e.getFrom()).item.id == fromId)) {
	    	 e.getFrom().y = e.getFrom().y -(e.getFrom().y-e.getTo().y)-50;
	    	//e.getFrom().y=e.getFrom().y+(e.getTo().y-e.getFrom().y);
	    } //else e.getTo().y = e.getTo().y + (e.getFrom().y-e.getTo().y);
	    if ((e.getFrom().y<e.getTo().y+50)&&(GraphNode(e.getFrom()).item.id != fromId)) {
	    	  e.getTo().y = e.getTo().y + (e.getFrom().y-e.getTo().y)-50;
	    	//e.getFrom().y=e.getFrom().y+(e.getTo().y-e.getFrom().y);
	    }
	    }
	    }else {

	    if (((e.getFrom().y+50)>e.getTo().y)&&(GraphNode(e.getFrom()).item.id == fromId)) {
	    	 e.getFrom().y = e.getFrom().y -(e.getFrom().y-e.getTo().y)-50;
	    	//e.getFrom().y=e.getFrom().y+(e.getTo().y-e.getFrom().y);
	    } //else e.getTo().y = e.getTo().y + (e.getFrom().y-e.getTo().y);
	    else
	    if ((e.getFrom().y<e.getTo().y+50)&&(GraphNode(e.getFrom()).item.id != fromId)) {
	    	  e.getTo().y = e.getTo().y + (e.getFrom().y-e.getTo().y)-50;
	    	//e.getFrom().y=e.getFrom().y+(e.getTo().y-e.getFrom().y);
	    }*/
	    //if (e.getTo().y % vDistance > 5 && (Math.abs(e.getFrom().y - e.getTo().y)) > vDistance)
	    //	e.getTo().y = e.getTo().y - (e.getTo().y % vDistance);
	    //see if you drag a node up or down ... the mode positioning is different (hierarchy)
	    /*if (dragNode!=null) {
	    	if (dragNode.y>yScale) {
	    		upMovement=false;
	    		yScale=dragNode.y;
	   		}
	    	if (dragNode.y<yScale) {
	    		upMovement=true;
	    		yScale=dragNode.y;
	    	}
	   	}*/
		
		//if (dragStartY!=0 || dragEndY!=0) {

		//}
	   	 //	if (vContraction == true)
	   	 //		upMovement=false;
	    //---------------------------------------------------------------AAAAAAAAAAAAAAAAAAAAAA :)
	    //put nodes in a hierarchy
	    	    //create the new nodes in concordance to parent node //LOWER NODES
	   if ((GraphNode(e.getFrom()).item.id == fromId) && (e.getTo().seted==false)) {
	    	e.getTo().y = e.getFrom().y + vDistance;
	    	//e.getTo().x = e.getFrom().x - 20;
	    	e.getTo().seted = true;
	    } else 
	    if ((GraphNode(e.getFrom()).item.id != fromId) && (e.getFrom().seted==false)) {
	    	e.getFrom().y = e.getTo().y + vDistance;
	    	//e.getFrom().x = e.getTo().x - 20;
	    	e.getFrom().seted = true;
	    }
	    //create the new nodes in concordance to parent node //UPPER NODES
	    if ((GraphNode(e.getFrom()).item.id == fromId) && (e.getFrom().seted==false)) {
	    	//var ii:Number=e.getTo().y;
	    	e.getFrom().y = e.getTo().y - vDistance;
	    	//e.getTo().x = e.getFrom().x - 20;
	    	e.getFrom().seted = true;
	    } else 
	    if ((GraphNode(e.getFrom()).item.id != fromId) && (e.getTo().seted==false)) {
	    	e.getTo().y = e.getFrom().y - vDistance;
	    	//e.getFrom().x = e.getTo().x - 20;
	    	e.getTo().seted = true;
	    }
		//--------------------------------------------------------------------------------//I divide to 12 for a smooth positioning
		if (GraphNode(e.getFrom()).item.id == fromId) { //&& dragNode!=null) {
	    	if ((e.getFrom().y+vDistance)>e.getTo().y) {
	    		 if (upMovement==false) 
	    		  	e.getTo().y=e.getTo().y+(-(e.getTo().y-e.getFrom().y)+vDistance)/12;//pentru radacina sa coboare frunzele
	    		 if (upMovement==true) 
	    		  	e.getFrom().y = e.getFrom().y +(-(e.getFrom().y-e.getTo().y)-vDistance)/12;//pentru frunze sa ridice radacina
	    	} //else positioningComplete=(e.getFrom().y+vDistance)>e.getTo().y-5;
	    } 
	    else
	    	if (e.getFrom().y<(e.getTo().y+vDistance)) {
	    		  if (upMovement==false) 
	    		  	e.getFrom().y=e.getFrom().y+(-(e.getFrom().y-e.getTo().y)+vDistance)/12;//pentru radacina sa coboare frunzele
	    		  if (upMovement==true) 
	    		  	e.getTo().y = e.getTo().y +(- (e.getTo().y-e.getFrom().y)-vDistance)/12;//pentru frunze sa ridice radacina
	    	} //else positioningComplete=e.getFrom().y-5<(e.getTo().y+vDistance);
		//----------------------------------------------------------------------------------------
		
		/*if (GraphNode(e.getFrom()).item.id == fromId) { //&& dragNode!=null) {
			//if (e.getTo().y%vDistance==0)
					e.getTo().y=e.getFrom().y+ vDistance;
		} 
		else  {
			//if (e.getFrom().y%vDistance==0)
				e.getFrom().y=e.getTo().y+ vDistance;
		}*/
	    //contracts the nodes
	    var tmp:Number=Math.abs(e.getTo().y-e.getFrom().y);
	    //var tmp2:Number=tmp % vDistance;
	    if ((vContraction == true)) {
	    	if (tmp > vDistance) {
	    		if (GraphNode(e.getFrom()).item.id == fromId)
	    			e.getTo().y=e.getTo().y - contractionDistance; 
	    		else e.getFrom().y=e.getFrom().y - contractionDistance;
	    	}
	    }
	    //----------------------------------------
	    /*if (vDistance < oldVerticalDistance) {
	    	if (GraphNode(e.getFrom()).item.id == fromId)
	    		e.getTo().y=e.getTo().y-(oldVerticalDistance - vDistance); 
	    	else e.getFrom().y=e.getFrom().y-(oldVerticalDistance - vDistance);
	    	oldVerticalDistance=vDistance;
	    } else oldVerticalDistance=vDistance;*/
//------------------------------------------------------backup 2
/*			if (GraphNode(e.getFrom()).item.id == fromId) { //&& dragNode!=null) {
	    	if ((e.getFrom().y+50)>e.getTo().y)
	    		  e.getTo().y=e.getTo().y-(e.getTo().y-e.getFrom().y)+50;//pentru radacina sa coboare frunzele
	    		  //e.getFrom().y = e.getFrom().y -(e.getFrom().y-e.getTo().y)-50;//pentru frunze sa ridice radacina
	    } 
	    else
	    	if (e.getFrom().y<e.getTo().y+50) 
	    		  e.getFrom().y=e.getFrom().y-(e.getFrom().y-e.getTo().y)+50;//pentru radacina sa coboare frunzele
	    		  //e.getTo().y = e.getTo().y - (e.getTo().y-e.getFrom().y)-50;//pentru frunze sa ridice radacina
	    */

	    //--------------------------------------------------backup to previous
	    /*
	    	    if (dragNode == e.getFrom()) {
	    if (((e.getFrom().y+50)>e.getTo().y)&&(GraphNode(e.getFrom()).item.id == fromId)) {
	    	 e.getTo().y=e.getTo().y-(e.getTo().y-e.getFrom().y)+50;
	    } 
	    if ((e.getFrom().y<e.getTo().y+50)&&(GraphNode(e.getFrom()).item.id != fromId)) {
	    	  //e.getTo().y = e.getTo().y + (e.getFrom().y-e.getTo().y)-50;
	    	 e.getFrom().y=e.getFrom().y-(e.getFrom().y-e.getTo().y)+50;//+50;
	    	//e.getFrom().y=e.getFrom().y+(e.getTo().y-e.getFrom().y);
	    }
	    } else
		{
	    if (((e.getFrom().y+50)>e.getTo().y)&&(GraphNode(e.getFrom()).item.id == fromId)) {
	    	 e.getFrom().y = e.getFrom().y -(e.getFrom().y-e.getTo().y)-50;
	    	//e.getFrom().y=e.getFrom().y+(e.getTo().y-e.getFrom().y);
	    } //else e.getTo().y = e.getTo().y + (e.getFrom().y-e.getTo().y);
	    if ((e.getFrom().y<e.getTo().y+50)&&(GraphNode(e.getFrom()).item.id != fromId)) {
	    	  e.getTo().y = e.getTo().y + (e.getFrom().y-e.getTo().y)-50;
	    	//e.getFrom().y=e.getFrom().y+(e.getTo().y-e.getFrom().y);
	    }
	    }
*/
//end of backup
	    //else {
	    	//e.getTo().dx = todx;
	    	//e.getFrom().dx = fromdx;
	    //}
	    //---------------------------
	    //if (e.getTo().dy<e.getFrom().dy) {
	    //    e.getTo().dy = e.getTo().dy - 10;
	    //    e.getFrom().dy = e.getFrom().dy-aux;
	        //e.getFrom().dy = e.getFrom().dy+5;
	       // e.getFrom().dy = 200;
	        //e.getFrom().dy=e.getFrom().dy+10;
	    //}
	  /*  if (e.getFrom().dy>e.getTo().dy) {
	        e.getTo().dy = e.getTo().dy - 1;
	    //}
	    //e.getFrom().dy=aux;
	    //e.getFrom().dx=auxx;
	    } else {
	        //e.getFrom().dx = e.getFrom().dx + dx*len/10;
	        //e.getFrom().dy = e.getFrom().dy + dy*len/10;
	    }*/
	}

	 public function forEachNode(n: Node): void {
	    var dx: Number = n.dx;
	    var dy: Number = n.dy;
	    dx*=damper;  //The damper slows things down.  It cuts down jiggling at the last moment, and optimizes
	    dy*=damper;  //layout.  As an experiment, get rid of the damper in these lines, and make a
	                 //long straight line of nodes.  It wiggles too much and doesn't straighten out.

	    n.dx = dx/2;   //Slow down, but dont stop.  Nodes in motion store momentum.  This helps when the force
	    n.dy = dy/2;   //on a node is very low, but you still want to get optimal layout.
	
	    var distMoved: Number = Math.sqrt(dx*dx+dy*dy); //how far did the node actually move?
	
	     if (!n.fixed && !(n==dragNode) ) {
	    	
	     	//var upNodeX: Number = IEdge(this).getFrom().x;
	     	//var upNodeY: Number = IEdge(this).getFrom().y;
	    	//var vy: Number = e.getTo().y - e.getFrom().y;
			//var edges: Array = this.dataProvider.dataProvider.getEdges();
			//for each (var edge: GraphEdge in edges) {
			//	var fromNode: GraphNode = GraphNode(edge.getFrom());
			//	var toNode: GraphNode = GraphNode(edge.getTo());
			//	var color: int = ((fromNode.item == distinguishedItem) || (toNode.item == distinguishedItem))
			//		? distinguishedLineColor : _lineColor;
			//	drawEdge(fromNode.view, toNode.view, color);
			//}
	     	//actual coordinates positioning !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	        n.x = n.x + Math.max(-30, Math.min(30, dx)); //don't move faster then 30 units at a time.
	        n.y = n.y + Math.max(-30, Math.min(30, dy)); //I forget when this is important.  Stopping severed nodes from
	                                            //flying away?
	        //if (n==dragNode) {
	        //	n.x=dx;
	        //}
	     }
	     maxMotionA[0]=Math.max(distMoved,maxMotionA[0]);
	}
	
	public function forEachNodePair(n2: Node, n1: Node): void { //face sa se departeze
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		//trace(Object(n1).item.id + "," + String(n1.x) + "," + String(n1.y) + " ... " + Object(n2).item.id + "," + String(n2.x) + "," + String(n2.y));
	    var dx: Number=0;
	    var dy: Number=0;
	    var vx: Number = n1.x - n2.x;
	    var vy: Number = n1.y - n2.y;
	    var len: Number = vx * vx + vy * vy; //so it's length squared
	    if (len == 0) {
	        dx = Math.random(); //If two nodes are right on top of each other, randomly separate
	        dy = Math.random();
	    } else if (len < 360000) { //600*600, because we don't want deleted nodes to fly too far away
	        dx = vx / len;  // If it was sqrt(len) then a single node surrounded by many others will
	        dy = vy / len;  // always look like a circle.  This might look good at first, but I think
	                        // it makes large graphs look ugly + it contributes to oscillation.  A
	                        // linear function does not fall off fast enough, so you get rough edges
	                        // in the 'force field'
	    }
	   /* var neighborsN1: Object = SpringGraph._graph.neighbors(GraphNode(n1).item.id);
	    var neighborsN2: Object = SpringGraph._graph.neighbors(GraphNode(n2).item.id);
	    var auxBol:Boolean = false;
	    for (var i: String in neighborsN1) { 
			for (var j: String in neighborsN2) { 
				if (i==j) {
					var fromId: String = SpringGraph._graph.getLinkData(SpringGraph._graph.find(i), GraphNode(n1).item).toString();
					var fromIdSecond: String = SpringGraph._graph.getLinkData(SpringGraph._graph.find(j), GraphNode(n2).item).toString();
					if (fromId==fromIdSecond) auxBol = true;
					//auxBol = true;
				} 
			}
		}*/
	    //if (GraphNode(n2).item.id == fromId)
	    if ((n1.y < n2.y+Roamer._nodeHeight) && (n1.y>n2.y-Roamer._nodeHeight)) { //&& (auxBol == true)) {
	
	    var repSum: Number = n1.repulsion * n2.repulsion/100;
	    var factor: Number = repSum*rigidity;
	
	    //if(n1.justMadeLocal || !n2.justMadeLocal) { always true, because justMadeLocal is always false
	        n1.dx += dx*factor;
	        //var a1:int = n1.dx + dx*factor;
	        //n1.dy += dy*factor;
	    //}
	    //else {
	    //    n1.dx = n1.dx + dx*repSum*rigidity/10;
	    //    n1.dy = n1.dy + dy*repSum*rigidity/10;
	    //}
	    //if (n2.justMadeLocal || !n1.justMadeLocal) { always true, because justMadeLocal is always false
	       n2.dx -= dx*factor;
	       //var a2:int = n2.dx - dx*factor;
	       /*if (Math.abs(n1.x - n2.x) < 30) {
	       		if (n1.x > n2.x)
	       			n2.x=n2.x+1;
	       		else n1.x=n1.x-1;
	       }*/
	     }
	        //n2.dy -= dy*factor;
	       //var n1y:Number = n1.y;
	       //var n2y:Number = n2.y;
	       //face nodurile mai apropiate de 100 sa se departeze
	       	//var fromId:String = SpringGraph._graph.getLinkData(Item(n1), Item(n2)).toString();
			//if (Item.(n1).id == fromId && n1.y > n2.y) { 
			//n2.y=n2.y+100
			// }
			//	view.y = 100;//cat de sus sa fie
			//pentru construirea pe nivele se comenteaza ca este inauntrul isului:
			
			
			
	       /*if (Math.abs(n1.y-n2.y)<factor) {//DECOMENTARE PT REPULSIE PE SI PE X I PE Y
	       //	n1.dy = n1y;
	       //	n2.dy = n2y;
	       	n1.dy += dy*factor;//pentru separarea de pe nivele
	       	n2.dy -= dy*factor;//akininarea acestor linii duce la crearea unei latici pe nivele
	       }*/
	       
	       
	       
	      /* var n1x:Number = n1.dx + dx*factor;
	       var n1y:Number = n1.dy + dy*factor;
	       var n2x:Number = n2.dx - dx*factor;
	       var n2y:Number = n2.dy - dy*factor;
	       if (n2y<n1y) {
	       	n1.dx = n1x;
	       	n1.dy = n2y;
	       	n2.dx = n2x;
	       	n2.dy = n1y;
	       	
	       } else {
	        n1.dx = n1x;
	       	n1.dy = n1y;
	       	n2.dx = n2x;
	       	n2.dy = n2y;
	       }*/
	       
	    //}
	    //else {
	    //    n2.dx = n2.dx - dx*repSum*rigidity/10;
	    //    n2.dy = n2.dy - dy*repSum*rigidity/10;
	    //}
	}
	}
}

import com.adobe.flex.extras.controls.forcelayout.IForEachNode;
import com.adobe.flex.extras.controls.forcelayout.Node;

class Refresher implements IForEachNode {
	 public function forEachNode( n: Node ): void {
	 	n.refresh();
	 }
}

class Committer implements IForEachNode {
	 public function forEachNode( n: Node ): void {
	 	n.commit();
	 }
}
