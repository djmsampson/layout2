# :arrow_down: uix.VBox, uix.VBoxFlex

Arrange elements vertically in a single row

## Syntax

`b = uix.VBox()` creates a new, default, *unparented* vertical box layout or flexible box layout. The output is a new layout object that can be used as the parent for other user interface components.

`b = uix.VBox(n1,v1,n2,v2,...)` also sets one or more property values.

`uix.VBoxFlex` extends `uix.VBox`, adding draggable dividers between the rows.

## Properties

| Name | Description | Type |
| --- | --- | --- |
| `BackgroundColor` | Background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `Contents` | Children, in order of addition to the layout, regardless of `HandleVisibility`; settable only to a permutation of itself | graphics vector |
| `Heights` | Height of the each of the rows; nonnegative entries indicate fixed sizes in pixels, and negative values indicate relative weights for resizing | real double vector |
| `MinimumHeights` | Minimum height of each of the rows, in pixels | nonnegative double vector |
| `Padding` | Space around contents, in pixels | nonnegative scalar integer
| `Parent` | Parent figure or container | figure, panel, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#mw_e4809363-1f35-4bc7-89f8-36ed9cccb017) |
| `Position` | Position within parent figure or container, in `Units` | `[left, bottom, width, height]`  |
| `Spacing` | Space between rows, in pixels | nonnegative scalar |
| `Units` | Position units; default is `"normalized"` | `"normalized"`, `"pixels"`, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#bub8wap-1_sep_shared-Position) |
| `Visible` | Visibility; default is `"on"` | `"on"` or `"off"` |

plus other [container properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`

### :warning: Deprecated

| Name | Alternative | Type | Notes |
| --- | --- | --- | --- |
| `DividerMarkings` (for `uix.VBoxFlex`) | none | `"on"` | `"off"` | Now `"off"`; no longer has any effect; this property toggled the markings on the draggable dividers |

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

## Related Topics

* :arrow_right: [`uix.HBox`](uixHBox.md): Arrange elements horizontally in a single row
* :left_right_arrow: [`uix.HBoxFlex`](uixHBox.md): Arrange elements horizontally with draggable dividers
* :traffic_light: [`uix.HButtonBox`](uixHButtonBox.md): Arrange buttons horizontally in a single row
* :vertical_traffic_light: [`uix.VButtonBox`](uixVButtonBox.md): Arrange buttons vertically in a single column