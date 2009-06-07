package logic
{
	import com.adobe.flex.extras.controls.springgraph.Graph;
	
	import mx.collections.ArrayCollection;

	public class AndrewsConceptProcessor implements IConceptProcessor
	{
		public function AndrewsConceptProcessor()
		{
		}

		private var lhsA: ArrayCollection = new ArrayCollection();
        private var lhsB: ArrayCollection = new ArrayCollection();
        
        private var iNewR:int;
        
        private function InClose(iR: int, iY:int, bValues: ArrayCollection):void
        {
            var j:int = 0;

            iNewR = iNewR + 1;
            lhsA.addItem(new Array());
            lhsB.addItem(new Array());

            for (j = iY; j <= bValues[0].length - 1; ++j)
            {
            	lhsA[iNewR].length = 0;
                
				var i:int = 0;
				for (i = 0; i < lhsA[iR].length; ++i)
				{
					if (bValues[lhsA[iR][i]][j])
                    {
                        lhsA[iNewR].push(i);
                    }
				}
                
                if (lhsA[iNewR].length > 0)
                {
                    if (lhsA[iNewR].length == lhsA[iR].length)
                    {
                        lhsB[iR].push(j);
                    }
                    else
                    {
                        if (IsCannonical(iR, j - 1, bValues))
                        {
                            lhsB[iNewR].length = 0;
                            lhsB[iNewR].push(lhsB[iR]);
                            lhsB[iNewR].push(j);
                            InClose(iNewR, j + 1, bValues);
                        }

                    }
                }
            }
        }
        
        private function IsCannonical(iR: int, iY: int, bValues: ArrayCollection): Boolean
        {
            var k:int = 0;
            var j:int = 0;
            var h:int = 0;

            var aB:Array = lhsB[iR];
            var aA:Array = lhsA[iNewR];

            for (k = aB.length - 1; k >= 0; --k)
            {
                for (j = iY; j >= aB[k] + 1; --j)
                {
                    for (h = 0; h <= aA.length - 1; ++h)
                    {
                        if (!bValues[aA[h]][j])
                        {
                            break;
                        }
                    }
                    if (h == aA.length)
                    {
                        return false;
                    }
                }
                iY = aB[k] - 1;
            }

            for (j = iY; j >= 0; --j)
            {
                for (h = 0; h <= aA.length - 1; ++h)
                {
                    if (!bValues[aA[h]][j])
                    {
                        break;
                    }
                }
                if (h == aA.length)
                {
                    return false;
                }
            }

            return true;
        }
        
		public function computeConcept(objects:Array, attributes:Array, data:ArrayCollection):Graph
		{
			var i:int = 0;
			
			var g: Graph = new Graph();
			
            var hsSupremumObjects: Array = new Array();
            var hsSupremumAttributes: Array= new Array();
            
            for (i = 0; i < objects.length; ++i)
            {
                hsSupremumObjects.push(i);
            }

			lhsA.removeAll();
			lhsB.removeAll();
			
            lhsA.addItem(hsSupremumObjects);
            lhsB.addItem(hsSupremumAttributes);

			iNewR = 0;
            InClose(0, 0, data);
            
            return g;
		}
		
	}
}