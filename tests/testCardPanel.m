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


function testContents()
%testContents  Test adding and removing children
close all force;

h = uiextras.CardPanel( 'Parent', figure() );
assertEqual( isa( h, 'uiextras.CardPanel' ), true );

u = [
    uicontrol( 'Parent', h, 'BackgroundColor', 'r' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'g' )
    uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
    ];
assertEqual( h.Contents, u );

delete( u(2) )
assertEqual( h.Contents, u([1,3]) );

h.SelectedChild = 1;

% Make sure the "selected" child is visible
assertEqual( u(1).Visible, 'on' )

% Make sure the "hidden" child is invisible
assertEqual( u(3).Visible, 'off' )

close all force;


function testAxesVisibility()
%testAxesVisibility  Test that axes children do not accidentally become
%visible when not selected
close all force;

cp = uiextras.CardPanel( 'Parent', figure() );
assertEqual( isa( cp, 'uiextras.CardPanel' ), true );

ax1 = axes( 'Parent', cp, 'Color', [0.9 0.9 1.0] );
ax2 = axes( 'Parent', cp, 'Color', [1.0 1.0 0.9] );

% Axes 2 should be visible, 1 should be invisible
cp.Selection = 2;
assertEqual( ax1.Visible, 'off' );
assertEqual( ax2.Visible, 'on' );

% Plotting can make axes visible again (g1100294)
plot( ax1, 1:10, 1:10 )
assertEqual( ax1.Visible, 'off' );
assertEqual( ax2.Visible, 'on' );



