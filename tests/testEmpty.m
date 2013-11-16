function test_suite = testEmpty()
%testEmpty  Unit tests for uiextras.Empty
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
% fprintf( 'uiextras.Empty: ' )
initTestSuite();



function testDefaultConstructor()
%testDefaultConstructor  Test constructing the widget with no arguments
close all force;
assertEqual( isa( uiextras.Empty(), 'matlab.ui.control.StyleControl' ), true );
close all force;


function testConstructionArguments()
%testConstructionArguments  Test constructing the widget with optional arguments
close all force;
args = {
    'Parent',          gcf()
    'Tag',             'Test'
    'Visible',         'on'
    }';
    
assertEqual( isa( uiextras.Empty( args{:} ), 'matlab.ui.control.StyleControl' ), true );
close all force;


function testPositioning()
%testChildren  Test adding and removing children
close all force;

h = uiextras.HBox( 'Parent', figure, 'Units', 'Pixels', 'Position', [1 1 500 500] );
assertEqual( isa( h, 'uiextras.HBox' ), true );

e = uiextras.Empty( 'Parent', h );
uicontrol( 'Parent', h, 'BackgroundColor', 'b' )

assertEqual( e.Position, [1 1 250 500] );
close all force;


