function buildDocExamples()
%% layout examples
%
% This script creates examples showing the use of each of the layout
% container objects.

%   Copyright 2009 The MathWorks Inc
%   $Revision: 293 $    $Date: 2010-07-15 12:57:26 +0100 (Thu, 15 Jul 2010) $

close all force;

%% Axes examples
f = iFigure( 'axes OuterPosition example' );
axes( 'Parent', f, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1] );
iCaptureFigure( f, 'axes_outer' );

f = iFigure( 'axes Position example' );
axes( 'Parent', f, 'Units', 'Normalized', 'Position', [0 0 1 1] );
iCaptureFigure( f, 'axes_inner' );

f = iFigure( 'Axes inside layouts' );
set( f, 'Position', [50 50 400 250] );
iCaptureFigure( f, 'axes_layout_example_1' );

hbox = uiextras.HBoxFlex('Parent', f, 'Spacing', 3);
axes1 = axes( 'Parent', hbox, ...
    'ActivePositionProperty', 'OuterPosition' );
axes2 = axes( 'Parent', hbox, ...
    'ActivePositionProperty', 'Position' );
set( hbox, 'Sizes', [-2 -1] );
iCaptureFigure( f, 'axes_layout_example_2' );

x = membrane( 1, 15 );
surf( axes1, x );
lighting( axes1, 'gouraud' );
shading( axes1, 'interp' );
l = light( 'Parent', axes1 );
camlight( l, 'head' );
axis( axes1, 'tight' );
imagesc( x, 'Parent', axes2 );
set( axes2, 'xticklabel', [], 'yticklabel', [] );

iCaptureFigure( f, 'axes_layout_example_3' );

%% Layout basics
f = iFigure( 'Basics' );
set( f, 'Position', [50 50 180 90] );
iCaptureFigure( f, 'basics_example1' );
layout = uiextras.HBox( 'Parent', f );

uicontrol( 'String', 'Button 1', 'Parent', layout );
iCaptureFigure( f, 'basics_example2' );
uicontrol( 'String', 'Button 2', 'Parent', layout );
iCaptureFigure( f, 'basics_example3' );
uicontrol( 'String', 'Button 3', 'Parent', layout );
iCaptureFigure( f, 'basics_example4' );

layout.Sizes = [-1 -2 -1];
iCaptureFigure( f, 'basics_example5' );
layout.Sizes = [80 -1 -1];
iCaptureFigure( f, 'basics_example6' );

f = iFigure( 'Basics' );
set( f, 'Position', [50 50 180 90] );
layout = uiextras.VBox( 'Parent', f );
uicontrol( 'String', 'Button 1', 'Parent', layout );
uicontrol( 'String', 'Button 2', 'Parent', layout );
uicontrol( 'String', 'Button 3', 'Parent', layout );
iCaptureFigure( f, 'basics_example_vbox' );

f = iFigure( 'Basics' );
set( f, 'Position', [50 50 180 90] );
layout = uiextras.TabPanel( 'Parent', f );
uicontrol( 'String', 'Button 1', 'Parent', layout );
uicontrol( 'String', 'Button 2', 'Parent', layout );
uicontrol( 'String', 'Button 3', 'Parent', layout );
iCaptureFigure( f, 'basics_example_tab' );

%% Non-layout examples
f = iFigure( 'Normalized' );
set( f, 'Position', 200*ones(1,4) );
axes( 'Parent', f, ...
    'Units', 'Normalized', ...
    'OuterPosition', [0.02 0.2 0.96 0.8] );
uicontrol( 'Parent', f, ...
    'Units', 'Normalized', ...
    'Position', [0.02 0.02 0.46 0.16], ...
    'String', 'Button 1' );
uicontrol( 'Parent', f, ...
    'Units', 'Normalized', ...
    'Position', [0.52 0.02 0.46 0.16], ...
    'String', 'Button 2' );
iCaptureFigure( f, 'why_normalized1' );
set( f, 'Position', 250*ones(1,4) );
iCaptureFigure( f, 'why_normalized2' );

f = iFigure( 'Fixed' );
set( f, 'Position', 200*ones(1,4) );
axes( 'Parent', f, ...
    'Units', 'Pixels', ...
    'OuterPosition', [10 35 190 175] );
