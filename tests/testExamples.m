function test_suite = testExamples()
%testExamples  Unit tests for the layout example applications
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
% fprintf( 'Examples: ' )
initTestSuite();
end % testDefaults


function testaxesexample()
oldDir = pwd();
cd( fullfile( layoutRoot, 'LayoutHelp', 'Examples' ) );

axesexample;

cd( oldDir );
end % testaxesexample

function testcallbackexample()
oldDir = pwd();
cd( fullfile( layoutRoot, 'LayoutHelp', 'Examples' ) );

callbackexample;

cd( oldDir );
end % testcallbackexample

function testdemoBrowser()
oldDir = pwd();
cd( fullfile( layoutRoot, 'LayoutHelp', 'Examples' ) );

demoBrowser;

cd( oldDir );
end % testdemoBrowser

function testdockexample()
oldDir = pwd();
cd( fullfile( layoutRoot, 'LayoutHelp', 'Examples' ) );

dockexample;

cd( oldDir );
end % testdockexample

function testenableexample()
oldDir = pwd();
cd( fullfile( layoutRoot, 'LayoutHelp', 'Examples' ) );

enableexample;

cd( oldDir );
end % testenableexample

function testgridflexpositioning()
oldDir = pwd();
cd( fullfile( layoutRoot, 'LayoutHelp', 'Examples' ) );

gridflexpositioning;

cd( oldDir );
end % testgridflexpositioning

function testheirarchyexample()
oldDir = pwd();
cd( fullfile( layoutRoot, 'LayoutHelp', 'Examples' ) );

heirarchyexample;

cd( oldDir );
end % testheirarchyexample

function testminimizeexample()
oldDir = pwd();
cd( fullfile( layoutRoot, 'LayoutHelp', 'Examples' ) );

minimizeexample;

cd( oldDir );
end % testminimizeexample

function testtabpanelexample()
oldDir = pwd();
cd( fullfile( layoutRoot, 'LayoutHelp', 'Examples' ) );

tabpanelexample;

cd( oldDir );
end % testtabpanelexample

function testvisibleexample()
oldDir = pwd();
cd( fullfile( layoutRoot, 'LayoutHelp', 'Examples' ) );

visibleexample;

cd( oldDir );
end % testvisibleexample

