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
set( f, 'Position', [100 100 400 250] );
iCaptureFigure( f, 'axes_layout_example_1' );

hbox = uix.HBoxFlex('Parent', f, 'Spacing', 3);
axes1 = axes( 'Parent', hbox, ...
    'ActivePositionProperty', 'outerposition' );
axes2 = axes( 'Parent', hbox, ...
    'ActivePositionProperty', 'Position' );
% set( hbox, 'Widths', [-2 -1] );
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

%% Legend/ colorbar
f = iFigure( 'Axes legend and colorbars' );
set( f, 'Position', [100 100 400 400] );
iCaptureFigure( f, 'colorbar_example_1' );

hbox = uix.VBoxFlex('Parent', f, 'Spacing', 3);
axes1 = axes( 'Parent', uicontainer('Parent', hbox) );
axes2 = axes( 'Parent', uicontainer('Parent', hbox) );
iCaptureFigure( f, 'colorbar_example_2' );

surf( axes1, membrane( 1, 15 ) );
colorbar( axes1 );
theta = 0:360;
plot( axes2, theta, sind(theta), theta, cosd(theta) );
legend( axes2, 'sin', 'cos', 'Location', 'NorthWestOutside' );
iCaptureFigure( f, 'colorbar_example_3' );

%% Layout basics
f = iFigure( 'Basics' );
set( f, 'Position', [100 100 180 90] );
iCaptureFigure( f, 'basics_example1' );
layout = uix.HBox( 'Parent', f );

uicontrol( 'String', 'Button 1', 'Parent', layout );
iCaptureFigure( f, 'basics_example2' );
uicontrol( 'String', 'Button 2', 'Parent', layout );
iCaptureFigure( f, 'basics_example3' );
uicontrol( 'String', 'Button 3', 'Parent', layout );
iCaptureFigure( f, 'basics_example4' );

layout.Widths = [-1 -2 -1];
iCaptureFigure( f, 'basics_example5' );
layout.Widths = [80 -1 -1];
iCaptureFigure( f, 'basics_example6' );

f = iFigure( 'Basics' );
set( f, 'Position', [100 100 180 90] );
layout = uix.VBox( 'Parent', f );
uicontrol( 'String', 'Button 1', 'Parent', layout );
uicontrol( 'String', 'Button 2', 'Parent', layout );
uicontrol( 'String', 'Button 3', 'Parent', layout );
iCaptureFigure( f, 'basics_example_vbox' );

f = iFigure( 'Basics' );
set( f, 'Position', [100 100 180 90] );
layout = uix.TabPanel( 'Parent', f );
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
vbox = uix.VBox( 'Parent', f );
axes( 'Parent', vbox );
iCaptureFigure( f, 'why_layout0_1' );
hbox = uix.HButtonBox( 'Parent', vbox, 'Padding', 5 );
uicontrol( 'Parent', hbox, ...
    'String', 'Button 1' );
uicontrol( 'Parent', hbox, ...
    'String', 'Button 2' );
iCaptureFigure( f, 'why_layout0_2' );
% set( vbox, 'Heights', [-1 35] )
iCaptureFigure( f, 'why_layout1' );
set( f, 'Position', 250*ones(1,4) );
iCaptureFigure( f, 'why_layout2' );


%% uix.CardPanel
f = iFigure( 'uix.CardPanel example' );
p = uix.CardPanel( 'Parent', f, 'Padding', 5 );
uicontrol( 'Parent', p, 'Background', 'r' );
uicontrol( 'Parent', p, 'Background', 'b' );
uicontrol( 'Parent', p, 'Background', 'g' );
p.Selection = 2;
iCaptureFigure( f, 'CardPanel' );

%% uix.Panel
f = iFigure( 'uix.Panel example' );
p = uix.Panel( 'Parent', f, 'Title', 'A Panel', 'Padding', 5 );
uicontrol( 'Parent', p, 'Background', 'r' );
iCaptureFigure( f, 'Panel' );

%% uix.Panel 2
f = iFigure( 'uix.Panel example 2' );
p = uix.Panel( 'Parent', f, 'Title', 'A Panel', 'Padding', 5, 'TitlePosition', 'CenterTop' );
b = uix.HBox( 'Parent', p, 'Spacing', 5 );
uicontrol( 'Style', 'listbox', 'Parent', b, 'String', {'Item 1','Item 2'} );
uicontrol( 'Parent', b, 'Background', 'b' );
set( b, 'Widths', [60 -1] );
iCaptureFigure( f, 'Panel2' );

%% uix.BoxPanel
f = iFigure( 'uix.BoxPanel example' );
p = uix.BoxPanel( 'Parent', f, 'Title', 'A BoxPanel', 'Padding', 5 );
uicontrol( 'Parent', p, 'Background', 'r' );
iCaptureFigure( f, 'BoxPanel' );