uicontrol( 'Parent', f, ...
    'Units', 'Pixels', ...
    'Position', [5 5 90 25], ...
    'String', 'Button 1' );
uicontrol( 'Parent', f, ...
    'Units', 'Pixels', ...
    'Position', [105 5 90 25], ...
    'String', 'Button 2' );
iCaptureFigure( f, 'why_fixed1' );
set( f, 'Position', 250*ones(1,4) );
iCaptureFigure( f, 'why_fixed2' );

f = iFigure( 'Layout' );
set( f, 'Position', 200*ones(1,4) );
vbox = uiextras.VBox( 'Parent', f );
axes( 'Parent', vbox );
iCaptureFigure( f, 'why_layout0_1' );
hbox = uiextras.HButtonBox( 'Parent', vbox, 'Padding', 5 );
uicontrol( 'Parent', hbox, ...
    'String', 'Button 1' );
uicontrol( 'Parent', hbox, ...
    'String', 'Button 2' );
iCaptureFigure( f, 'why_layout0_2' );
set( vbox, 'Sizes', [-1 35] )
iCaptureFigure( f, 'why_layout1' );
set( f, 'Position', 250*ones(1,4) );
iCaptureFigure( f, 'why_layout2' );


%% uiextras.CardPanel
f = iFigure( 'uiextras.CardPanel example' );
p = uiextras.CardPanel( 'Parent', f, 'Padding', 5 );
uicontrol( 'Parent', p, 'Background', 'r' );
uicontrol( 'Parent', p, 'Background', 'b' );
uicontrol( 'Parent', p, 'Background', 'g' );
p.SelectedChild = 2;
iCaptureFigure( f, 'CardPanel' );

%% uiextras.Panel
f = iFigure( 'uiextras.Panel example' );
p = uiextras.Panel( 'Parent', f, 'Title', 'A Panel', 'Padding', 5 );
uicontrol( 'Parent', p, 'Background', 'r' );
iCaptureFigure( f, 'Panel' );

%% uiextras.Panel 2
f = iFigure( 'uiextras.Panel example 2' );
p = uiextras.Panel( 'Parent', f, 'Title', 'A Panel', 'Padding', 5, 'TitlePosition', 'CenterTop' );
b = uiextras.HBox( 'Parent', p, 'Spacing', 5 );
uicontrol( 'Style', 'listbox', 'Parent', b, 'String', {'Item 1','Item 2'} );
uicontrol( 'Parent', b, 'Background', 'b' );
set( b, 'Sizes', [60 -1] );
iCaptureFigure( f, 'Panel2' );

%% uiextras.BoxPanel
f = iFigure( 'uiextras.BoxPanel example' );
p = uiextras.BoxPanel( 'Parent', f, 'Title', 'A BoxPanel', 'Padding', 5 );
uicontrol( 'Parent', p, 'Background', 'r' );
iCaptureFigure( f, 'BoxPanel' );

%% uiextras.BoxPanel 2
f = iFigure( 'uiextras.BoxPanel example 2' );
p = uiextras.BoxPanel( 'Parent', f, 'Title', 'A BoxPanel', 'Padding', 5 );
b = uiextras.HBoxFlex( 'Parent', p, 'Spacing', 5 );
uicontrol( 'Style', 'listbox', 'Parent', b, 'String', {'Item 1','Item 2'} );
uicontrol( 'Parent', b, 'Background', 'b' );
set( b, 'Sizes', [-1 -3] );
p.FontSize = 12;
p.FontWeight = 'bold';
p.HelpFcn = @(x,y) disp('Help me!');
iCaptureFigure( f, 'BoxPanel2' );

%% uiextras.BoxPanel HelpExample
f = iFigure( 'uiextras.BoxPanel Help Example' );
b = uiextras.HBox( 'Parent', f );
uiextras.BoxPanel( 'Parent', b, 'Title', 'sin', 'HelpFcn', @(a,b) doc('sin') );
uiextras.BoxPanel( 'Parent', b, 'Title', 'cos', 'HelpFcn', @(a,b) doc('cos') );
uiextras.BoxPanel( 'Parent', b, 'Title', 'tan', 'HelpFcn', @(a,b) doc('tan') );
iCaptureFigure( f, 'BoxPanelHelpExample' );

