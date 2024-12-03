# **What is GUI Layout Toolbox?**

GUI Layout Toolbox provides a toolbox of MATLAB classes that allow for complex arrangement of graphical user interface elements within a figure window. The main capabilities provided are:

-  Automatic element arrangement horizontally, vertically, or in grids 
-  Ability to specify fixed sizes or resizing weights for each element 
-  Ability to nest layouts to produce virtually any element arrangement 
-  Divider bars for user\-resizing of elements 

These element arrangements are designed to match those found as standard in other user\-interface toolkits such as Java Swing, GTK, QT, etc.

## **Quick Start Example**

In this example we create a simple application to plot random data. Run the example by entering:

```matlab
randomPlotter
```

The source code is available in `randomPlotter.m`.

```matlab
edit randomPlotter 
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

## **Installation**

GUI Layout Toolbox is provided as a MATLAB toolbox file (**`.mltbx`**).

For instructions on installing and uninstalling toolboxes, see [Get and Manage Add\-Ons](https://www.mathworks.com/help/matlab/matlab_env/get-add-ons.html) in the MATLAB documentation.

## **Support**

This toolbox is not a MathWorks\-supported product. However, if you have problems, suggestions, or other comments, please contact the authors:

-  [David Sampson](https://www.mathworks.com/matlabcentral/profile/authors/16247) 
-  [Ben Tordoff](https://www.mathworks.com/matlabcentral/profile/authors/1297191) 

If you like this toolbox, help others to find it by leaving a rating and comment on the [MATLAB Central File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox).

## **Acknowledgements**

The authors wish to acknowledge the earlier contributions of the following MathWorks [consultants](https://www.mathworks.com/services/consulting.html) to this area:

-  Brad Phelan 
-  Malcolm Wood 
-  Richard Lang 
-  Paul Kerr\-Delworth