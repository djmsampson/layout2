# Quick Start Example

In this example we create a simple application to plot random data.

```matlab
randomPlotter
```

The example uses a [vertical layout](uixVBox.md) to stack the axes above a [horizontal layout](uixHBox.md). In turn, the horizontal layout groups two buttons, for resetting the plot and generating new data respectively. The code listing is as follows.

```matlab
function varargout = randomPlotter()
%RANDOMPLOTTER Simple app to plot random data.
% This example shows how to use layouts to create a simple application for
% plotting random data.

% Copyright 2024 The MathWorks, Inc.

%% Create a new figure window.
f = uifigure( "AutoResizeChildren", "off" );

%% Define the application layout.
% We create a vertical layout containing an axes a horizontal layout. The
% horizontal layout contains two buttons.
vb = uix.VBox( "Parent", f, ...
    "Padding", 5, ...
    "Spacing", 5 );
p = uipanel( "Parent", vb, ...
    "BorderType", "none" );
ax = axes( "Parent", p );
pl = plot( ax, 1:100, NaN( 100, 1 ), "LineWidth", 2 );
title( ax, "Random Data" )
grid( ax, "on" )
hb = uix.HBox( "Parent", vb, ...
    "Padding", 5, ...
    "Spacing", 5 );
vb.Heights = [-1, 35];

%% Add the button controls.
uibutton( "Parent", hb, ...
    "Text", "Clear", ...
    "Tooltip", "Clear data from the axes", ...
    "ButtonPushedFcn", @onClear );
uibutton( "Parent", hb, ...
    "Text", "Generate data", ...
    "Tooltip", "Generate new random data", ...
    "ButtonPushedFcn", @onGenerate );

%% Create initial data.
onGenerate()

%% Return the figure if an output is requested.
nargoutchk( 0, 1 )
if nargout == 1
    varargout{1} = f;
end % if

    function onClear( ~, ~ )

        pl.YData = NaN( 100, 1 );

    end % onClear

    function onGenerate( ~, ~ )

        pl.YData = rand( 100, 1 );

    end % onGenerate

end % randomPlotter  
```

## Related Topics
* [Horizontal layouts](uixHBox.md)
* [Vertical layouts](uixVBox.md)

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024