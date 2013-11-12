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
cd( demoroot() );
try
    
    axesexample;
    
    cd( oldDir );
catch e
    cd( oldDir );
    e.rethrow()
end
end % testaxesexample

function testcallbackexample()
oldDir = pwd();
cd( demoroot() );
try
    
    callbackexample;
    
    cd( oldDir );
catch e
    cd( oldDir );
    e.rethrow()
end
end % testcallbackexample

function testdemoBrowser()
oldDir = pwd();
cd( demoroot() );
try
    
    demoBrowser;
    
    cd( oldDir );
catch e
    cd( oldDir );
    e.rethrow()
end
end % testdemoBrowser

function testdockexample()
oldDir = pwd();
cd( demoroot() );
try
    
    dockexample;
    
    cd( oldDir );
catch e
    cd( oldDir );
    e.rethrow()
end
end % testdockexample

function testenableexample()
oldDir = pwd();
cd( demoroot() );
try
    
    enableexample;
    
    cd( oldDir );
catch e
    cd( oldDir );
    e.rethrow()
end
end % testenableexample

function testgridflexpositioning()
oldDir = pwd();
cd( demoroot() );
try
    
    gridflexpositioning;
    
    cd( oldDir );
catch e
    cd( oldDir );
    e.rethrow()
end
end % testgridflexpositioning

function testheirarchyexample()
oldDir = pwd();
cd( demoroot() );
try
    
    heirarchyexample;
    
    cd( oldDir );
catch e
    cd( oldDir );
    e.rethrow()
end
end % testheirarchyexample

function testminimizeexample()
oldDir = pwd();
cd( demoroot() );
try
    
    minimizeexample;
    
    cd( oldDir );
catch e
    cd( oldDir );
    e.rethrow()
end
end % testminimizeexample

function testtabpanelexample()
oldDir = pwd();
cd( demoroot() );
try
    
    tabpanelexample;
    
    cd( oldDir );
catch e
    cd( oldDir );
    e.rethrow()
end
end % testtabpanelexample

function testvisibleexample()
oldDir = pwd();
cd( demoroot() );
try
    
    visibleexample;
    
    cd( oldDir );
catch e
    cd( oldDir );
    e.rethrow()
end
end % testvisibleexample

function d = demoroot()

d = fullfile( fileparts( 'fullpath' ), 'demos' );

end % helper function