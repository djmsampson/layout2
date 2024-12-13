# :arrow_right: uix.HBox, uix.HBoxFlex

Arrange elements horizontally in a single row

## Syntax

`b = uix.HBox()` creates a new, default, *unparented* horizontal box layout or flexible box layout. The output is a new layout object that can be used as the parent for other user interface components.

`b = uix.HBox(n1,v1,n2,v2,...)` also sets one or more property values.

`uix.HBoxFlex` extends `uix.HBox`, adding draggable dividers between the columns.

To interleave empty space within the horizontal layout, use [`uix.Empty`](uixEmpty.md). Column widths can be fixed or variable, and are equipped with minimum values. Variable-sized columns fill available container space, subject to minima, according to specified weights.

## Properties

| Name | Description | Type |
| --- | --- | --- |
| `BackgroundColor` | Background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `Contents` | Children, in order of addition to the layout, regardless of `HandleVisibility`; settable only to a permutation of itself | graphics vector |
| `MinimumWidths` | Minimum width of each of the columns, in pixels | nonnegative double vector |
| `Padding` | Space around contents, in pixels | nonnegative integer |
| `Parent` | Parent figure or container | figure, panel, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#mw_e4809363-1f35-4bc7-89f8-36ed9cccb017) |
| `Position` | Position within parent figure or container, in `Units` | `[left, bottom, width, height]`  |
| `Spacing` | Space between columns, in pixels | nonnegative integer |
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
| `DividerMarkings` (for `uix.HBoxFlex`) | none | `"on"` | `"off"` | Now `"off"`; no longer has any effect; this property toggled the markings on the draggable dividers |

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

## Related Topics

* :arrow_down: [`uix.VBox`](uixVBox.md): Arrange elements vertically in a single column
* :arrow_up_down: [`uix.VBoxFlex`](uixVBox.md): Arrange elements vertically with draggable dividers
* :traffic_light: [`uix.HButtonBox`](uixHButtonBox.md): Arrange buttons horizontally in a single row
* :vertical_traffic_light: [`uix.VButtonBox`](uixVButtonBox.md): Arrange buttons vertically in a single column

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024