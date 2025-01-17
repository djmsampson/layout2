# :scroll: uix.ScrollingPanel

Arrange a single element inside a scrollable panel

## Syntax

`p = uix.ScrollingPanel()` creates a new, default, *unparented* scrolling panel. A scrolling panel arranges a single element inside a panel and provide scrollbars if the panel is smaller than the element.

`p = uix.ScrollingPanel(n1,v1,n2,v2,...)` also sets one or more property values.

## Properties

| Name | Description | Type |
| --- | --- | --- |
| `BackgroundColor` | Background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `Contents` | Children, in order of addition to the layout, regardless of `HandleVisibility`; settable only to a permutation of itself | graphics vector |
| `Height` | Child height; a positive value indicates a fixed size in pixels, whereas a negative value indicates a relative weight for resizing | double |
| `HorizontalOffset` | Horizontal offset of the child; the value is limited to between 0 and the difference between the width of the child and the width of the panel | nonnegative double |
| `HorizontalStep` | Horizontal slider step, in pixels | positive double |
| `MinimumHeight` | Minimum height of the child, in pixels | positive double |
| `MinimumWidth` | Minimum width of the child, in pixels | positive double |
| `MouseWheelEnabled` | Indicates whether the scrolling panels responds to user interaction with the mouse wheel (default: `'on'`) | `'on'` | `'off'` |
| `Padding` | Space around contents, in pixels | nonnegative integer |
| `Parent` | Parent figure or container | figure, panel, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#mw_e4809363-1f35-4bc7-89f8-36ed9cccb017) |
| `Position` | Position within parent figure or container, in `Units` | `[left, bottom, width, height]` |
| `Units` | Position units; default is `'normalized'` | `'normalized'`, `'pixels'`, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#bub8wap-1_sep_shared-Position) |
| `VerticalOffset` | Vertical offset of the child; the value is limited to between 0 and the difference between the height of the child and the height of the panel | nonnegative double |
| `VerticalStep` | Vertical slider step, in pixels | positive double |
| `Visible` | Visibility; default is `'on'` | `'on'` or `'off'` |
| `Width` | Child width; a positive value indicates a fixed size in pixels, whereas a negative value indicates a relative weight for resizing | double |

plus other [container properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`

### :warning: Deprecated

| Name | Alternative | Type | Notes |
| --- | --- | --- | --- |
| `Selection` | none | nonnegative integer | No longer has any effect; in previous versions, the currently visible child was determined using this property |
| `Heights` | `Height` | double vector | Now scalar |
| `MinimumHeights` | `MinimumHeight` | positive double vector | Now scalar |
| `Widths` | `Width` | double vector | Now scalar |
| `MinimumWidths` | `MinimumWidth` | positive double vector | Now scalar |
| `VerticalSteps` | `VerticalStep` | positive double vector | Now scalar |
| `VerticalOffsets` | `VerticalOffset` | positive double vector | Now scalar |
| `HorizontalSteps` | `HorizontalStep` | positive double vector | Now scalar |
| `HorizontalOffsets` | `HorizontalOffset` | positive double vector | Now scalar |

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

[home](index.md) :house: | [`CardPanel`](uixCardPanel.md) :card_index: | [`BoxPanel`](uixBoxPanel.md) :black_square_button: | [`TabPanel`](uixTabPanel.md) :point_right: | [`ScrollingPanel`](uixScrollingPanel.md) :scroll: | [`HBox`](uixHBox.md) :arrow_right: | [`VBox`](uixVBox.md) :arrow_down: | [`Grid`](uixGrid.md) :symbols: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2025