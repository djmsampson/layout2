# :traffic_light: uix.HButtonBox

Arrange buttons horizontally in a single row

## Syntax

`b = uix.HButtonBox()` creates a new, default, *unparented* horizontal button box. This is a type of [horizontal layout](uixHBox.md) specialized for arranging a row of buttons, checkboxes, or similar graphical elements. All elements are given equal size and by default are centered in the drawing area. The justification can be changed as required.

`b = uix.HButtonBox(n1,v1,n2,v2,...)` also sets one or more property values.

## Properties

| Name | Description | Type |
| --- | --- | --- |
| `BackgroundColor` | Background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `ButtonSize` | The size used for the buttons or controls (all elements are given the same size) | `[width, height]` |
| `Contents` | Children, in order of addition to the layout, regardless of `HandleVisibility`; settable only to a permutation of itself | graphics vector |
| `HorizontalAlignment` | The horizontal position of the buttons or controls | `"left"` | `"center"` | `"right"` |
| `Padding` | Space around contents, in pixels | nonnegative integer |
| `Parent` | Parent figure or container | figure, panel, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#mw_e4809363-1f35-4bc7-89f8-36ed9cccb017) |
| `Position` | Position within parent figure or container, in `Units` | `[left, bottom, width, height]`  |
| `Spacing` | Space between elements, in pixels | nonnegative integer |
| `Units` | Position units; default is `"normalized"` | `"normalized"`, `"pixels"`, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#bub8wap-1_sep_shared-Position) |
| `VerticalAlignment` | The vertical position of the buttons or controls | `"top"` | `"middle"` | `"bottom"` |
| `Visible` | Visibility; default is `"on"` | `"on"` or `"off"` |

plus other [container properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`

## Examples

### Create three buttons in a horizontal button box

```matlab
f = figure( 'Name', 'uix.HButtonBox Example' );
hbb = uix.HButtonBox( 'Parent', f, 'ButtonSize', [130, 35], 'Spacing', 5 );
uicontrol( 'Parent', hbb, 'Style', 'pushbutton', 'String', 'One' )
uicontrol( 'Parent', hbb, 'Style', 'pushbutton', 'String', 'Two' )
uicontrol( 'Parent', hbb, 'Style', 'pushbutton', 'String', 'Three' )
```

### Create multiple controls in a horizontal button box in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
hbb = uix.HButtonBox( "Parent", f, "ButtonSize", [130, 35], "Spacing", 5 );
uibutton( hbb, "BackgroundColor", "r" );
uidropdown( hbb );
uibutton( hbb, "BackgroundColor", "b" );
uibutton( hbb, "BackgroundColor", "g" );
```

## Related Topics

* :arrow_right: [`uix.HBox`](uixHBox.md): Arrange elements horizontally in a single row
* :arrow_down: [`uix.VBox`](uixVBox.md): Arrange elements vertically in a single column
* :left_right_arrow: [`uix.HBoxFlex`](uixHBox.md): Arrange elements horizontally with draggable dividers
* :arrow_up_down: [`uix.VBoxFlex`](uixVBox.md): Arrange elements vertically with draggable dividers
* :vertical_traffic_light: [`uix.VButtonBox`](uixVButtonBox.md): Arrange buttons vertically in a single column