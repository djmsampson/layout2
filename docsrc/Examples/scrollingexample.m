%% Creating a scrolling panel
%
%   This example opens a simple user-interface with a scrolling panel to
%   navigate around a large set of axes.
%
%   Copyright 2016 The MathWorks, Inc.

%% Open a window and add a panel
fig = figure();
fig.Position(3:4) = 400;
panel = uix.ScrollingPanel( 'Parent', fig );

%% Put a set of axes inside the panel
ax = axes( 'Parent', panel );
[x, y, z] = peaks();
surf( ax, x, y, z )
ax.ActivePositionProperty = 'position';

%% Set the panel contents dimensions to be larger than the panel
set( panel, 'Widths', 600, 'Heights', 600, 'HorizontalOffsets', 100, 'VerticalOffsets', 100 )