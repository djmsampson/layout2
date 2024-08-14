# `uix.Grid`, `uix.GridFlex`

[![Grid](Images/bigIcon_Grid.png "Grid")](uixGrid.md)[![GridFlex](Images/bigIcon_GridFlex.png "GridFlex")](uixGrid.md)

* `uix.Grid`: Arrange elements in a two-dimensional grid
* `uix.GridFlex`: Arrange elements in a two-dimensional grid with draggable dividers

## Syntax

### `uix.Grid` 

* `gr = uix.Grid()` creates a new grid layout. The number of rows and columns to use is determined from the number of elements in the `Heights` and `Widths` properties, respectively. Child elements are arranged down column one first, then column two, and so on. If there are insufficient columns then a new one is added. The output is a new layout object that can be used as the parent for other user-interface components.
* `gr = uix.Grid( <propertyName>, <propertyValue>, ... )` also sets one or more property values.

### `uix.GridFlex`

* `grf = uix.GridFlex()` creates a new grid layout with draggable dividers between elements. The number of rows and columns to use is determined from the number of elements in the `Heights` and `Widths` properties, respectively. Child elements are arranged down column one first, then column two, and so on. If there are insufficient columns then a new one is added. The output is a new layout object that can be used as the parent for other user-interface components.
* `grf = uix.GridFlex( <propertyName>, <propertyValue>, ... )` also sets one or more property values.

## `uix.Grid` and `uix.GridFlex` Properties


## Examples

### Create controls of different sizes in a 2-by-3 grid

```matlab
f = figure( 'Name', 'uix.Grid Example' );
gr = uix.Grid( 'Parent', f, 'Spacing', 5 );
uicontrol( 'Parent', gr, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
uicontrol( 'Parent', gr, 'Style', 'pushbutton', 'BackgroundColor', 'g' )
uicontrol( 'Parent', gr, 'Style', 'pushbutton', 'BackgroundColor', 'b' )
uix.Empty( 'Parent', gr );
uicontrol( 'Parent', gr, 'Style', 'pushbutton', 'BackgroundColor', 'c' )
uicontrol( 'Parent', gr, 'Style', 'pushbutton', 'BackgroundColor', 'y' )
set( gr, 'Widths', [-1, 100, -2], 'Heights', [-1, 100] )
```

### Add axes and controls to a flexible grid

```matlab
f = figure( 'Name', 'uix.GridFlex Example' );
grf = uix.GridFlex( 'Parent', f, 'Spacing', 5 );
ax = axes( 'Parent', uicontainer( grf ), 'PositionConstraint', 'innerposition', 'NextPlot', 'add' );
plot( ax, randn( 100, 1 ), 'LineWidth', 2 )
uicontrol( 'Parent', grf, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
ax = axes( 'Parent', uicontainer( grf ), 'PositionConstraint', 'innerposition', 'NextPlot', 'add' );
plot( ax, cumsum( randn( 100, 1 ) ), 'LineWidth', 2 )
uicontrol( 'Parent', grf, 'Style', 'pushbutton', 'BackgroundColor', 'g' )
ax = axes( 'Parent', uicontainer( grf ), 'PositionConstraint', 'innerposition', 'NextPlot', 'add' );
surf( ax, peaks() )
shading( ax, 'interp' )
uicontrol( 'Parent', grf, 'Style', 'pushbutton', 'BackgroundColor', 'b' )
set( grf, 'Widths', [-1, -1, -1], 'Heights', [-1, 25] )
```

### Create a 2-by-2 grid in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
gr = uix.Grid( "Parent", f, "Spacing", 10 );
uibutton( gr, "BackgroundColor", "m" );
uibutton( gr, "BackgroundColor", "c" );
uilistbox( gr );
uidropdown( gr );
gr.Heights = [-1, -1];
```

### Add axes and controls to a flexible layout in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
grf = uix.GridFlex( "Parent", f, "Spacing", 5, "Padding", 5 );
ax = axes( "Parent", uicontainer( grf ), "PositionConstraint", "innerposition", "NextPlot", "add" );
plot( ax, randn( 100, 1 ), 'LineWidth', 2 )
uibutton( grf, "BackgroundColor", "m" );
ax = axes( "Parent", uicontainer( grf ), "PositionConstraint", "innerposition", "NextPlot", "add" );
plot( ax, cumsum( randn( 100, 1 ) ), 'LineWidth', 2 )
p = uipanel( "Parent", grf, "BorderType", "none" );
gl = uigridlayout( p, [1, 1] );
uiknob( gl );
ax = axes( "Parent", uicontainer( grf ), "PositionConstraint", "innerposition", "NextPlot", "add" );
surf( ax, peaks() )
shading( ax, "interp" )
p = uipanel( "Parent", grf, "BorderType", "none" );
gl = uigridlayout( p, [1, 1] );
uislider( gl );
set( grf, 'Widths', [-1, -1, -1], 'Heights', [-1, 100] )
```

## See also

* [`uix.HBox`](uixHBox.md): Arrange elements horizontally in a single row
* [`uix.VBox`](uixVBox.md): Arrange elements vertically in a single column
* [`uix.HBoxFlex`](uixHBox.md): Arrange elements horizontally with draggable dividers
* [`uix.VBoxFlex`](uixVBox.md): Arrange elements vertically with draggable dividers
* [`uix.HButtonBox`](uixHButtonBox.md): Arrange buttons horizontally in a single row
* [`uix.VButtonBox`](uixVButtonBox.md): Arrange buttons vertically in a single column