using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace libconexplore
{
    class NaiveComparer : IEqualityComparer<HashSet<int>>
    {

        #region IEqualityComparer<HashSet<int>> Members

        public bool Equals(HashSet<int> x, HashSet<int> y)
        {
            if (x.Count != y.Count)
            {
                return false;
            }

            return ((x.IsSubsetOf(y)) && (x.IsSupersetOf(y)));
        }

        public int GetHashCode(HashSet<int> obj)
        {
            int iHash = 0;
            foreach (int iObj in obj)
            {
                iHash += iObj;
            }
            return iHash;
        }

        #endregion
    }
}