%% BoxPanel Minimize example
f = iFigure( 'Collapsable GUI Example' );
width = 200;
pheightmin = 20;
pheightmax = 100;
b = uiextras.VBox( 'Parent', f );

% Add three panels to the box
p = cell(1,3);
p{1} = uiextras.BoxPanel( 'Title', 'Panel 1', 'Parent', b );
p{2} = uiextras.BoxPanel( 'Title', 'Panel 2', 'Parent', b );
p{3} = uiextras.BoxPanel( 'Title', 'Panel 3', 'Parent', b );
set( b, 'Sizes', pheightmax*ones(1,3) );

% Add some contents
uicontrol( 'Style', 'PushButton', 'String', 'Button 1', 'Parent', p{1} );
uicontrol( 'Style', 'PushButton', 'String', 'Button 2', 'Parent', p{2} );
uicontrol( 'Style', 'PushButton', 'String', 'Button 3', 'Parent', p{3} );

% Resize the window
pos = get( f, 'Position' );
set( f, 'Position', [pos(1,1:2),width,sum(b.Sizes)] );

iCaptureFigure( f, 'BoxPanelMinimizeExample1' );

% Hook up the minimize callback
set( p{1}, 'MinimizeFcn', {@nMinimize, 1} );
set( p{2}, 'MinimizeFcn', {@nMinimize, 2} );
set( p{3}, 'MinimizeFcn', {@nMinimize, 3} );
iCaptureFigure( f, 'BoxPanelMinimizeExample2' );

% Now minimize one
nMinimize( [], [], 2 );
iCaptureFigure( f, 'BoxPanelMinimizeExample3' );


%% BoxPanel Dock example
f = iFigure( 'Dockable GUI Example' );
b = uiextras.HBox( 'Parent', f );

% Add three panels to the box
p = cell(1,3);
p{1} = uiextras.BoxPanel( 'Title', 'Panel 1', 'Parent', b );
p{2} = uiextras.BoxPanel( 'Title', 'Panel 2', 'Parent', b );
p{3} = uiextras.BoxPanel( 'Title', 'Panel 3', 'Parent', b );

% Add some contents
uicontrol( 'Style', 'PushButton', 'String', 'Button 1', 'Parent', p{1} );
uicontrol( 'Style', 'PushButton', 'String', 'Button 2', 'Parent', p{2} );
uicontrol( 'Style', 'PushButton', 'String', 'Button 3', 'Parent', p{3} );

iCaptureFigure( f, 'BoxPanelDockExample1' );

% Set the dock/undock callback
set( p{1}, 'DockFcn', {@nDock, 1} );
set( p{2}, 'DockFcn', {@nDock, 2} );
set( p{3}, 'DockFcn', {@nDock, 3} );
iCaptureFigure( f, 'BoxPanelDockExample2' );

% Now undock one
allfigs = findall( 0, 'type', 'figure' );
nDock( [], [], 2 );
newfig = setdiff( findall( 0, 'type', 'figure' ), allfigs );
iCaptureFigure( f, 'BoxPanelDockExample3' );
iCaptureFigure( newfig, 'BoxPanelDockExample4' );

%% Enable example
f = iFigure( 'Enable example', 'Position', [100 100 150 250] );
panel = uiextras.BoxPanel( 'Parent', f, 'Title', 'Panel' );
iCaptureFigure( f, 'EnableExample1' );

box = uiextras.VButtonBox( 'Parent', panel );
uicontrol( 'Parent', box, 'String', 'Button 1' );
uicontrol( 'Parent', box, 'String', 'Button 2' );
uicontrol( 'Parent', box, 'String', 'Button 3', 'Enable', 'off' );
uicontrol( 'Parent', box, 'String', 'Button 4' );
uicontrol( 'Parent', box, 'String', 'Button 5', 'Enable', 'off' );
uicontrol( 'Parent', box, 'String', 'Button 6' );
iCaptureFigure( f, 'EnableExample2' );

set( panel, 'Enable', 'off' );
iCaptureFigure( f, 'EnableExample3' );


%% Visible example
f = iFigure( 'Visible example', 'Position', [100 100 150 250] );
panel = uiextras.BoxPanel( 'Parent', f, 'Title', 'Panel' );
iCaptureFigure( f, 'VisibleExample1' );

