1.  Background

GUI Layout Toolbox provides tools to create sophisticated MATLAB graphical 
user interfaces that resize gracefully.  The classes supplied can be used 
in combination to produce virtually any user interface layout.

* Arrange MATLAB user-interface components horizontally, vertically or in 
  grids
* Mix fixed size and variable size elements
* Resize elements by dragging dividers
* Use panels and tabs for switching interface pages

GUI Layout Toolbox version 2.x provides support for Graphics version 2, the 
upcoming MATLAB graphics system.

The current version is 2.0.1.  This is a beta version that is feature 
complete but may contain bugs and performance issues.

The developers expect to continue to provide bug fixes for GUI Layout 
Toolbox version 1.

2.  Abbreviations

* HG1: Graphics version 1, the legacy MATLAB graphics system
* HG2: Graphics version 2, the upcoming MATLAB graphics system
* GLT1: GUI Layout Toolbox version 1, supporting HG1
* GLT2: GUI Layout Toolbox version 2, supporting HG2

3.  Installation

GLT2 supports MATLAB R2013b onwards with HG2.  To start MATLAB with HG2, 
use the command line switch -hgVersion 2.

GLT2 can be installed by running its 'install' function.  To verify correct 
installation, type 'ver layout' at the MATLAB command line, and check for 
the GLT2 entry.

GLT1 and GLT2 should not be used simultaneously.  GLT1 can be uninstalled 
by running its 'uninstall' function.

4.  Changes in version 2, including incompatibilities

4.1  Package name

GLT1 packages were contained in the package 'uiextras'.  GLT2 classes are 
contained in the package 'uix'.  In GLT2, a package 'uiextras' is included 
to provide support for legacy code.  Classes in 'uiextras' extend 
corresponding classes in 'uix', and contain only compatibility-related 
code.

4.2  Contents property

The contents of GLT1 objects were accessible via the property 'Children'.  
The contents of GLT2 objects are accessible via the property 'Contents'.  
GLT2 objects also provide a property 'Children', but this controls the 
vertical stacking order of contents, rather than the layout order.  Legacy 
code that accesses 'Children' will run without error, but will not achieve 
the desired change in layout order, and should be modified to access 
'Contents' instead.

An upcoming release of GLT1 will include support for code that references 
contents via 'Contents'.  That way, code modified to work in GLT2 will also 
work in GLT1.

The background to this change is as follows.  GLT1 objects were wrappers 
for built-in graphics objects, and presented contents in layout order via 
the property 'Children'.  GLT2 objects extend built-in graphics objects, 
and as such, inherit properties, methods and events.  One such property is 
'Children' which is used to control the top-to-bottom stacking order.  
MATLAB stacking rules, e.g., controls are always on top of axes, mean that 
some reasonable layout orders may be invalid stacking orders, so a new 
property for layout order is required.

4.3  Auto-parenting

HG2 introduces unparented objects, i.e., those with property 'Parent' 
empty.  HG2 also introduces a separation between class constructors, e.g., 
matlab.ui.container.Panel, and construction functions, e.g., uipanel.  
These behaviors are related in that construction functions are auto-
parenting, i.e., if 'Parent' is not specified then it is set to gcf, 
whereas class constructors return objects with 'Parent' empty by default.  
GLT2 has adopted the HG2 pattern, with an HG2-like naming convention, e.g., 
class constructor uix.Grid and construction function uixgrid.

Classes in 'uiextras' are auto-parenting so the behavior of legacy code is 
unchanged.  However, best practice is to specify parent explicitly during 
construction.

4.4  Defaults mechanism

GLT1 provided a defaults mechanism -- 'get'/'set'/'unset' in 'uiextras' -- 
that mimicked HG1 'get' and 'set'.  This feature has been removed from 
GLT2.  Users should use an alternative programming pattern, e.g. factory 
function, to create objects with standard settings.

4.5  Enable and disable

GLT1 provided a mechanism to enable and disable container contents using 
the property 'Enable'.  This feature has been removed from GLT2.  Users 
should enable and disable controls directly.

4.6  Other property name changes

A number of property names have changed to achieve greater consistency 
across the package.  For example, 'RowSizes' and 'ColumnSizes' in 
uiextras.Grid are now 'Heights' and 'Widths' in uix.Grid.  The package 
'uiextras' provides support for legacy property names.

4.7  Property shape changes

GLT2 contents companion properties are now of the same size as 'Contents', 
i.e., column vectors.  In GLT1, these properties were row vectors.  The 
package 'uiextras' provides support for legacy property values.

4.8  Documentation

GLT2 documentation is in preparation.  GLT1 documentation is largely valid, 
apart from exceptions listed above.

5.  Release history

2.0.1  Initial beta version (16 November 2013)

6.  Feedback

* Email: david.sampson@mathworks.co.uk
* Gecko: Component "Consulting Projects", subcomponent "GUI Layout Toolbox"
