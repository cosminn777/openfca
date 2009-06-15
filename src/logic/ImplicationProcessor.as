package logic
{
	import mx.collections.ArrayCollection;
	
	public class ImplicationProcessor
	{
		public function ImplicationProcessor()
		{
		}

		// gets an object set
		public function getExtent(A:Array, objects: Array, data: ArrayCollection): Array
		{
			var B: Array = new Array();
			var i: int = 0;
			var j: int = 0;
			for (i = 0; i < objects.length; ++i) // for all objects
			{
				for (j = 0; j < A.length; ++j) // for all attributes
				{
					if (!data[i][A[j]])
					{
						break;
					}
				}
				if (j == A.length)
				{
					B.push(i);
				}
			}

			return B;	
		}
		
		public function fromBitSetToAttributeSet(A: Array, attributes: Array): Array
		{
			var i: int = 0;
			var attrSet: Array = new Array();
			for (i = 0; i < A.length; ++i)
			{
				if (A[i])
				{
					attrSet.push(i);
				}
			}
			
			return attrSet;
		}
		
		public function fromAttributeSetToBitSet(A: Array, attributes: Array): Array
		{
			var i: int = 0;
			var bitSet: Array = new Array();
			for (i = 0; i < attributes.length; ++i)
			{
				bitSet.push(false);
			}
			for (i = 0; i < A.length; ++i)
			{
				bitSet[A[i]] = true;		
			}
			
			return bitSet;
		}
		
		public function getIntent(B:Array, attributes: Array, data: ArrayCollection): Array
		{
			var A: Array = new Array();
			var i: int = 0;
			var j: int = 0;
			for (j = 0; j < attributes.length; ++j) // for all attributes
			{
				for (i = 0; i < B.length; ++i) // for all objects
				{
					if (!data[B[i]][j])
					{
						break;
					}
				}
				if (i == B.length)
				{
					A.push(j);
				}
			}
			
			return A;
		}
		
		// B - A
		public function getBitSetDifference(A: Array, B: Array): Array
		{
			var C: Array = new Array();
			var i: int;
			for (i = 0; i < A.length; ++i)
			{
				if (A[i] == B[i])
				{
					C.push(false);
				}
				else
				{
					C.push(B[i]);
				}
			}
			return C;
		}

		public function getAttrSetAsString(A: Array, attributes:Array): String
		{
			var s:String = "";
			var i: int = 0;
			var sA: Array = new Array();
			for (i = 0; i < A.length; ++i)
			{
				sA.push(attributes[A[i]]); 
			}
			s = sA.join(", ");
			if (s == "")
			{
				s = "no";
			}
			return s;
		}

		public var sPremise: ArrayCollection = new ArrayCollection();
		public var sConclusion: ArrayCollection = new ArrayCollection();
		
		// A is included in X
		private function Included(bsA: Array, bsX: Array): Boolean
		{
			var i: int = 0;
			for (i = 0; i < bsA.length; ++i)
			{
				if (bsA[i])
				{
					if (!bsX[i])
					{
						break;
					}
				}
			}
			return (i == bsA.length);
		}
		
		// A <iPos B
		private function Smaller(bsA: Array, bsB: Array, iPos: int): Boolean
		{
			var i: int = 0;
			for (i = 0; i < bsA.length; ++i)
			{
				if (bsA[i] != bsB[i])
				{
					break;
				}
			}
			if (i < iPos)
			{
				return false;
			}
			// i >= iPos
			return (bsB[i]);
		}
		
		private function Alpha(bsA: Array): Array
		{
			var i: int = 0;
			var bsAlpha: Array = new Array();
			for (i = 0; i < bsA.length; ++i)
			{
				bsAlpha.push(bsA[i]); // copy values
			}
			
			for (i = 0; i < sPremise.length; ++i)
			{
				if (Included(sPremise[i], bsA))
				{
					var j: int = 0;
					for (j = 0; j < sConclusion[i].length; ++j)
					{
						if (sConclusion[i][j])
						{
							bsAlpha[j] = true;
						}
					}
				}
			}
			
			return bsAlpha;
		}
		
		public function FirstClosure(objects: Array, attributes: Array, data: ArrayCollection): Array
		{
			var bsA: Array = new Array();
			
			var i: int = 0;
			for (i = 0; i < attributes.length; ++i)
			{
				bsA.push(false);
			}	
			
			var bsADeriv: Array = fromAttributeSetToBitSet(
							getIntent(
								getExtent(
									fromBitSetToAttributeSet(bsA, attributes), 
								objects, data), 
							attributes, data), 
						attributes);	
						
			sPremise.addItem(bsA);
			sConclusion.addItem(bsADeriv);
						
			return bsA;
		}
		
		public function NextClosure(bsA: Array, objects: Array, attributes: Array, data: ArrayCollection): Array
		{
			var i: int = attributes.length;
			var bsIA: Array = new Array(); // bsA without modifications
			for (i = 0; i < bsA.length; ++i)
			{
				bsIA.push(bsA[i]);
			}
			
			var success: Boolean = false;
			do
			{
				var j: int = 0;
				i = i - 1;
				if (bsA[i] == false)
				{
					bsA[i] = true;
					// bsA is now a valid A . i
					var bsAlpha: Array = Alpha(bsA);
					// bsAlpha is now Alpha(A . i)
					
					if (Smaller(bsIA, bsAlpha, i))
					{
						
						var bsAlphaDeriv: Array = fromAttributeSetToBitSet(
							getIntent(
								getExtent(
									fromBitSetToAttributeSet(bsAlpha, attributes), 
								objects, data), 
							attributes, data), 
						attributes);	
						
						sPremise.addItem(bsAlpha);
						sConclusion.addItem(bsAlphaDeriv);
						
						success = true;
					}
					else
					{
						bsA[i] = false;
					}
				}
				else
				{
					bsA[i] = false;
				}
			} while ((success == false) && (i > 0))
			
			return bsAlpha;
		}
	}
}