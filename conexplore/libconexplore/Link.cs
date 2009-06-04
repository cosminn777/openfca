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

        public int From { get; private set; }
        public int To { get; private set; }

        public Link(Concept cSource, Concept cTarget, int iFrom, int iTo)
        {
            Source = cSource;
            Target = cTarget;
            From = iFrom;
            To = iTo;
        }
    }
}
