using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace libconexplore
{
    public class Link
    {
        public Concept Source { get; private set; }
        public Concept Target { get; private set; }

        public Link(Concept cSource, Concept cTarget)
        {
            Source = cSource;
            Target = cTarget;
        }
    }
}
