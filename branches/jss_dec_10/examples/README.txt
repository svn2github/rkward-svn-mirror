-- Requirements for this demonstration --
These demonstration files require an existing installation of RKWard 0.5.4 (or later) on your
system. Please refer to http://rkward.sf.net for instructions on the various
methods of installation.

-- Replicating examples and figures from Sections 3, 4, and 5 --
To replicate the examples and figures from Sections 3, 4, and 5 of the article,
source or paste the script 'demo.R' contained in the same directory as this file,
*inside an RKWard session*. Assuming that the rkward binary is in your system's
search path, you can also run
   rkward --evaluate "source ('demo.R')"
from within the directory containing this file.

Note that since most examples/figures are concerned with interactive GUI
elements, the demonstration script runs interactively as well, and will prompt
you to perform certain user actions, which cannot (meaningfully) be scripted.

-- Plugin example from Section 6 --
Section 6 of the article shows how to extend RKWard by a custom plugin. The
required files are included in the sub-directory 'plugin_demo' contained in the
same directory as this file. To activate these, start an RKWard session, and select
Settings->Configure RKWard->Plugins from the menu. Add the file
plugin_demo/demo.pluginmap to the list of .pluginmap files.

Note that the official RKWard distribution already contains a t-test plugin.
