function test_suite = testGrid()
%testGrid  Unit tests for uiextras.Grid
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
% fprintf( 'uiextras.Grid: ' )
initTestSuite();


function testDefaultConstructor()
%testDefaultConstructor  Test constructing the widget with no arguments
close all force;
assertEqual( isa( uiextras.Grid(), 'uiextras.Grid' ), true );
close all force;


function testConstructionArguments()
%testConstructionArguments  Test constructing the widget with optional arguments
close all force;
args = {
    'Parent',          gcf()
    'BackgroundColor', 'b'
    'Units',           'Pixels'
    'Position',        [10 10 400 400]
    'Padding',         5
    'Spacing',         5
    'Tag',             'Test'
    'Visible',         'on'
    }';
    
assertEqual( isa( uiextras.Grid( args{:} ), 'uiextras.Grid' ), true );
close all force;


function testChildren()
%testChildren  Test adding and removing children
close all force;

h = uiextras.Grid();
assertEqual( isa( h, 'uiextras.Grid' ), true );

u = [
    uicontrol( 'Parent', h, 'BackgroundColor', 'r' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'g' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'y' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'm' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'c' )
    ];
assertEqual( h.Children, u );

% Reshape
set( h, 'RowSizes', [-1 200], 'ColumnSizes', [-1 100 -1] )

delete( u(5) )
assertEqual( h.Children, u([1:4,6]) );


close all force;
