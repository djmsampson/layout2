function test_suite = testCardPanel()
%testCardPanel  Unit tests for uiextras.CardPanel
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
% fprintf( 'uiextras.CardPanel: ' )
initTestSuite();



function testDefaultConstructor()
%testDefaultConstructor  Test constructing the widget with no arguments
close all force;
assertEqual( isa( uiextras.CardPanel(), 'uiextras.CardPanel' ), true );
close all force;


function testConstructionArguments()
%testConstructionArguments  Test constructing the widget with optional arguments
close all force;
args = {
    'Parent',          gcf()
    'Units',           'Pixels'
    'Position',        [10 10 400 400]
    'Padding',         5
    'Tag',             'Test'
    'Visible',         'on'
    }';
    
assertEqual( isa( uiextras.CardPanel( args{:} ), 'uiextras.CardPanel' ), true );
close all force;


function testChildren()
%testChildren  Test adding and removing children
close all force;

h = uiextras.CardPanel();
assertEqual( isa( h, 'uiextras.CardPanel' ), true );

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
assertEqual( pos(1:2), [1 1] );

% Make sure the "hidden" child is off-screen
pos = get( u(3), 'Position' );
assertEqual( all( pos(1:2) > 2000 ), true );

close all force;




