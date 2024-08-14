# `uix.VBox`, `uix.VBoxFlex`

[![VBox](Images/bigIcon_VBox.png "VBox")](uixVBox.md)[![VBoxFlex](Images/bigIcon_VBoxFlex.png "VBoxFlex")](uixVBox.md)

* `uix.VBox`: Arrange elements vertically in a single row
* `uix.VBoxFlex`: Arrange elements vertically with draggable dividers

## Syntax

### `uix.VBox` 

* `vb = uix.VBox()` creates a new vertical box layout. The output is a new layout object that can be used as the parent for other user-interface components.
* `vb = uix.VBox( <propertyName>, <propertyValue>, ... )` also sets one or more property values.

### `uix.VBoxFlex`

* `vbf = uix.VBoxFlex()` creates a new vertical box layout with draggable dividers. The output is a new layout object that can be used as the parent for other user-interface components.
* `vbf = uix.VBoxFlex( <propertyName>, <propertyValue>, ... )` also sets one or more property values.

## `uix.VBox` and `uix.VBoxFlex` Properties


## Examples

### Create controls of different sizes in a vertical layout

```matlab
f = figure( 'Name', 'uix.VBox Example' );
vb = uix.VBox( 'Parent', f, 'Spacing', 5 );
uicontrol( 'Parent', vb, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
uicontrol( 'Parent', vb, 'Style', 'pushbutton', 'BackgroundColor', 'g' )
uicontrol( 'Parent', vb, 'Style', 'pushbutton', 'BackgroundColor', 'b' )
vb.Heights = [-1, 100, -2];
```

### Create controls of different sizes in a flexible vertical layout

```matlab
f = figure( 'Name', 'uix.VBoxFlex Example' );
vbf = uix.VBoxFlex( 'Parent', f, 'Spacing', 5 );
uicontrol( 'Parent', vbf, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
uicontrol( 'Parent', vbf, 'Style', 'pushbutton', 'BackgroundColor', 'g' )
uicontrol( 'Parent', vbf, 'Style', 'pushbutton', 'BackgroundColor', 'b' )
uicontrol( 'Parent', vbf, 'Style', 'pushbutton', 'BackgroundColor', 'y' )
vbf.Heights = [-1, 100, -2, -1];
```

### Nest a vertical layout inside a [horizontal layout](uixHBox.md)

```matlab
f = figure( 'Name', 'Nested Layouts Example' );
hb = uix.HBox( 'Parent', f );
uicontrol( 'Parent', hb, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
vb = uix.VBox( 'Parent', hb, 'Padding', 5, 'Spacing', 5 );
uicontrol( 'Parent', vb, 'Style', 'pushbutton', 'String', 'Button 1' )
uicontrol( 'Parent', vb, 'Style', 'pushbutton', 'String', 'Button 2' )
uicontrol( 'Parent', vb, 'Style', 'pushbutton', 'String', 'Button 3' )
hb.Widths = [60, -1];
```

### Create a flexible vertical layout in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
f.Position(3:4) = [400, 200];
vbf = uix.VBoxFlex( "Parent", f );
uibutton( vbf, "BackgroundColor", "r" );
uibutton( vbf, "BackgroundColor", "g" );
uibutton( vbf, "BackgroundColor", "b" );
uidropdown( vbf );
vbf.Heights = [25, 25, 25, 25];
```

### Add a gauge and table to a flexible vertical layout in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
vbf = uix.VBoxFlex( "Parent", f );
p = uipanel( "Parent", vbf, "BorderType", "none" );
gl = uigridlayout( p, [1, 1] );
g = uigauge( gl );
uitable( vbf, "Data", magic( 5 ) );
```

## See also

* [`uix.HBox`](uixHBox.md): Arrange elements horizontally in a single row
* [`uix.HBoxFlex`](uixHBox.md): Arrange elements horizontally with draggable dividers
* [`uix.HButtonBox`](uixHButtonBox.md): Arrange buttons horizontally in a single row
* [`uix.VButtonBox`](uixVButtonBox.md): Arrange buttons vertically in a single column