%% uix.BoxPanel 2
f = iFigure( 'uix.BoxPanel example 2' );
p = uix.BoxPanel( 'Parent', f, 'Title', 'A BoxPanel', 'Padding', 5 );
b = uix.HBoxFlex( 'Parent', p, 'Spacing', 5 );
uicontrol( 'Style', 'listbox', 'Parent', b, 'String', {'Item 1','Item 2'} );
uicontrol( 'Parent', b, 'Background', 'b' );
set( b, 'Widths', [-1 -3] );
p.FontSize = 12;
p.FontWeight = 'bold';
p.HelpFcn = @(x,y) disp('Help me!');
iCaptureFigure( f, 'BoxPanel2' );

%% uix.BoxPanel HelpExample
f = iFigure( 'uix.BoxPanel Help Example' );
b = uix.HBox( 'Parent', f );
uix.BoxPanel( 'Parent', b, 'Title', 'sin', 'HelpFcn', @(a,b) doc('sin') );
uix.BoxPanel( 'Parent', b, 'Title', 'cos', 'HelpFcn', @(a,b) doc('cos') );
uix.BoxPanel( 'Parent', b, 'Title', 'tan', 'HelpFcn', @(a,b) doc('tan') );
iCaptureFigure( f, 'BoxPanelHelpExample' );

%% BoxPanel Minimize example
f = iFigure( 'Collapsable GUI Example' );
width = 200;
pheightmin = 20;
pheightmax = 100;
b = uix.VBox( 'Parent', f );

% Add three panels to the box
p = cell(1,3);
p{1} = uix.BoxPanel( 'Title', 'Panel 1', 'Parent', b );
p{2} = uix.BoxPanel( 'Title', 'Panel 2', 'Parent', b );
p{3} = uix.BoxPanel( 'Title', 'Panel 3', 'Parent', b );
set( b, 'Heights', pheightmax*ones(1,3) );

% Add some contents
uicontrol( 'Style', 'PushButton', 'String', 'Button 1', 'Parent', p{1} );
uicontrol( 'Style', 'PushButton', 'String', 'Button 2', 'Parent', p{2} );
uicontrol( 'Style', 'PushButton', 'String', 'Button 3', 'Parent', p{3} );

% Resize the window
pos = get( f, 'Position' );
set( f, 'Position', [pos(1,1:2),width,sum(b.Heights)] );

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
b = uix.HBox( 'Parent', f );

% Add three panels to the box
p = cell(1,3);
p{1} = uix.BoxPanel( 'Title', 'Panel 1', 'Parent', b );
p{2} = uix.BoxPanel( 'Title', 'Panel 2', 'Parent', b );
p{3} = uix.BoxPanel( 'Title', 'Panel 3', 'Parent', b );

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
% f = iFigure( 'Enable example', 'Position', [100 100 150 250] );
% panel = uix.BoxPanel( 'Parent', f, 'Title', 'Panel' );
% iCaptureFigure( f, 'EnableExample1' );
% 
% box = uix.VButtonBox( 'Parent', panel );
% uicontrol( 'Parent', box, 'String', 'Button 1' );
% uicontrol( 'Parent', box, 'String', 'Button 2' );
% uicontrol( 'Parent', box, 'String', 'Button 3', 'Enable', 'off' );
% uicontrol( 'Parent', box, 'String', 'Button 4' );
% uicontrol( 'Parent', box, 'String', 'Button 5', 'Enable', 'off' );
% uicontrol( 'Parent', box, 'String', 'Button 6' );
% iCaptureFigure( f, 'EnableExample2' );
% 
% set( panel, 'Enable', 'off' );
% iCaptureFigure( f, 'EnableExample3' );


%% Visible example
f = iFigure( 'Visible example', 'Position', [100 100 150 250] );
panel = uix.BoxPanel( 'Parent', f, 'Title', 'Panel' );
iCaptureFigure( f, 'VisibleExample1' );

