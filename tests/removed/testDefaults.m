function test_suite = testDefaults()
%testDefaults  Unit tests for uiextras.setDefualt/getDefault
%
%   This test suite requires Steve Eddin's xUnit testing framework to be
%   installed. Get it from the <a href="http://www.mathworks.com/matlabcentral/fileexchange/22846">File Exchange</a>.
%
%   Type "runtests" to run the test suite.

%   Copyright 2010 The MathWorks Ltd.
%   $Revision: 294 $
%   $Date: 2010-07-15 14:18:48 +0100 (Thu, 15 Jul 2010) $

%#ok<*DEFNU> (ignore the unused subfunction warnings)

% Intialise xUnit
% fprintf( 'uiextras.setDefault: ' )
initTestSuite();
end % testDefaults

%% General
function testSettingGetting()
%testDefaultConstructor  Test basic setting and getting of a property
close all force;
col1 = 'r';
col2 = 'g';
uiextras.set( 0, 'DefaultVBoxBackgroundColor', col1 );
newcol = uiextras.get( 0, 'DefaultVBoxBackgroundColor' );
assertEqual( newcol, col1 );

% Now test that a figure etc inherits this correctly
f = figure();
u = uipanel( 'Parent', f );
newcol = uiextras.get( u, 'DefaultVBoxBackgroundColor' );
assertEqual( newcol, col1 );

% If the figure version changes, the panel shuold see this
uiextras.set( f, 'DefaultVBoxBackgroundColor', col2 );
newcol = uiextras.get( u, 'DefaultVBoxBackgroundColor' );
assertEqual( newcol, col2 );

% New figures should retain the base version
f2 = figure();
newcol = uiextras.get( f2, 'DefaultVBoxBackgroundColor' );
assertEqual( newcol, col1 );

% Clear the settings
uiextras.unset( 0, 'DefaultVBoxBackgroundColor' );

close all force;
end % testSettingGetting

%% Panels
function testBoxPanel()
%testBoxPanel  Test that defaults are obeyed by BoxPanel
props = {
    'BackgroundColor', [0 1 1]
    'ForegroundColor', [1 0 1]
    'HighlightColor',  [1 1 0]
    'ShadowColor',     [0 1 0]
    'Padding',         2
    'FontAngle',       'italic'
    'FontName',        'Arial'
    'FontSize',        20
    'FontUnits',       'pixels'
    'FontWeight',      'demi'
    };
doPropertyCheck( 'uiextras.BoxPanel', props );
end % testBoxPanel


function testTabPanel()
%testTabPanel  Test that defaults are obeyed by TabPanel
props = {
    'BackgroundColor', [0 1 1]
    'ForegroundColor', [1 0 1]
    'HighlightColor',  [1 1 0]
    'ShadowColor',     [0 1 0]
    'Padding',         2
    'FontAngle',       'italic'
    'FontName',        'Arial'
    'FontSize',        20
    'FontUnits',       'pixels'
    'FontWeight',      'demi'
    'TabPosition',     'Bottom'
    'TabSize',         100
    };
doPropertyCheck( 'uiextras.TabPanel', props );
end % testTabPanel

function testPanel()
%testPanel  Test that defaults are obeyed by Panel
props = {
    'BackgroundColor', [0 1 1]
    'ForegroundColor', [1 0 1]
    'HighlightColor',  [1 1 0]
    'ShadowColor',     [0 1 0]
    'Padding',         2
    'FontAngle',       'italic'
    'FontName',        'Arial'
    'FontSize',        20
    'FontUnits',       'pixels'
    'FontWeight',      'demi'
    'TitlePosition',   'righttop'
    'BorderType',      'etchedout'
    'BorderWidth',     5
    };
doPropertyCheck( 'uiextras.Panel', props );
end % testPanel

function testCardPanel()
%testCardPanel  Test that defaults are obeyed by CardPanel
props = {
    'BackgroundColor', [0 1 1]
    'Padding',         2
    };
doPropertyCheck( 'uiextras.CardPanel', props );
end % testCardPanel


%% Boxes
function testHBox()
%testHBox  Test that defaults are obeyed by HBox
props = {
    'BackgroundColor', [0 1 1]
    'Padding',         2
    'Spacing',         3
    };
doPropertyCheck( 'uiextras.HBox', props );
end % testHBox


function testVBox()
%testVBox  Test that defaults are obeyed by VBox
props = {
    'BackgroundColor', [0 1 1]
    'Padding',         2
    'Spacing',         3
    };
doPropertyCheck( 'uiextras.VBox', props );
end % testVBox


function testHBoxFlex()
%testHBoxFlex  Test that defaults are obeyed by HBoxFlex
props = {
    'BackgroundColor', [0 1 1]
    'Padding',         2
    'Spacing',         3
    'ShowMarkings',    'off'
    };
doPropertyCheck( 'uiextras.HBoxFlex', props );
end % testHBoxFlex


function testVBoxFlex()
%testVBoxFlex  Test that defaults are obeyed by VBoxFlex
props = {
    'BackgroundColor', [0 1 1]
    'Padding',         2
    'Spacing',         3
    'ShowMarkings',    'off'
    };
doPropertyCheck( 'uiextras.VBoxFlex', props );
end % testVBoxFlex


function testHButtonBox()
%testHBox  Test that defaults are obeyed by HBox
props = {
    'BackgroundColor',    [0 1 1]
    'Padding',            2
    'Spacing',            3
    'ButtonSize',         [123 34]
    'HorizontalAlignment' 'right'
    'VerticalAlignment'   'bottom'
    };
doPropertyCheck( 'uiextras.HButtonBox', props );
end % testHButtonBox


function testVButtonBox()
%testVBox  Test that defaults are obeyed by VBox
props = {
    'BackgroundColor', [0 1 1]
    'Padding',         2
    'Spacing',         3
    'ButtonSize',      [123 34]
    'HorizontalAlignment' 'right'
    'VerticalAlignment'   'bottom'
    };
doPropertyCheck( 'uiextras.VButtonBox', props );
end % testVButtonBox


%% Grids
function testGrid()
%testGrid  Test that defaults are obeyed by Grid
props = {
    'BackgroundColor', [0 1 1]
    'Padding',         2
    'Spacing',         3
    };
doPropertyCheck( 'uiextras.Grid', props );
end % testGrid


function testGridFlex()
%testGridFlex  Test that defaults are obeyed by GridFlex
props = {
    'BackgroundColor', [0 1 1]
    'Padding',         2
    'Spacing',         3
    'ShowMarkings',    'off'
    };
doPropertyCheck( 'uiextras.GridFlex', props );
end % testGridFlex


%% Helper functions
function doPropertyCheck( name, props )
% Set properties
close all force;
f = figure();
if strncmpi( name, 'uiextras.', 9 )
    shortName = name(10:end);
else
    shortName = name;
end
for pp=1:size( props, 1 )
    uiextras.set( f, ['Default',shortName,props{pp,1}], props{pp,2} )
end

% Create widget
b = feval( name, 'Parent', f );

% Check properties
for pp=1:size( props, 1 )
    assertEqual( b.(props{pp,1}), props{pp,2} );
end
close all force;
end % doPropertyCheck

