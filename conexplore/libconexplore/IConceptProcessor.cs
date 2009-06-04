using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace libconexplore
{
    public interface IConceptProcessor
    {
        Graph Process(string[] sObjects, string[] sAttributes, bool[][] bValues);
    }
}