box = uix.VButtonBox( 'Parent', panel );
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
% f = iFigure( 'Defaults example' );
% uix.set( f, 'DefaultHBoxBackgroundColor', [0.3 0.3 0.3] );
% uix.set( f, 'DefaultBoxPanelTitleColor', 'y' );
% uix.set( f, 'DefaultBoxPanelFontSize', 16 );
% h = uix.HBox( 'Parent', f, 'Padding', 10, 'Spacing', 10 );
% uix.BoxPanel( 'Parent', h, 'Title', 'Panel 1' );
% uix.BoxPanel( 'Parent', h, 'Title', 'Panel 2' );
% iCaptureFigure( f, 'DefaultsFigure' );
% 
% 
% uix.set( 0, 'DefaultHBoxBackgroundColor', [0.3 0.3 0.3] );
% uix.set( 0, 'DefaultBoxPanelTitleColor', 'y' );
% uix.set( 0, 'DefaultBoxPanelFontSize', 14 );
% f1 = iFigure( 'Defaults example 1' );
% h = uix.HBox( 'Parent', f1, 'Padding', 10, 'Spacing', 10 );
% p1 = uix.BoxPanel( 'Parent', h, 'Title', 'Panel 1' );
% p2 = uix.BoxPanel( 'Parent', h, 'Title', 'Panel 2' );
% iCaptureFigure( f1, 'DefaultsSystem1' );
% 
% f2 = iFigure( 'Defaults example 2' );
% uix.set( f2, 'DefaultBoxPanelFontSize', 20 );
% p3 = uix.BoxPanel( 'Parent', f2, 'Title', 'Panel 3' );
% iCaptureFigure( f2, 'DefaultsSystem2' );
% 
% uix.unset( 0, 'DefaultHBoxBackgroundColor' );
% uix.unset( 0, 'DefaultBoxPanelTitleColor' );
% uix.unset( 0, 'DefaultBoxPanelFontSize' );


%% uix.TabPanel
f = iFigure( 'uix.BoxPanel example' );
p = uix.TabPanel( 'Parent', f, 'Padding', 5 );
uicontrol( 'Parent', p, 'Background', 'r' );
uicontrol( 'Parent', p, 'Background', 'b' );
uicontrol( 'Parent', p, 'Background', 'g' );
p.TabTitles = {'Red', 'Blue', 'Green'};
p.Selection = 2;
iCaptureFigure( f, 'TabPanel' );


%% uix.HBox
f = iFigure( 'uix.HBox example' );
b = uix.HBox( 'Parent', f );
uicontrol( 'Parent', b, 'Background', 'r' );
uicontrol( 'Parent', b, 'Background', 'b' );
uicontrol( 'Parent', b, 'Background', 'g' );
set( b, 'Widths', [-1 100 -2], 'Spacing', 5 );
iCaptureFigure( f, 'HBox' );

%% uix.HBoxFlex
f = iFigure( 'uix.HBoxFlex example' );
b = uix.HBoxFlex( 'Parent', f );
uicontrol( 'Parent', b, 'Background', 'r' );
uicontrol( 'Parent', b, 'Background', 'b' );
uicontrol( 'Parent', b, 'Background', 'g' );
uicontrol( 'Parent', b, 'Background', 'y' );
set( b, 'Widths', [-1 100 -2 -1], 'Spacing', 5 );
iCaptureFigure( f, 'HBoxFlex' );

%% HButtonBox
f = iFigure( 'uix.HBoxFlex example' );
b = uix.HButtonBox( 'Parent', f );
uicontrol( 'Parent', b, 'String', 'One' );
uicontrol( 'Parent', b, 'String', 'Two' );
uicontrol( 'Parent', b, 'String', 'Three' );
set( b, 'ButtonSize', [130 35], 'Spacing', 5 );
iCaptureFigure( f, 'HButtonBox' )

%% uix.VBox
f = iFigure( 'uix.VBox example' );
b = uix.VBox( 'Parent', f );
uicontrol( 'Parent', b, 'Background', 'r' );
uicontrol( 'Parent', b, 'Background', 'b' );
uicontrol( 'Parent', b, 'Background', 'g' );
set( b, 'Heights', [-1 100 -2], 'Spacing', 5 );
iCaptureFigure( f, 'VBox' );

%% uix.VBoxFlex
f = iFigure( 'uix.VBoxFlex example' );
b = uix.VBoxFlex( 'Parent', f );
uicontrol( 'Parent', b, 'Background', 'r' )
uicontrol( 'Parent', b, 'Background', 'b' )
uicontrol( 'Parent', b, 'Background', 'g' )
uicontrol( 'Parent', b, 'Background', 'y' )
set( b, 'Heights', [-1 100 -2 -1], 'Spacing', 5 );
iCaptureFigure( f, 'VBoxFlex' )

%% VButtonBox
f = iFigure( 'uix.VBoxFlex example' );
b = uix.VButtonBox( 'Parent', f );
uicontrol( 'Parent', b, 'String', 'One' );
uicontrol( 'Parent', b, 'String', 'Two' );
uicontrol( 'Parent', b, 'String', 'Three' );
set( b, 'ButtonSize', [130 35], 'Spacing', 5 );
iCaptureFigure( f, 'VButtonBox' )


%% Combining boxes
f = iFigure( 'Combining boxes example' );
b1 = uix.VBoxFlex( 'Parent', f );
uicontrol( 'Parent', b1, 'Background', 'r' )
b2 = uix.HBoxFlex( 'Parent', b1, 'Padding', 5, 'Spacing', 5 );
uicontrol( 'Parent', b2, 'String', 'Button1' )
uicontrol( 'Parent', b2, 'String', 'Button2' )
set( b1, 'Heights', [-1 -1] );
iCaptureFigure( f, 'CombineBoxes' )

