function varargout = reportTestCoverage( testFileSpec )
%REPORTTESTCOVERAGE Report test coverage for GUI Layout Toolbox.

arguments
    testFileSpec(1, :) string = rootFolder()
end % arguments

nargoutchk( 0, 1 )

% Create the test suite.
suite = testsuite( testFileSpec, ...
    "IncludeSubfolders", true, ...
    "IncludeSubpackages", true );

% Create the test runner.
runner = testrunner( "minimal" );

% Configure the runner to have a code coverage plugin for the main folder
% of the toolbox.
coverageFolder = fullfile( rootFolder, "Coverage" );
coverageReport = matlab.unittest.plugins.codecoverage...
    .CoverageReport( coverageFolder, ...
    "MainFile", "CoverageReport.html" );
coveragePlugin = matlab.unittest.plugins.CodeCoveragePlugin...
    .forFolder( layoutRoot(), ...
    "IncludingSubfolders", true, ...
    "Producing", coverageReport );
runner.addPlugin( coveragePlugin )

% Run the tests.
results = runner.run( suite );
if nargout == 1    
    varargout{1} = results;
end % if

% Open the coverage report.
web( fullfile( coverageFolder, coverageReport.MainFile ), "-browser" )

end % reportTestCoverage

function folder = rootFolder()
%ROOTFOLDER Return the parent folder of the function.

folder = fileparts( mfilename( "fullpath" ) );

end % rootFolder