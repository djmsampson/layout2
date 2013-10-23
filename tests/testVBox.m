function test_suite = testVBox()
%testVBox  Unit tests for uiextras.VBox
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
% fprintf( 'uiextras.VBox: ' )
initTestSuite();



function testDefaultConstructor()
%testDefaultConstructor  Test constructing the widget with no arguments
close all force;
assertEqual( isa( uiextras.VBox(), 'uiextras.VBox' ), true );
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
    
assertEqual( isa( uiextras.VBox( args{:} ), 'uiextras.VBox' ), true );
close all force;


function testContents()
%testContents  Test adding and removing children
close all force;

h = uiextras.VBox();
assertEqual( isa( h, 'uiextras.VBox' ), true );

u = [
    uicontrol( 'Parent', h, 'BackgroundColor', 'r' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'g' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
    ];
assertEqual( h.Contents, u );

delete( u(2) )
assertEqual( h.Contents, u([1,3]) );


close all force;
