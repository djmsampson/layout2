function test_suite = testAxesHandling()
%testAxesHandling  Test that axes get positioned properly
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
% fprintf( 'axes: ' )
initTestSuite();



function testAxesPosition()
%testAxesPosition  Test that axes get positioned properly
close all force;

h = uiextras.HBox( 'Units', 'Pixels', 'Position', [1 1 500 500] );
ax1 = axes( 'Parent', h, 'ActivePositionProperty', 'OuterPosition', 'Units', 'Pixels' );

ax2 = axes( 'Parent', h, 'ActivePositionProperty', 'Position', 'Units', 'Pixels' );

% Check that the legend doesn't appear as a child
assertEqual( h.Children, [ax1;ax2] );

% Check that the axes sizes are correct
assertEqual( get( ax1, 'OuterPosition' ), [1 1 250 500] );
assertEqual( get( ax2, 'Position' ), [251 1 250 500] );

close all force;


function testAxesLegend()
%testAxesLegend  Test that axes legends are ignored properly
close all force;

h = uiextras.HBox( 'Units', 'Pixels', 'Position', [1 1 500 500] );
ax1 = axes( 'Parent', h, 'ActivePositionProperty', 'OuterPosition', 'Units', 'Pixels' );
plot( ax1, peaks(7) )
axis( ax1, 'tight' )
legend( 'line 1', 'line 2', 'line 3', 'line 4', 'line 5', 'line 6', 'line 7' )

ax2 = axes( 'Parent', h, 'ActivePositionProperty', 'Position', 'Units', 'Pixels' );
imagesc( peaks(7), 'Parent', ax2 );
axis( ax2, 'off' )

% Check that the legend doesn't appear as a child
assertEqual( h.Children, [ax1;ax2] );

close all force;

%% XXX This doesn't work rigtht now. Not sure why.
% function testAxesColorbar()
% %testAxesColorbar  Test that axes colorbars are ignored properly
% close all force;
% 
% h = uiextras.HBox( 'Units', 'Pixels', 'Position', [1 1 500 500] );
% ax1 = axes( 'Parent', h, 'ActivePositionProperty', 'OuterPosition', 'Units', 'Pixels' );
% contourf( ax1, peaks(30) )
% axis( ax1, 'tight' )
% colorbar( 'peer', ax1, 'location', 'EastOutside' )
% 
% ax2 = axes( 'Parent', h, 'ActivePositionProperty', 'Position', 'Units', 'Pixels' );
% imagesc( peaks(7), 'Parent', ax2 );
% axis( ax2, 'off' )
% 
% % Check that the legend doesn't appear as a child
% assertEqual( h.Children, [ax1;ax2] );
% 
% close all force;
