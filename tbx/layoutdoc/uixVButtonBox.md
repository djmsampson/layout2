# `uix.VButtonBox`

[![VButtonBox](Images/bigIcon_VButtonBox.png "VButtonBox")](uixVButtonBox.md)

Arrange buttons vertically in a single row

## Syntax

* `vbb = uix.VButtonBox()` creates a new vertical button box. This is a type of `VBox` specialized for arranging a column of buttons, checkboxes, or similar graphical elements. All elements are given equal size and by default are centered in the drawing area. The justification can be changed as required.
* `vbb = uix.VButtonBox( <propertyName>, <propertyValue>, ... )` also sets one or more property values.

## `uix.VButtonBox` Properties

## Examples

### Create three buttons in a vertical button box

```matlab
f = figure( 'Name', 'uix.VButtonBox Example' );
vbb = uix.VButtonBox( 'Parent', f, 'ButtonSize', [130, 35], 'Spacing', 5 );
uicontrol( 'Parent', vbb, 'Style', 'pushbutton', 'String', 'One' )
uicontrol( 'Parent', vbb, 'Style', 'pushbutton', 'String', 'Two' )
uicontrol( 'Parent', vbb, 'Style', 'pushbutton', 'String', 'Three' )
```

### Create multiple controls in a vertical button box in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
vbb = uix.HButtonBox( "Parent", f, "ButtonSize", [130, 35], "Spacing", 5 );
uibutton( vbb, "BackgroundColor", "r" );
uidropdown( vbb );
uibutton( vbb, "BackgroundColor", "b" );
uibutton( vbb, "BackgroundColor", "g" );
```

## See also

* [`uix.HBox`](uixHBox.md): Arrange elements horizontally in a single row
* [`uix.VBox`](uixVBox.md): Arrange elements vertically in a single column
* [`uix.HBoxFlex`](uixHBox.md): Arrange elements horizontally with draggable dividers
* [`uix.VBoxFlex`](uixVBox.md): Arrange elements vertically with draggable dividers
* [`uix.HButtonBox`](uixHButtonBox.md): Arrange buttons horizontally in a single row