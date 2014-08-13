                        === GUI LAYOUT TOOLBOX ===


1.  BACKGROUND

GUI Layout Toolbox provides tools to create sophisticated MATLAB graphical 
user interfaces that resize gracefully.  The classes supplied can be used 
in combination to produce virtually any user interface layout.

* Arrange MATLAB user-interface components horizontally, vertically or in 
  grids
* Mix fixed size and variable size elements
* Resize elements by dragging dividers
* Use panels and tabs for switching interface pages

GUI Layout Toolbox version 2.x provides support for MATLAB Graphics version
2.

The current version is 2.0.5.  This is a beta version that is feature 
complete but may contain bugs and performance issues.

The developers expect to continue to provide bug fixes for GUI Layout 
Toolbox version 1.


2.  ABBREVIATIONS

* HG1: Graphics version 1, the legacy MATLAB graphics system
* HG2: Graphics version 2, the upcoming MATLAB graphics system
* GLT1: GUI Layout Toolbox version 1, supporting HG1
* GLT2: GUI Layout Toolbox version 2, supporting HG2


3.  INSTALLATION

GLT2 can be installed by running its 'install' function.  To verify correct 
installation, type 'ver layout' at the MATLAB command line, and check for 
the GLT2 entry.

GLT1 and GLT2 should not be used simultaneously.  GLT1 can be uninstalled 
by running its 'uninstall' function.


4.  CHANGES IN VERSION 2, INCLUDING INCOMPATIBILITIES

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
should enable and disable controls directly rather than via containers.

See related discussion at: http://goo.gl/j0KmTR

4.6  Other property name changes

A number of property names have changed to achieve greater consistency 
across the package.  For example, 'RowSizes' and 'ColumnSizes' in 
uiextras.Grid are now 'Heights' and 'Widths' in uix.Grid.  The package 
'uiextras' provides support for legacy property names.

4.7  Property shape changes

GLT2 contents companion properties are now of the same size as 'Contents', 
i.e., column vectors.  In GLT1, these properties were row vectors.  The 
package 'uiextras' provides support for legacy property values.

4.8  Tab selection behavior

In GLT1, after adding a tab to a tab panel, the new tab is selected.

In GLT2, the original selection is preserved, except if the tab panel was 
empty, in which case the new tab is selected.  This is consistent with the 
behavior of matlab.ui.container.TabGroup.

4.9  Documentation

GLT2 documentation is in preparation.  GLT1 documentation is largely valid, 
apart from exceptions listed above.

4.10  Warnings

A number of warnings are provided:
* uiextras:Deprecated: Feature will be removed in a future release
* uix:Unimplemented: GLT1 feature not implemented in GLT2
* uix:InvalidState: Internal error handled by workaround

These can be disabled via warning( 'off', id ), where id is the identifier.


5.  RELEASE HISTORY

2.0.6  Minor changes (13 August 2014)
  - Added missing uix.Empty
  - Removed internal class uix.EventSource

2.0.5  Minor changes (3 June 2014)
  - Updated to use new class and event names

2.0.4  Minor changes (18 January 2014)

2.0.3  Minor changes (27 November 2013)
  - Improved appearance of flexible dividers
  - Modified default tab titles to match GLT1 behavior
  - Modified button resize behavior to shrink-to-fit in button boxes
  - Modified default button box horizontal alignment to 'center'
  - Added support for row values for property 'Contents'
  - Fixed bugs in uiextras.Grid accessors for property 'Heights'

2.0.2  Minor changes (19 November 2013)
  - Added support for row values for contents companion properties in uix
  - Modified uix.Image to construct JLabel on EDT
  - Added HandleVisibility awareness to uix.ChildObserver
  - Suppressed constructor warnings in uiextras

2.0.1  Initial beta version (16 November 2013)


6.  FEEDBACK

* Email: david.sampson@mathworks.co.uk
* Gecko: Component "Consulting Projects", subcomponent "GUI Layout Toolbox"
