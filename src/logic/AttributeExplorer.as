package logic
{
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
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
		
		public function getExtent(A:Array, data: ArrayCollection): Array
		{
			var B: Array = new Array();
			var i: int = 0;
			var j: int = 0;
			for (i = 0; i < data.length; ++i)
			{
				var isOk: Boolean = true;
				for (j = 0; j < A.length; ++j)
				{
					if (A[j] == true)
					{
						if (!data[i][j])
						{
							isOk = false;
						}
					}
				}
				B.push((isOk) ? true : false); // simplify, add isOk directly
			}
			
			return B;	
		}
		
		public function getIntent(B:Array, data: ArrayCollection): Array
		{
			var A: Array = new Array();
			var i: int = 0;
			var j: int = 0;
			if (data.length > 0)
			{
				for (j = 0; j < data[0].length; ++j)
				{
					var isOk: Boolean = true;
					for (i = 0; i < B.length; ++i)
					{
						if (B[i] == true)
						{
							if (!data[i][j])
							{
								isOk = false;
							}
						}
					}
					A.push((isOk) ? true : false); // simplify
				}
			}
			else // has no objects
			{
				for (i = 0; i < B.length; ++i)
				{
					A.push(true);
				}
			}
			return A;
		}
		
		public function getAttrSetAsString(A: Array, attributes:Array): String
		{
			var s:String = "";
			var i: int = 0;
			for (i = 0; i < A.length; ++i)
			{
				if (A[i] == true)
				{
					s += "<b>" + attributes[i] + "</b>; "; 
				}
			}
			if (s == "")
			{
				s = "<i>no</i> ";
			}
			return s;
		}
		
		public function NextClosure(A: Array, objects: Array, attributes: Array, data: ArrayCollection): Array
		{
				var i: int = attributes.length;
				var success: Boolean = false;
				do
				{
					i = i - 1;
					if (A[i] == false)
					{
						A[i] = true;
						var B: Array = getIntent(getExtent(A, data), data);
						var j: int = 0;
						for (j = 0; j < B.length; ++j)
						{
							if ((B[j] == true) && (A[j] == false))
							{
								break;
							}
						}
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