box = uiextras.VButtonBox( 'Parent', panel );
uicontrol( 'Parent', box, 'String', 'Button 1' );
uicontrol( 'Parent', box, 'String', 'Button 2' );
uicontrol( 'Parent', box, 'String', 'Button 3', 'Visible', 'off' );
uicontrol( 'Parent', box, 'String', 'Button 4' );
uicontrol( 'Parent', box, 'String', 'Button 5', 'Visible', 'off' );
uicontrol( 'Parent', box, 'String', 'Button 6' );
iCaptureFigure( f, 'VisibleExample2' );

set( panel, 'Visible', 'off' );
iCaptureFigure( f, 'VisibleExample3' );


%% Defaults examples
f = iFigure( 'Defaults example' );
uiextras.set( f, 'DefaultHBoxBackgroundColor', [0.3 0.3 0.3] );
uiextras.set( f, 'DefaultBoxPanelTitleColor', 'y' );
uiextras.set( f, 'DefaultBoxPanelFontSize', 16 );
h = uiextras.HBox( 'Parent', f, 'Padding', 10, 'Spacing', 10 );
uiextras.BoxPanel( 'Parent', h, 'Title', 'Panel 1' );
uiextras.BoxPanel( 'Parent', h, 'Title', 'Panel 2' );
iCaptureFigure( f, 'DefaultsFigure' );


uiextras.set( 0, 'DefaultHBoxBackgroundColor', [0.3 0.3 0.3] );
uiextras.set( 0, 'DefaultBoxPanelTitleColor', 'y' );
uiextras.set( 0, 'DefaultBoxPanelFontSize', 14 );
f1 = iFigure( 'Defaults example 1' );
h = uiextras.HBox( 'Parent', f1, 'Padding', 10, 'Spacing', 10 );
p1 = uiextras.BoxPanel( 'Parent', h, 'Title', 'Panel 1' );
p2 = uiextras.BoxPanel( 'Parent', h, 'Title', 'Panel 2' );
iCaptureFigure( f1, 'DefaultsSystem1' );

f2 = iFigure( 'Defaults example 2' );
uiextras.set( f2, 'DefaultBoxPanelFontSize', 20 );
p3 = uiextras.BoxPanel( 'Parent', f2, 'Title', 'Panel 3' );
iCaptureFigure( f2, 'DefaultsSystem2' );

uiextras.unset( 0, 'DefaultHBoxBackgroundColor' );
uiextras.unset( 0, 'DefaultBoxPanelTitleColor' );
uiextras.unset( 0, 'DefaultBoxPanelFontSize' );


%% uiextras.TabPanel
f = iFigure( 'uiextras.BoxPanel example' );
p = uiextras.TabPanel( 'Parent', f, 'Padding', 5 );
uicontrol( 'Parent', p, 'Background', 'r' );
uicontrol( 'Parent', p, 'Background', 'b' );
uicontrol( 'Parent', p, 'Background', 'g' );
p.TabNames = {'Red', 'Blue', 'Green'};
p.SelectedChild = 2;
iCaptureFigure( f, 'TabPanel' );


%% uiextras.HBox
f = iFigure( 'uiextras.HBox example' );
b = uiextras.HBox( 'Parent', f );
uicontrol( 'Parent', b, 'Background', 'r' );
uicontrol( 'Parent', b, 'Background', 'b' );
uicontrol( 'Parent', b, 'Background', 'g' );
set( b, 'Sizes', [-1 100 -2], 'Spacing', 5 );
iCaptureFigure( f, 'HBox' );

%% uiextras.HBoxFlex
f = iFigure( 'uiextras.HBoxFlex example' );
b = uiextras.HBoxFlex( 'Parent', f );
uicontrol( 'Parent', b, 'Background', 'r' );
uicontrol( 'Parent', b, 'Background', 'b' );
uicontrol( 'Parent', b, 'Background', 'g' );
uicontrol( 'Parent', b, 'Background', 'y' );
set( b, 'Sizes', [-1 100 -2 -1], 'Spacing', 5 );
iCaptureFigure( f, 'HBoxFlex' );

%% HButtonBox
f = iFigure( 'uiextras.HBoxFlex example' );
b = uiextras.HButtonBox( 'Parent', f );
uicontrol( 'Parent', b, 'String', 'One' );
uicontrol( 'Parent', b, 'String', 'Two' );
uicontrol( 'Parent', b, 'String', 'Three' );
set( b, 'ButtonSize', [130 35], 'Spacing', 5 );
iCaptureFigure( f, 'HButtonBox' )

