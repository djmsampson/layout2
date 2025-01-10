# Working with Scrolling Panels

A scrolling panel ([`uix.ScrollingPanel`](uixScrollingPanel.md)) arranges a single element inside a panel equipped with horizontal and vertical scrolling capabilities. This page contains examples showing how to use scrolling panels, as well as a note on the built-in `uipanel`, which can also be equipped with scrolling capability.

## Working with fixed-size contents

In this example, we'll plot a surface in an axes inside a scrolling panel. We'll set a fixed size for the axes within the scrolling panel.

Start by creating a figure.
```matlab
f = figure();
```

Add a scrolling panel.
```matlab
sp = uix.ScrollingPanel( 'Parent', f );
```

Place an axes inside the scrolling panel, and plot the surface.
```matlab
ax = axes( 'Parent', sp );
surf( ax, peaks )
```

At this point, the scrolling panel behaves like a standard `uicontainer`. If we resize the figure, then the scrolling panel and its contents resize in turn. Inspect the `Height` and `Width` values:
```matlab
sp.Height
sp.Width
```

Both the `Height` and the `Width` have value -1, indicating that the contents resize as the scrolling panel resizes. Next, let's set a fixed height for the axes.

```matlab
sp.Height = 1000;
```

Note that a vertical scrollbar appears on the scrolling panel. If the height of the figure window is changed, then the scrolling panel maintains a height of 1000 pixels for the axes. On the other hand, if the width of the figure window is changed, then the scrolling panel updates the width of the axes to match the width of the container.

Set a fixed width for the axes.
```matlab
sp.Width = 1000;
```

Note that a horizontal scrollbar appears on the scrolling panel. As for the height, the scrolling panel now maintains a fixed width of 1000 pixels for the axes. If the parent figure is increased in size to more than 1000 pixels in width or height, then the corresponding scrollbar disappears from the scrolling panel. If the parent figure is sufficiently decreased in size, then the scrollbars reappear.

## Minimum dimensions

In some cases, it's useful to impose minimum dimensions on the scrolling panel contents. For example, we may want to ensure that a plot remains visible for as long as possible as its container is decreased in size. To achieve this, we use relative dimensions for the scrolling panel contents, but set a minimum height or width (or both).

Start by creating a figure.
```matlab
f = figure();
```

Add a scrolling panel.
```matlab
sp = uix.ScrollingPanel( 'Parent', f );
```

Add the contents.
```matlab
ax = axes( 'Parent', sp );
surf( ax, peaks )
```

Set minimum dimensions on the scrolling panel. Resize the figure window.
```matlab
set( sp, 'MinimumHeight', 200, 'MinimumWidth', 200 )
f.Position(3:4) = 175;
```

Note that horizontal and vertical scrollbars appear on the scrolling panel. The scrolling panel preserves the minimum dimensions (200 by 200 pixels) of its contents.

## Specifying offsets

Scrolling panels can be scrolled interactively using the mouse wheel, or programmatically by specifying a horizontal or vertical offset.

Create a scrolling panel containing an axes.
```matlab
f = figure();
sp = uix.ScrollingPanel( 'Parent', f );
ax = axes( 'Parent', sp );
surf( ax, peaks )
```

Set the dimensions.
```matlab
set( sp, 'Height', 1000, 'Width', 1000 )
```

Scroll horizontally.
```matlab
sp.HorizontalOffset = 100;
```

Scroll vertically.
```matlab
sp.VerticalOffset = 200;
```

## Scrollable containers in web graphics

In web graphics, standard panels created using the `uipanel` function can be scrollable. Set the `Scrollable` property to `true` to enable scrolling on a panel. Layout managers created using the `uigridlayout` function can also be made scrollable in the same way. The panel or grid can be scrolled programmatically using the `scroll` function. 

## Related Topics

* :scroll: [`uix.ScrollingPanel`](uixScrollingPanel.md): Arrange a single element inside a scrollable panel
* [`scroll`](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.tree.scroll.html)
* [`uipanel`](https://www.mathworks.com/help/matlab/ref/uipanel.html)
* [`uigridlayout`](https://www.mathworks.com/help/matlab/ref/uigridlayout.html)

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2025