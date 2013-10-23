function test_suite = testGridFlex()
%testGridFlex  Unit tests for uiextras.GridFlex
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
% fprintf( 'uiextras.GridFlex: ' )
initTestSuite();


function testDefaultConstructor()
%testDefaultConstructor  Test constructing the widget with no arguments
close all force;
assertEqual( isa( uiextras.GridFlex(), 'uiextras.GridFlex' ), true );
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
    'ShowMarkings',    'on'
    }';
    
assertEqual( isa( uiextras.GridFlex( args{:} ), 'uiextras.GridFlex' ), true );
close all force;


function testContents()
%testContents  Test adding and removing children
close all force;

h = uiextras.GridFlex();
assertEqual( isa( h, 'uiextras.GridFlex' ), true );

u = [
    uicontrol( 'Parent', h, 'BackgroundColor', 'r' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'g' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'y' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'm' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'c' )
    ];
assertEqual( h.Contents, u );

% Reshape
set( h, 'RowSizes', [-1 200], 'ColumnSizes', [-1 100 -1] )

delete( u(5) )
assertEqual( h.Contents, u([1:4,6]) );


close all force;
