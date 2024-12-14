# :black_square_button: uix.BoxPanel

Arrange a single element in a panel with title and controls

## Syntax

`p = uix.BoxPanel()` creates a new, default, *unparented*, box-styled panel object with automatic management of the contained control or layout. The available properties are largely the same as the standard [`uipanel`](https://www.mathworks.com/help/matlab/ref/uipanel.html) object.

`p = uix.BoxPanel(n1,v1,n2,v2,...)` also sets one or more property values.

## Properties

| Name | Description | Type |
| --- | --- | --- |
| `BackgroundColor` | Background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `BorderType` | Type of border around the box panel area | `"none"` | `"etchedin"` | `"etchedout"` | `"beveledin"` | `"beveledout"` | `"line"` |
| `BorderWidth` | Width of the box panel border | nonnegative integer |
| `Contents` | Children, in order of addition to the layout, regardless of `HandleVisibility`; settable only to a permutation of itself | graphics vector |
| `CloseRequestFcn` | Function to call when the panel close icon is clicked; if this callback is empty, then no close icon is shown | [`function_handle`](https://www.mathworks.com/help/matlab/ref/function_handle.html) |
| `CloseTooltip` | Custom tooltip for the close icon; if the `CloseRequestFcn` is empty, then no close icon is shown | `string` |
| `Docked` | Whether the box panel is docked; see [Working with Box Panels](WorkingWithBoxPanels.md) for details | `logical` |
| `DockFcn` | Function to call when the panel is docked or undocked; if this callback is empty, then no dock button is shown; see [Working with Box Panels](WorkingWithBoxPanels.md) for details. | [`function_handle`](https://www.mathworks.com/help/matlab/ref/function_handle.html) |
| `DockTooltip` | Custom tooltip for the dock icon (when the box panel is undocked); if the `DockFcn` is empty, then no dock icon is shown | `string` |
| `FontAngle` | Title font angle | `"normal"` | `"italic"` |
| `FontName` | Title font name (e.g., `"Arial"`, `"Helvetica"`, etc) | `string` |
| `FontSize` | Title font size | positive integer |
| `FontUnits` | Title font units | `"inches"` | `"centimeters"` | `"normalized"` | `"points"` | `"pixels"` |
| `FontWeight` | Title font weight | `"normal"` | `"bold"` |
| `ForegroundColor` | Title font color and/or color of 2D border line | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `HelpFcn` | Function to call when the help icon is clicked; if this callback is empty, then no help icon is shown; see [Working with Box Panels](WorkingWithBoxPanels.md) for details | [`function_handle`](https://www.mathworks.com/help/matlab/ref/function_handle.html) |
| `HelpTooltip` | Custom tooltip for help icon; if the `HelpFcn` is empty, then no help icon is shown | `string` |
| `MaximizeTooltip` | Custom tooltip for minimize icon (when panel is minimized); if the `MinimizeFcn` callback is empty, then no minimize button is shown | `string` |
| `Minimized` | Whether the box panel is minimized; see [Working with Box Panels](WorkingWithBoxPanels.md) for details | `logical` |
| `MinimizeFcn` | Function to call when the box panel is minimized or maximized; if this callback is empty, then no minimize icon is shown see [Working with Box Panels](WorkingWithBoxPanels.md) for details | [`function_handle`](https://www.mathworks.com/help/matlab/ref/function_handle.html) |
| `MinimizeTooltip` | Custom tooltip for minimize icon (when panel is maximized); if the `MinimizeFcn` is empty, then no minimize icon is shown | `string` |
| `Padding` | Space around contents, in pixels | nonnegative integer |
| `Parent` | Parent figure or container | figure, panel, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#mw_e4809363-1f35-4bc7-89f8-36ed9cccb017) |
| `Position` | Position within parent figure or container, in `Units` | `[left, bottom, width, height]` |
| `Title` | Title string | `string` |
| `TitleColor` | Title bar background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `UndockTooltip` | Custom tooltip for dock icon (when panel is docked); if the `DockFcn` is empty, then no dock icon is shown | `string` |
| `Units` | Position units; default is `"normalized"` | `"normalized"`, `"pixels"`, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#bub8wap-1_sep_shared-Position) |
| `Visible` | Visibility; default is `"on"` | `"on"` or `"off"` |

plus other [container properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`
* Decorations: `HighlightColor`, `ShadowColor`

### :warning: Deprecated

| Name | Alternative | Type | Notes |
| --- | --- | --- | --- |
| `Selection` | none | nonnegative integer | No longer has any effect; in previous versions, the currently visible child was determined using this property |
| `MinimizeTooltipString` | `MinimizeTooltip` | `string` | Renamed for consistency with [`uicontrol`](https://www.mathworks.com/help/matlab/ref/uicontrol.html) and web graphics controls |
| `MaximizeTooltipString` | `MaximizeTooltip` | `string` | As above |
| `HelpTooltipString` | `HelpTooltip` | `string` | As above |
| `CloseTooltipString` | `CloseTooltip` | `string` | As above |
| `DockTooltipString` | `DockTooltip` | `string` | As above |
| `UndockTooltipString` | `UndockTooltip` | `string` | As above |

## Examples

### Add a button to a box panel

```matlab
f = figure();
bp = uix.BoxPanel( 'Parent', f, 'Title', 'A Box Panel', 'Padding', 5 );
uicontrol( 'Parent', bp, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
``` 

### Add a listbox and a button to a [horizontal layout](uixHBox.md) inside a box panel

```matlab
f = figure();
bp = uix.BoxPanel( 'Parent', f, 'Title', 'Box Panel', 'Padding', 5 );
hb = uix.HBox( 'Parent', bp, 'Spacing', 5, 'Padding', 5 );
uicontrol( 'Parent', hb, 'Style', 'listbox', 'String', {'Item 1', 'Item 2'} )
uicontrol( 'Parent', hb, 'BackgroundColor', 'b' )
h.Widths = [100, -1];
```

### Create a box panel with a help button on the title bar

```matlab
f = figure();
bp = uix.BoxPanel( 'Parent', f, 'Title', 'Box Panel with Help Button', ...
'HelpFcn', @(~, ~) doc( "sin" ) );
ax = axes( uicontainer( bp ) );
x = linspace( -2*pi, 2*pi, 500 );
y = sin( 3*x );
plot( ax, x, y, "LineWidth", 2, "DisplayName", "$y = \sin(x)$" )
legend( ax, "Interpreter", "latex" )
```

### Add a vertical button box to a box panel in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
bp = uix.BoxPanel( "Parent", f, "Title", "Box Panel with Button Box", ...
"Units", "normalized", "Position", [0.05, 0.05, 0.90, 0.90], ...
"FontSize", 16 );
vbb = uix.VButtonBox( "Parent", bp, "Spacing", 10, "ButtonSize", [100, 40] );
uibutton( vbb, "BackgroundColor", "r" );
uibutton( vbb, "BackgroundColor", "g" );
uibutton( vbb, "BackgroundColor", "b" );
```

## Related Topics

* :page_facing_up: [`uix.Panel`](uixPanel.md): Arrange a single element inside a standard panel
* :card_index: [`uix.CardPanel`](uixCardPanel.md): Show one element (card) from a list
* :point_right: [`uix.TabPanel`](uixTabPanel.md): Arrange elements in a panel with tabs for selecting which element is visible
* :scroll: [`uix.ScrollingPanel`](uixScrollingPanel.md): Arrange a single element inside a scrollable panel

___

[home](index.md) :house: | [`CardPanel`](uixCardPanel.md) :card_index: | [`BoxPanel`](uixBoxPanel.md) :black_square_button: | [`TabPanel`](uixTabPanel.md) :point_right: | [`ScrollingPanel`](uixScrollingPanel.md) :scroll: | [`HBox`](uixHBox.md) :arrow_right: | [`VBox`](uixVBox.md) :arrow_down: | [`Grid`](uixGrid.md) :symbols: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024