# :symbols: uix.Grid, uix.GridFlex

Arrange elements in a two-dimensional grid

## Syntax

`g = uix.Grid()` creates a new, default, *unparented* grid layout or flexible grid layout. The number of rows and columns to use is determined from the number of elements in the `Heights` and `Widths` properties, respectively. Child elements are arranged down column one first, then column two, and so on. If there are insufficient columns then a new one is added. The output is a new layout object that can be used as the parent for other user interface components.

`g = uix.Grid(n1,v1,n2,v2,...)` also sets one or more property values.

`uix.GridFlex` extends `uix.Grid`, adding draggable dividers between the rows and columns.

In a grid, the number of rows and columns change dynamically with the number of elements:
* Changing the number of rows may change the number of columns, and vice versa.
* Adding and removing elements may increase and decrease the number of columns.

To interleave empty space within the grid, use [`uix.Empty`](uixEmpty.md). Row heights and column widths can be fixed or variable, and are equipped with minimum values. Variable-sized rows and columns fill available container space, subject to minima, according to specified weights.

## Properties

| Name | Description | Type |
| --- | --- | --- |
| `BackgroundColor` | Background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `Contents` | Children, in order of addition to the layout, regardless of `HandleVisibility`; settable only to a permutation of itself | graphics vector |
| `Heights` | Height of the each of the rows; nonnegative entries indicate fixed sizes in pixels, and negative values indicate relative weights for resizing | double vector |
| `MinimumHeights` | Minimum height of each of the rows, in pixels | nonnegative double vector |
| `MinimumWidths` | Minimum width of each of the columns, in pixels | nonnegative double vector |
| `Padding` | Space around contents, in pixels | nonnegative integer |
| `Parent` | Parent figure or container | figure, panel, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#mw_e4809363-1f35-4bc7-89f8-36ed9cccb017) |
| `Position` | Position within parent figure or container, in `Units` | `[left, bottom, width, height]`  |
| `Spacing` | Space between rows and columns, in pixels | nonnegative integer |
| `Units` | Position units; default is `"normalized"` | `"normalized"`, `"pixels"`, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#bub8wap-1_sep_shared-Position) |
| `Visible` | Visibility; default is `"on"` | `"on"` or `"off"` |
| `Widths` | Width of the each of the columns; nonnegative entries indicate fixed sizes in pixels, and negative values indicate relative weights for resizing | double vector |

plus other [container properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`

### :warning: Deprecated

| Name | Alternative | Type | Notes |
| --- | --- | --- | --- |
| `DividerMarkings` (for `uix.GridFlex`) | none | `"on"` | `"off"` | Now `"off"`; no longer has any effect; this property toggled the markings on the draggable dividers |

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

## Related Topics

* :arrow_right: [`uix.HBox`](uixHBox.md): Arrange elements horizontally in a single row
* :arrow_down: [`uix.VBox`](uixVBox.md): Arrange elements vertically in a single column
* :left_right_arrow: [`uix.HBoxFlex`](uixHBox.md): Arrange elements horizontally with draggable dividers
* :arrow_up_down: [`uix.VBoxFlex`](uixVBox.md): Arrange elements vertically with draggable dividers
* :traffic_light: [`uix.HButtonBox`](uixHButtonBox.md): Arrange buttons horizontally in a single row
* :vertical_traffic_light: [`uix.VButtonBox`](uixVButtonBox.md): Arrange buttons vertically in a single column

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024