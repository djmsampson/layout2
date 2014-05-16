function test_suite = testHButtonBox()
%testHButtonBox  Unit tests for uiextras.HButtonBox
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
% fprintf( 'uiextras.HButtonBox: ' )
initTestSuite();



function testDefaultConstructor()
%testDefaultConstructor  Test constructing the widget with no arguments
close all force;
assertEqual( isa( uiextras.HButtonBox(), 'uiextras.HButtonBox' ), true );
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
    'ButtonSize',      [200 25]
    'Tag',             'Test'
    'Visible',         'on'
    }';
    
assertEqual( isa( uiextras.HButtonBox( args{:} ), 'uiextras.HButtonBox' ), true );

% g1020336: check that the default alignment is correct
b = uiextras.HButtonBox();
assertEqual( b.HorizontalAlignment , 'center' );
assertEqual( b.VerticalAlignment , 'middle' );

close all force;


function testContents()
%testContents  Test adding and removing children
close all force;

h = uiextras.HButtonBox();
assertEqual( isa( h, 'uiextras.HButtonBox' ), true );

u = [
    uicontrol( 'Parent', h, 'BackgroundColor', 'r' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'g' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
    ];
assertEqual( h.Contents, u );

delete( u(2) )
assertEqual( h.Contents, u([1,3]) );
close all force;

