# `uix.HBox`, `uix.HBoxFlex`

[![HBox](Images/bigIcon_HBox.png "HBox")](uixHBox.md)[![HBoxFlex](Images/bigIcon_HBoxFlex.png "HBoxFlex")](uixHBox.md)

* `uix.HBox`: Arrange elements horizontally in a single row
* `uix.HBoxFlex`: Arrange elements horizontally with draggable dividers

## Syntax

### `uix.HBox` 

* `hb = uix.HBox()` creates a new horizontal box layout. The output is a new layout object that can be used as the parent for other user-interface components.
* `hb = uix.HBox( <propertyName>, <propertyValue>, ... )` also sets one or more property values.

### `uix.HBoxFlex`

* `hbf = uix.HBoxFlex()` creates a new horizontal box layout with draggable dividers. The output is a new layout object that can be used as the parent for other user-interface components.
* `hbf = uix.HBoxFlex( <propertyName>, <propertyValue>, ... )` also sets one or more property values.

## `uix.HBox` and `uix.HBoxFlex` Properties


## Examples

### Create controls of different sizes in a horizontal layout

```matlab
f = figure( 'Name', 'uix.HBox Example' );
hb = uix.HBox( 'Parent', f, 'Spacing', 5 );
uicontrol( 'Parent', hb, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
uicontrol( 'Parent', hb, 'Style', 'pushbutton', 'BackgroundColor', 'g' )
uicontrol( 'Parent', hb, 'Style', 'pushbutton', 'BackgroundColor', 'b' )
hb.Widths = [-1, 100, -2];
```

### Create controls of different sizes in a flexible horizontal layout

```matlab
f = figure( 'Name', 'uix.HBoxFlex Example' );
hbf = uix.HBoxFlex( 'Parent', f, 'Spacing', 5 );
uicontrol( 'Parent', hbf, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
uicontrol( 'Parent', hbf, 'Style', 'pushbutton', 'BackgroundColor', 'g' )
uicontrol( 'Parent', hbf, 'Style', 'pushbutton', 'BackgroundColor', 'b' )
uicontrol( 'Parent', hbf, 'Style', 'pushbutton', 'BackgroundColor', 'y' )
hbf.Widths = [-1, 100, -2, -1];
```

### Nest a horizontal layout inside a [vertical layout](uixVBox.md)

```matlab
f = figure( 'Name', 'Nested Layouts Example' );
vb = uix.VBox( 'Parent', f );
uicontrol( 'Parent', vb, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
hb = uix.HBox( 'Parent', vb, 'Padding', 5, 'Spacing', 5 );
uicontrol( 'Parent', hb, 'Style', 'pushbutton', 'String', 'Button 1' )
uicontrol( 'Parent', hb, 'Style', 'pushbutton', 'String', 'Button 2' )
vb.Heights = [60, -1];
```

### Create a flexible horizontal layout in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
hbf = uix.HBoxFlex( "Parent", f );
uibutton( hbf, "BackgroundColor", "m" );
uilistbox( hbf );
uitable( hbf, "Data", magic( 3 ) );
hbf.Widths = [60, -1, -1];
```

### Add a knob and listbox to a flexible horizontal layout in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
hbf = uix.HBoxFlex( "Parent", f );
p = uipanel( "Parent", hbf, "BorderType", "none" );
g = uigridlayout( p, [1, 1] );
k = uiknob( g );
uilistbox( hbf );
```

## See also

* [`uix.VBox`](uixVBox.md): Arrange elements vertically in a single column
* [`uix.VBoxFlex`](uixVBox.md): Arrange elements vertically with draggable dividers
* [`uix.HButtonBox`](uixHButtonBox.md): Arrange buttons horizontally in a single row
* [`uix.VButtonBox`](uixVButtonBox.md): Arrange buttons vertically in a single column