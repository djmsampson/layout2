function test_suite = testBoxPanel()
%testBoxPanel  Unit tests for uiextras.BoxPanel
%
%   This test suite requires Steve Eddin's xUnit testing framework to be
%   installed. Get it from the <a href="http://www.mathworks.com/matlabcentral/fileexchange/22846">File Exchange</a>.
%
%   Type "runtests" to run the test suite.

%   Copyright 2010 The MathWorks Ltd.
%   $Revision: 383 $    
%   $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $

%#ok<*DEFNU> (ignore the unused subfunction warnings)

% Intialise xUnit
% fprintf( 'uiextras.BoxPanel: ' )
initTestSuite();



function testDefaultConstructor()
%testDefaultConstructor  Test constructing the widget with no arguments
close all force;
assertEqual( isa( uiextras.BoxPanel(), 'uiextras.BoxPanel' ), true );
close all force;


function testConstructionArguments()
%testConstructionArguments  Test constructing the widget with optional arguments
close all force;
args = {
    'Parent',          gcf()
    'Units',           'Pixels'
    'Position',        [10 10 400 400]
    'Title',           'A BoxPanel'
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
    
assertEqual( isa( uiextras.BoxPanel( args{:} ), 'uiextras.BoxPanel' ), true );
close all force;


function testBorderType()
%testBorderType  Test setting the border type
close all force;

% First set using the default
p = uiextras.BoxPanel('Title', 'My panel');

% Now test changing it
p.BorderType = 'etchedout';
assertEqual( get(p, 'BorderType'), 'etchedout' );


function testContents()
%testContents  Test adding and removing children
close all force;

h = uiextras.BoxPanel( 'Title', 'A BoxPanel' );
assertEqual( isa( h, 'uiextras.BoxPanel' ), true );

u = [
    uicontrol( 'Parent', h, 'BackgroundColor', 'r' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'g' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
    ];
assertEqual( h.Contents, u );

delete( u(2) )
assertEqual( h.Contents, u([1,3]) );

h.SelectedChild = 1;

close all force;




