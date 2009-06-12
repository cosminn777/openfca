package logic
{
	import mx.collections.ArrayCollection;
	
	public class AttributeExplorer
	{
		public function AttributeExplorer()
		{
			
		}

		public function FirstClosure(objects: Array, attributes: Array): Array
		{
			var A: Array = new Array();
			
			var i: int = 0;
			for (i = 0; i < attributes.length; ++i)
			{
				A.push(0);
			}	
			
			return A;
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
		
		// gets an attribute set
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
		
		public function getAttrSetAsString(A: Array, attributes:Array): String
		{
			var s:String = "";
			var i: int = 0;
			var sA: Array = new Array();
			for (i = 0; i < A.length; ++i)
			{
				sA.push("<b>" + attributes[A[i]] + "</b>"); 
			}
			s = sA.join(", ");
			if (s == "")
			{
				s = "<i>no</i>";
			}
			return s;
		}
		
		public function NextClosure(A: Array, objects: Array, attributes: Array, data: ArrayCollection): Array
		{
				var i: int = attributes.length;
				var success: Boolean = false;
				do
				{
					var j: int = 0;
					i = i - 1;
					if (A[i] == false)
					{
						A[i] = true;
				// begin debug
				//*
				var sTrace: String = "A: ";
				for (j = 0; j < A.length; ++j)
				{
					sTrace += A[j] ? "1" : "0";
				}
				trace(sTrace);
				//*/
						var B: Array = fromAttributeSetToBitSet(getIntent(getExtent(fromBitSetToAttributeSet(A, attributes), objects, data), attributes, data), attributes);
				// begin debug
				//*	
				sTrace = "B: ";
				for (j = 0; j < B.length; ++j)
				{
					sTrace += B[j] ? "1" : "0";
				}
				trace(sTrace);
				//*/	
						for (j = 0; j < B.length; ++j)
						{
							if ((B[j] == true) && (A[j] == false))
							{
								break;
							}
						}
				// debug
				//trace(j + " " + i);
						if (j >= i)
						{
							A = B;
							success = true;
						}
					}
					else
					{
						A[i] = false;
					}
				} while ((success == false) && (i > 0))
				
				return A;
		}
	}
}