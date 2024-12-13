# Colorbars and Legends

## Overview

When using layouts to position axes that can have a colorbar or legend, it is very important to group the axes with its colorbar and legend by placing them insider a `uicontainer`. The following example illustrates this.

## Example

The code for this example is available in `colorbarsAndLegends.m`.

## Create a figure

Create a new figure window and remove the toolbar and menus.

```matlab
f = figure( 'Name', 'Axes Legends and Colorbars', ...
    'MenuBar', 'none', ...
    'ToolBar', 'none', ...
    'NumberTitle', 'off' );
```

## Create the layout

The layout involves two axes side by side. Each axes is placed into a `uicontainer` so that the legend and colorbar and grouped together with the axes.

```matlab
vbox = uix.VBoxFlex( 'Parent', f, 'Spacing', 3 );
axes1 = axes( 'Parent', uicontainer( 'Parent', vbox ) );
axes2 = axes( 'Parent', uicontainer( 'Parent', vbox ) );
```

## Add axes decorations

Give the first axes a colorbar and the second axes a legend.

```matlab
surf( axes1, membrane( 1, 15 ) )
colorbar( axes1 )

theta = 0:360;
plot( axes2, theta, sind( theta ), theta, cosd( theta ), 'LineWidth', 2 )
legend( axes2, 'sin', 'cos', 'Location', 'northwestoutside' )
```

## Related Topics

* [Flexible vertical boxes](uixVBox.md)
* [`axes`](https://www.mathworks.com/help/matlab/ref/axes.html)
* [`colorbar`](https://www.mathworks.com/help/matlab/ref/colorbar.html)
* [`legend`](https://www.mathworks.com/help/matlab/ref/legend.html)

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024