%% uiextras.VBox
f = iFigure( 'uiextras.VBox example' );
b = uiextras.VBox( 'Parent', f );
uicontrol( 'Parent', b, 'Background', 'r' );
uicontrol( 'Parent', b, 'Background', 'b' );
uicontrol( 'Parent', b, 'Background', 'g' );
set( b, 'Sizes', [-1 100 -2], 'Spacing', 5 );
iCaptureFigure( f, 'VBox' );

%% uiextras.VBoxFlex
f = iFigure( 'uiextras.VBoxFlex example' );
b = uiextras.VBoxFlex( 'Parent', f );
uicontrol( 'Parent', b, 'Background', 'r' )
uicontrol( 'Parent', b, 'Background', 'b' )
uicontrol( 'Parent', b, 'Background', 'g' )
uicontrol( 'Parent', b, 'Background', 'y' )
set( b, 'Sizes', [-1 100 -2 -1], 'Spacing', 5 );
iCaptureFigure( f, 'VBoxFlex' )

%% VButtonBox
f = iFigure( 'uiextras.VBoxFlex example' );
b = uiextras.VButtonBox( 'Parent', f );
uicontrol( 'Parent', b, 'String', 'One' );
uicontrol( 'Parent', b, 'String', 'Two' );
uicontrol( 'Parent', b, 'String', 'Three' );
set( b, 'ButtonSize', [130 35], 'Spacing', 5 );
iCaptureFigure( f, 'VButtonBox' )


%% Combining boxes
f = iFigure( 'Combining boxes example' );
b1 = uiextras.VBoxFlex( 'Parent', f );
uicontrol( 'Parent', b1, 'Background', 'r' )
b2 = uiextras.HBoxFlex( 'Parent', b1, 'Padding', 5, 'Spacing', 5 );
uicontrol( 'Parent', b2, 'String', 'Button1' )
uicontrol( 'Parent', b2, 'String', 'Button2' )
set( b1, 'Sizes', [-1 -1] );
iCaptureFigure( f, 'CombineBoxes' )

%% Combining boxes 2
f = iFigure( 'Boxes inside boxes example' );
b1 = uiextras.HBoxFlex( 'Parent', f, 'Spacing', 5 );

uicontrol( 'Parent', b1, 'Background', 'r' );
b2 = uiextras.VBoxFlex( 'Parent', b1, 'Spacing', 5 );
uicontrol( 'Parent', b1, 'Background', 'r' );

uicontrol( 'Parent', b2, 'Background', 'b' );
b3 = uiextras.HBoxFlex( 'Parent', b2, 'Spacing', 5 );
uicontrol( 'Parent', b2, 'Background', 'b' );

uicontrol( 'Parent', b3, 'Background', 'm' );
b4 = uiextras.VBoxFlex( 'Parent', b3, 'Spacing', 5 );
uicontrol( 'Parent', b3, 'Background', 'm' );

uicontrol( 'Parent', b4, 'Background', 'g' );
uiextras.Empty( 'Parent', b4 );
uicontrol( 'Parent', b4, 'Background', 'g' );
iCaptureFigure( f, 'BoxInBox' )

%% uiextras.Grid
f = iFigure( 'uiextras.Grid example' );
g = uiextras.Grid( 'Parent', f, 'Spacing', 5 );
uicontrol( 'Parent', g, 'Background', 'r' )
uicontrol( 'Parent', g, 'Background', 'b' )
uicontrol( 'Parent', g, 'Background', 'g' )
uiextras.Empty( 'Parent', g );
uicontrol( 'Parent', g, 'Background', 'c' )
uicontrol( 'Parent', g, 'Background', 'y' )
set( g, 'ColumnSizes', [-1 100 -2], 'RowSizes', [-1 100] );
iCaptureFigure( f, 'Grid' )

