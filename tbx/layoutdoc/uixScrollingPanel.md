# :scroll: uix.ScrollingPanel

Arrange a single element inside a scrollable panel

## Syntax

`p = uix.ScrollingPanel()` creates a new, default, *unparented* scrolling panel. A scrolling panel arranges a single element inside a panel and provide scrollbars if the panel is smaller than the element.

`p = uix.ScrollingPanel(n1,v1,n2,v2,...)` also sets one or more property values.

## Properties

| Name | Description | Type / Values |
| --- | --- | --- |
| `BackgroundColor` | Background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `Contents` | Children, in order of addition to the layout, regardless of `HandleVisibility`; settable only to a permutation of itself | graphics vector |
| `Height` | Content height; a positive value indicates a fixed size in pixels, whereas a negative value indicates the height of the panel | double |
| `HorizontalOffset` | Horizontal slider position, in pixels; left is 0, right is panel width minus content width | nonnegative double |
| `HorizontalStep` | Horizontal slider step, in pixels | positive double |
| `MinimumHeight` | Minimum content height, in pixels | positive double |
| `MinimumWidth` | Minimum content width, in pixels | positive double |
| `MouseWheelEnabled` | Is mouse wheel scrolling enabled? | **`'on'`**\|`'off'` |
| `Padding` | Space around content, in pixels | nonnegative double |
| `Parent` | Parent figure or container | [figure, panel, etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel.html?#mw_8db64fed-c01a-48e8-8182-edc1cbc2ac86) |
| `Position` | Position `[left bottom width height]` within parent figure or container, in `Units` | double 1x4 |
| `Units` | Position units | [**`'normalized'`**\|`'pixels'`\|etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel.html?#bub8wap-1_sep_mw_fcd6f5ca-13f2-41e8-9760-965b092c4093) |
| `VerticalOffset` | Vertical slider position, in pixels; top is 0, bottom is panel height minus content height | nonnegative double |
| `VerticalStep` | Vertical slider step, in pixels | positive double |
| `Visible` | Visibility | **`'on'`**\|`'off'` |
| `Width` | Content width; a positive value indicates a fixed size in pixels, whereas a negative value indicates the width of the panel | double |

plus other [container properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`

### :warning: Deprecated

| Name | Type / Values | Alternative | Notes |
| --- | --- | --- | --- |
| `Selection` | nonnegative integer | | Now ignored; previously, only the selected content was visible |
| `Heights` | double vector | `Height` | Now scalar; value applies to *all* contents |
| `MinimumHeights` | positive double vector | `MinimumHeight` | Now scalar; value applies to *all* contents |
| `Widths` | double vector | `Width` | Now scalar; value applies to *all* contents |
| `MinimumWidths` | positive double vector | `MinimumWidth` | Now scalar; value applies to *all* contents |
| `VerticalSteps` | positive double vector | `VerticalStep` | Now scalar; value applies to *all* contents |
| `VerticalOffsets` | nonnegative double vector | `VerticalOffset` | Now scalar; value applies to *all* contents |
| `HorizontalSteps` | positive double vector | `HorizontalStep` | Now scalar; value applies to *all* contents |
| `HorizontalOffsets` | nonnegative double vector | `HorizontalOffset` | Now scalar; value applies to *all* contents |

These changes were introduced in version 2.4.

## Examples

### Plot a surface in a scrolling panel

```matlab
f = figure( 'Name', 'uix.ScrollingPanel Example' );
f.Position(3:4) = 400;
sp = uix.ScrollingPanel( 'Parent', f );
ax = axes( 'Parent', sp );
[x, y, z] = peaks();
surf( ax, x, y, z )
ax.ActivePositionProperty = 'position';
set( sp, 'Width', 600, 'Height', 600, 'HorizontalOffset', 100, 'VerticalOffset', 100 )
```

### Visualize an image in a scrolling panel in web graphics

```matlab
f = uifigure( 'AutoResizeChildren', 'off' );
sp = uix.ScrollingPanel( 'Parent', f );
ax = axes( 'Parent', sp );
im = rand( 1e3, 1e3, 3 );
image( ax, im )
ax.PositionConstraint = 'innerposition';
set( sp, 'Width', 1000, 'Height', 1000, 'HorizontalOffset', 100, 'VerticalOffset', 100 )
```

## Related Topics

* [Working with Scrolling Panels](WorkingWithScrollingPanels.md)
* :page_facing_up: [`uix.Panel`](uixPanel.md): Arrange a single element inside a standard panel
* :card_index: [`uix.CardPanel`](uixCardPanel.md): Show one element (card) from a list
* :black_square_button: [`uix.BoxPanel`](uixBoxPanel.md): Arrange a single element in a panel with boxed title and optional toolbar controls
* :point_right: [`uix.TabPanel`](uixTabPanel.md): Arrange elements in a panel with tabs for selecting which element is visible

___

[home](index.md) :house: | [`CardPanel`](uixCardPanel.md) :card_index: | [`BoxPanel`](uixBoxPanel.md) :black_square_button: | [`TabPanel`](uixTabPanel.md) :point_right: | [`ScrollingPanel`](uixScrollingPanel.md) :scroll: | [`HBox`](uixHBox.md) :arrow_right: | [`VBox`](uixVBox.md) :arrow_down: | [`Grid`](uixGrid.md) :symbols: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024