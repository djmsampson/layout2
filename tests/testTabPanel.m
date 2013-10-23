function test_suite = testTabPanel()
%testTabPanel  Unit tests for uiextras.TabPanel
%
%   This test suite requires Steve Eddin's xUnit testing framework to be
%   installed. Get it from the <a href="http://www.mathworks.com/matlabcentral/fileexchange/22846">File Exchange</a>.
%
%   Type "runtests" to run the test suite.

%   Copyright 2010 The MathWorks Ltd.
%   $Revision: 351 $    
%   $Date: 2010-10-25 09:35:28 +0100 (Mon, 25 Oct 2010) $

%#ok<*DEFNU> (ignore the unused subfunction warnings)

% Intialise xUnit
% fprintf( 'uiextras.TabPanel: ' )
initTestSuite();



function testDefaultConstructor()
%testDefaultConstructor  Test constructing the widget with no arguments
close all force;
assertEqual( isa( uiextras.TabPanel(), 'uiextras.TabPanel' ), true );
close all force;


function testConstructionArguments()
%testConstructionArguments  Test constructing the widget with optional arguments
close all force;
args = {
    'Parent',          gcf()
    'Units',           'Pixels'
    'Position',        [10 10 400 400]
    'FontAngle',       'normal'
    'FontName',        'Arial'
    'FontSize',        20
    'FontUnits',       'points'
    'FontWeight',      'bold'
    'ForegroundColor', [0 0 0.5]
    'HighlightColor',  [1 0.9 0.9]
    'ShadowColor',     [0.5 0.2 0.2]
    'Padding',         5
    'Tag',             'Test'
    'Visible',         'on'
    }';
    
assertEqual( isa( uiextras.TabPanel( args{:} ), 'uiextras.TabPanel' ), true );
close all force;


function testChildren()
%testChildren  Test adding and removing children
close all force;

h = uiextras.TabPanel( 'FontSize', 14 );
assertEqual( isa( h, 'uiextras.TabPanel' ), true );

u = [
    uicontrol( 'Parent', h, 'BackgroundColor', 'r' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'g' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
    ];
assertEqual( h.Children, u );

% Test tab-name setting
h.TabNames = {'Tab 1', 'Tab 2', 'Tab 3'};

delete( u(2) )
assertEqual( h.Children, u([1,3]) );

h.SelectedChild = 1;

% Make sure the "selected" child is on-screen
pos = get( u(1), 'Position' );
assertEqual( pos(1:2), [1 1] );

% Make sure the "hidden" child is off-screen
pos = get( u(3), 'Position' );
assertEqual( all( pos(1:2) > 2000 ), true );

close all force;