%% uiextras.GridFlex
f = iFigure( 'uiextras.GridFlex example' );
g = uiextras.GridFlex( 'Parent', f, 'Spacing', 5 );
uicontrol( 'Parent', g, 'Background', 'r' )
uicontrol( 'Parent', g, 'Background', 'b' )
uicontrol( 'Parent', g, 'Background', 'g' )
uiextras.Empty( 'Parent', g );
uicontrol( 'Parent', g, 'Background', 'c' )
uicontrol( 'Parent', g, 'Background', 'y' )
set( g, 'ColumnSizes', [-1 100 -2], 'RowSizes', [-2 -1] );
iCaptureFigure( f, 'GridFlex' )

%% uiextras.Border
% f = iFigure( 'uiextras.Border example' );
% g = uiextras.Border( 'Parent', f, 'Spacing', 5 );
% uicontrol( 'Parent', g, 'Background', 'r' )
% uicontrol( 'Parent', g, 'Background', 'b' )
% uicontrol( 'Parent', g, 'Background', 'g' )
% uicontrol( 'Parent', g, 'Background', 'c' )
% uicontrol( 'Parent', g, 'Background', 'y' )
% set( g, 'NorthSize', 30, 'SouthSize', 30 );
% iCaptureFigure( f, 'Border' )

%% uiextras.Empty
f = iFigure( 'uiextras.Empty example' );
p = uiextras.HBox( 'Parent', f, 'Padding', 5 );
uicontrol( 'Parent', p, 'Background', 'r' );
uiextras.Empty( 'Parent', p );
uicontrol( 'Parent', p, 'Background', 'b' );
iCaptureFigure( f, 'Empty' );


% close all;

%-------------------------------------------------------------------------%
    function f = iFigure( name, varargin )
        sz = 230;
        bgcol = hex2rgb('ddddee');
        f = figure( 'Name', name, ...
            'Color', bgcol, ...
            'MenuBar', 'none', ...
            'ToolBar', 'none', ...
            'NumberTitle', 'off', ...
            'Tag', 'layout:ExampleFigure', ...
            'Position', [50 50 sz sz] );
        set( f, 'DefaultUIContainerBackgroundColor', bgcol )
        set( f, 'DefaultUIPanelBackgroundColor', bgcol )
        set( f, 'DefaultUIControlBackgroundColor', bgcol )
        if nargin>1
            set( f, varargin{:} );
        end
    end


%-------------------------------------------------------------------------%
    function iCaptureFigure( figh, filename )
        figure( figh );
        drawnow();
        pos1 = get( figh, 'Position' );
        pos = get( figh, 'OuterPosition' );
        pos(1:2) = pos(1:2) - pos1(1:2) + [1 1];
        fr = getframe( figh, pos );
        imwrite( fr.cdata, fullfile( 'Images', [filename,'.png'] ) );
    end

%-------------------------------------------------------------------------%
    function nMinimize( src, evt, whichpanel ) %#ok<INUSL>
        % A panel has been maximized/minimized
        s = get(b,'Sizes');
        pos = get( f, 'Position' );
        p{whichpanel}.IsMinimized = ~p{whichpanel}.IsMinimized;
        if p{whichpanel}.IsMinimized
            s(whichpanel) = pheightmin;
        else
            s(whichpanel) = pheightmax;
        end
        set(b,'Sizes',s);
        
        % Resize the figure, keeping the top stationary
        delta_height = pos(1,4) - sum(b.Sizes);
        set( f, 'Position', pos(1,:) + [0 delta_height 0 -delta_height] );
    end % nMinimize
%-------------------------------------------------------------------------%
    function nDock( src, evt, whichpanel ) %#ok<INUSL>
        % Set the flag
        p{whichpanel}.IsDocked = ~p{whichpanel}.IsDocked;
        if p{whichpanel}.IsDocked
            % Put it back into the layout
            newfig = get( p{whichpanel}, 'Parent' );
            set( p{whichpanel}, 'Parent', b );
            delete( newfig );
        else
            % Take it out of the layout
            pos = getpixelposition( p{whichpanel} );
            newfig = figure( ...
                'Name', get( p{whichpanel}, 'Title' ), ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'CloseRequestFcn', {@nDock, whichpanel} );
            figpos = get( newfig, 'Position' );
            set( newfig, 'Position', [figpos(1,1:2), pos(1,3:4)] );
            set( p{whichpanel}, 'Parent', newfig, ...
                'Units', 'Normalized', ...
                'Position', [0 0 1 1] );
        end
    end % nDock

end % EOF