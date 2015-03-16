# Usage Guide #

In order to use Conflexplore, you can either load it using the link from the Project Home, or you can download the latest build and run it locally on your machine (you'll need Flash version 10) or from your web server.
The minimum recommended resolution for visualization is: 1280 horizontal pixels x any number of vertical pixels (could be 1280x800, 1280x1024, 1920x1080, etc.).

### File open / save ###
  * You may open or save .con files (some examples are provided in the data/ sub directory of the distribution) using the _Open_ and _Save_ buttons.
  * Files that have more than 100 objects are not loaded into the context grid. Only the lattice viewer is displayed.

### Context creation ###
  * The context configuration can be specified as comma-separated attribute names and object names. You may choose from an existing set of existing configurations, by clicking on a configuration button, such as _Numbers_ or _Triangles_. Click _Create Context_ after editing the attribute and object names.
  * You may also choose from an existing set of complete contexts.

### Context Grid ###
  * You can edit the context by clicking on the check boxes. Attributes and objects can be added or popped out of the context by clicking the corresponding buttons above the context grid.
  * Click _Begin Attribute Exploration_ to start attribute exploration. If a new counter example is found, you may continue the exploration by clicking _Continue Attribute Exploration_.
  * You can view the implications for the current context by clicking _View Implications_.

### Lattice view ###
  * In the application control bar on top, click _View Lattice_ to view the Lattice for the current context.
  * Initially, only the first two levels of the lattice are displayed. In order to increase the depth of the graph, move the _Maximum edge distance_ slider.
  * The default item limit (how many concepts displayed on the screen) can be changed by moving the _Visible concepts limit_.
  * If the focused concept has a large number of neighbors, only a few of them will be displayed (the first ones). In order to view the rest, you have to set the _Skip_ number. If skip is 5, the first 5 neighbors will be discarded, and only the remaining will be shown. By repeatedly increasing the _skip_ value, you can view all neighbors.
  * The _Repulsion_ slider is used for configuring the distance between nodes.
  * _Item width_, _Item height_ and _Font size_ can be used for controlling the appearance of the nodes.