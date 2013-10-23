function test_suite = testPanel()
%testPanel  Unit tests for uiextras.Panel
%
%   This test suite requires Steve Eddin's xUnit testing framework to be
%   installed. Get it from the <a href="http://www.mathworks.com/matlabcentral/fileexchange/22846">File Exchange</a>.
%
%   Type "runtests" to run the test suite.

%   Copyright 2010 The MathWorks Ltd.
%   $Revision: 360 $    
%   $Date: 2011-02-07 15:26:56 +0000 (Mon, 07 Feb 2011) $

%#ok<*DEFNU> (ignore the unused subfunction warnings)

% Intialise xUnit
% fprintf( 'uiextras.Panel: ' )
initTestSuite();



function testDefaultConstructor()
%testDefaultConstructor  Test constructing the widget with no arguments
close all force;
assertEqual( isa( uiextras.Panel(), 'uiextras.Panel' ), true );
close all force;


function testConstructionArguments()
%testConstructionArguments  Test constructing the widget with optional arguments
close all force;
args = {
    'Parent',          gcf()
    'Units',           'Pixels'
    'Position',        [10 10 400 400]
    'Title',           'A panel'
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
    
assertEqual( isa( uiextras.Panel( args{:} ), 'uiextras.Panel' ), true );
close all force;


function testChildren()
%testChildren  Test adding and removing children
close all force;

h = uiextras.Panel( 'Title', 'A panel' );
assertEqual( isa( h, 'uiextras.Panel' ), true );

u = [
    uicontrol( 'Parent', h, 'BackgroundColor', 'r' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'g' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
    ];
assertEqual( h.Children, u );

delete( u(2) )
assertEqual( h.Children, u([1,3]) );

h.SelectedChild = 1;

% Make sure the "selected" child is on-screen
pos = get( u(1), 'Position' );
assertEqual( all( pos(1:2) < [10 10] ), true );

% Make sure the "hidden" child is off-screen
pos = get( u(3), 'Position' );
assertEqual( all( pos(1:2) > 2000 ), true );

close all force;




