function test_suite = testHBox()
%testHBox  Unit tests for uiextras.HBox
%
%   This test suite requires Steve Eddin's xUnit testing framework to be
%   installed. Get it from the <a href="http://www.mathworks.com/matlabcentral/fileexchange/22846">File Exchange</a>.
%
%   Type "runtests" to run the test suite.

%   Copyright 2010 The MathWorks Ltd.
%   $Revision: 382 $    
%   $Date: 2013-04-24 19:42:02 +0100 (Wed, 24 Apr 2013) $

%#ok<*DEFNU> (ignore the unused subfunction warnings)

% Intialise xUnit
% fprintf( 'uiextras.HBox: ' )
initTestSuite();



function testDefaultConstructor()
%testDefaultConstructor  Test constructing the widget with no arguments
close all force;
assertEqual( isa( uiextras.HBox(), 'uiextras.HBox' ), true );
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
    
assertEqual( isa( uiextras.HBox( args{:} ), 'uiextras.HBox' ), true );
close all force;


function testChildren()
%testChildren  Test adding and removing children
close all force;

h = uiextras.HBox();
assertEqual( isa( h, 'uiextras.HBox' ), true );

u = [
    uicontrol( 'Parent', h, 'BackgroundColor', 'r' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'g' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
    ];
assertEqual( h.Children, u );

% Delete a child
delete( u(2) )
assertEqual( h.Children, u([1,3]) );

% Reparent a child
set( u(3), 'Parent', figure )
assertEqual( h.Children, u(1) );

close all force;


