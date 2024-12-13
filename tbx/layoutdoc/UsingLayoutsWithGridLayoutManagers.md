# Using Layouts with `uigridlayout` and `tiledlayout`

## Overview

The [`uigridlayout`](https://www.mathworks.com/help/matlab/ref/uigridlayout.html) grid layout manager was introduced in the R2018b release. This layout manager is designed to position web graphics controls and graphics elements in a two-dimensional grid. Similarly, the [`tiledlayout`](https://www.mathworks.com/help/matlab/ref/tiledlayout.html) was introduced in the R2019b release. This layout is designed to arrange tiled axes in a two-dimensional grid, and is a replacement for the [`subplot`](https://www.mathworks.com/help/matlab/ref/subplot.html) function.

Layouts in the GUI Layout Toolbox can be used in conjunction with `uigridlayout` and `tiledlayout` using the techniques described in the following examples.

## Using a GUI Layout Toolbox layout in a `uigridlayout` container

The `uigridlayout` container manages the position and size of its child elements, so if a layout from GUI Layout Toolbox is placed in a `uigridlayout`, it will be automatically resized as needed. In turn, any child elements placed inside the GUI Layout Toolbox layout are resized according to the layout type.

### Example: create an instrumentation panel

In this example, we'll create a simple instrumentation panel with two knobs, a gauge, and a vertical array with six buttons. We use a `uigridlayout` container to hold the knobs and the gauge, and place a [vertical button box](uixVButtonBox.md) in the container to hold the buttons.

```matlab
% Create the figure and grid layout
f = uifigure();
g = uigridlayout( f, [3, 2] );

% Add the instrumentation
k1 = uiknob( g, "Value", 50 ); % Row 1, column 1
ga = uigauge( g, "Value", 75 );
ga.Layout.Row = 2;
ga.Layout.Column = 1; % Row 2, column 1
k2 = uiknob( g, "Value", 30 );
k2.Layout.Row = 3;
k2.Layout.Column = 1; % Row 3, column 1

% Add a vertical button box and populate it with buttons
vbb = uix.VButtonBox( "Parent", g, "Spacing", 10, "ButtonSize", [130, 25] );
vbb.Layout.Row = [1, 3];
vbb.Layout.Column = 2; % Rows 1-3, column 2
uibutton( vbb, "Text", "Button 1" );
uibutton( vbb, "Text", "Button 2" );
uibutton( vbb, "Text", "Button 3" );
uibutton( vbb, "Text", "Button 4" );
uibutton( vbb, "Text", "Button 5" );
uibutton( vbb, "Text", "Button 6" );
```

## Using a `uigridlayout` container in a GUI Layout Toolbox layout

Some web graphics controls have a fixed aspect ratio. For these controls, correct resizing means preserving the aspect ratio. This generally applies to instrumentation components such as knobs ([`uiknob`](https://www.mathworks.com/help/matlab/ref/uiknob.html)), gauges ([`uigauge`](https://www.mathworks.com/help/matlab/ref/uigauge.html)), lamps ([`uilamp`](https://www.mathworks.com/help/matlab/ref/uilamp.html)) and switches ([`uiswitch`](https://www.mathworks.com/help/matlab/ref/uiswitch.html)). Correctly resizing controls that have a fixed aspect ratio is one benefit of using a `uigridlayout` container.

When a layout from the GUI Layout Toolbox is resized, it resizes its child elements by setting their `Position` property. In general, this will not preserve the aspect ratio of the child element, leading to unexpected resizing behavior for components with a fixed aspect ratio. We can work around this by first placing the component with a fixed aspect ratio inside a `uigridlayout`. 

We also note that the `Position` property of a `uigridlayout` container is read-only, so no code (including GUI Layout Toolbox resizing code) can set the `Position` property directly.

To resolve this issue, when using a `uigridlayout` container in a GUI Layout Toolbox layout, it's important to first place it in a [`uipanel`](https://www.mathworks.com/help/matlab/ref/uipanel.html) or `uicontainer` object.

### Example: create a flexible grid layout containing instrumentation elements

```matlab
% Create the figure and flexible grid
f = uifigure( "AutoResizeChildren", "off" );
grf = uix.GridFlex( "Parent", f );

% Add instrumentation controls
p = uipanel( "Parent", grf, "BorderType", "none" );
g = uigridlayout( p, [1, 1] );
uiknob( g, "Value", 50 );

p = uipanel( "Parent", grf, "BorderType", "none" );
g = uigridlayout( p, [1, 1] );
uigauge( g, "Value", 75 );

p = uipanel( "Parent", grf, "BorderType", "none" );
g = uigridlayout( p, [1, 1] );
uilamp( g, "Color", "g" );

p = uipanel( "Parent", grf, "BorderType", "none" );
g = uigridlayout( p, [1, 1] );
uiswitch( g );

% Resize the grid
grf.Widths = [-1, -1];
```

## Using tiled layouts with GUI Layout Toolbox layouts

A `tiledlayout` can be placed directly in a GUI Layout Toolbox layout, but it is recommended to first place it in a `uipanel` or `uicontainer`. Since tiled layouts can only contain axes, it is not possible to place a GUI Layout Toolbox layout or any other component inside a tiled layout.

### Example: create a tiled chart layout and listbox in a [flexible horizontal box](uixHBox.md)

```matlab
% Create container graphics
f = uifigure( "AutoResizeChildren", "off" );
hbf = uix.HBoxFlex( "Parent", f, "Padding", 5 );
c = uicontainer( hbf );
tl = tiledlayout( c, "flow" );

% Add the list box
uilistbox( hbf, "Items", ["A", "B", "C", "D"] );
hbf.Widths = [-1, 50];

% Add the axes tiles and plot random data
ax = nexttile( tl );
plot( ax, rand( 100, 1 ), "LineWidth", 2, "Color", "r" )
title( ax, "A" )

ax = nexttile( tl );
plot( ax, rand( 100, 1 ), "LineWidth", 2, "Color", "g" )
title( ax, "B" )

ax = nexttile( tl );
plot( ax, rand( 100, 1 ), "LineWidth", 2, "Color", "b" )
title( ax, "C" )

ax = nexttile( tl );
plot( ax, rand( 100, 1 ), "LineWidth", 2, "Color", "y" )
title( ax, "D" )
```

## Related Topics

* [Flexible horizontal layouts](uixHBox.md)
* [`uigridlayout`](https://www.mathworks.com/help/matlab/ref/uigridlayout.html)
* [`tiledlayout`](https://www.mathworks.com/help/matlab/ref/tiledlayout.html)

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024