%% Combining boxes 2
% f = iFigure( 'Boxes inside boxes example' );
% b1 = uix.HBoxFlex( 'Parent', f, 'Spacing', 5 );
% 
% uicontrol( 'Parent', b1, 'Background', 'r' );
% b2 = uix.VBoxFlex( 'Parent', b1, 'Spacing', 5 );
% uicontrol( 'Parent', b1, 'Background', 'r' );
% 
% uicontrol( 'Parent', b2, 'Background', 'b' );
% b3 = uix.HBoxFlex( 'Parent', b2, 'Spacing', 5 );
% uicontrol( 'Parent', b2, 'Background', 'b' );
% 
% uicontrol( 'Parent', b3, 'Background', 'm' );
% b4 = uix.VBoxFlex( 'Parent', b3, 'Spacing', 5 );
% uicontrol( 'Parent', b3, 'Background', 'm' );
% 
% uicontrol( 'Parent', b4, 'Background', 'g' );
% uix.Empty( 'Parent', b4 );
% uicontrol( 'Parent', b4, 'Background', 'g' );
% iCaptureFigure( f, 'BoxInBox' )

%% uix.Grid
% f = iFigure( 'uix.Grid example' );
% g = uix.Grid( 'Parent', f, 'Spacing', 5 );
% uicontrol( 'Parent', g, 'Background', 'r' )
% uicontrol( 'Parent', g, 'Background', 'b' )
% uicontrol( 'Parent', g, 'Background', 'g' )
% uix.Empty( 'Parent', g );
% uicontrol( 'Parent', g, 'Background', 'c' )
% uicontrol( 'Parent', g, 'Background', 'y' )
% set( g, 'Widths', [-1 100 -2], 'Heights', [-1 100] );
% iCaptureFigure( f, 'Grid' )

%% uix.GridFlex
% f = iFigure( 'uix.GridFlex example' );
% g = uix.GridFlex( 'Parent', f, 'Spacing', 5 );
% uicontrol( 'Parent', g, 'Background', 'r' )
% uicontrol( 'Parent', g, 'Background', 'b' )
% uicontrol( 'Parent', g, 'Background', 'g' )
% uix.Empty( 'Parent', g );
% uicontrol( 'Parent', g, 'Background', 'c' )
% uicontrol( 'Parent', g, 'Background', 'y' )
% set( g, 'Widths', [-1 100 -2], 'Heights', [-2 -1] );
% iCaptureFigure( f, 'GridFlex' )

%% uix.Border
% f = iFigure( 'uix.Border example' );
% g = uix.Border( 'Parent', f, 'Spacing', 5 );
% uicontrol( 'Parent', g, 'Background', 'r' )
% uicontrol( 'Parent', g, 'Background', 'b' )
% uicontrol( 'Parent', g, 'Background', 'g' )
% uicontrol( 'Parent', g, 'Background', 'c' )
% uicontrol( 'Parent', g, 'Background', 'y' )
% set( g, 'NorthSize', 30, 'SouthSize', 30 );
% iCaptureFigure( f, 'Border' )

%% uix.Empty
% f = iFigure( 'uix.Empty example' );
% p = uix.HBox( 'Parent', f, 'Padding', 5 );
% uicontrol( 'Parent', p, 'Background', 'r' );
% uix.Empty( 'Parent', p );
% uicontrol( 'Parent', p, 'Background', 'b' );
% iCaptureFigure( f, 'Empty' );


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
            'Position', [100 100 sz sz] );
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
        pos(1:2) = pos(1:2) - pos1(1:2); % + [1 1];
        fr = getframe( figh, pos );
        imwrite( fr.cdata, fullfile( 'Images', [filename,'.png'] ) );
    end

%-------------------------------------------------------------------------%
    function nMinimize( src, evt, whichpanel ) %#ok<INUSL>
        % A panel has been maximized/minimized
        s = get(b,'Heights');
        pos = get( f, 'Position' );
        p{whichpanel}.Minimized = ~p{whichpanel}.Minimized;
        if p{whichpanel}.Minimized
            s(whichpanel) = pheightmin;
        else
            s(whichpanel) = pheightmax;
        end
        set(b,'Heights',s);
        
        % Resize the figure, keeping the top stationary
        delta_height = pos(1,4) - sum(b.Heights);
        set( f, 'Position', pos(1,:) + [0 delta_height 0 -delta_height] );
    end % nMinimize
%-------------------------------------------------------------------------%
    function nDock( src, evt, whichpanel ) %#ok<INUSL>
        % Set the flag
        p{whichpanel}.Docked = ~p{whichpanel}.Docked;
        if p{whichpanel}.Docked
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