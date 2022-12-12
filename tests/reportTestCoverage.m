function varargout = reportTestCoverage()
%REPORTTESTCOVERAGE Report test coverage for GUI Layout Toolbox.

% Create the test suite.
rootFolder = fileparts( mfilename( "fullpath" ) );
suite = testsuite( fullfile( rootFolder ), "IncludeSubfolders", true, ...
    "IncludeSubpackages", true );

% Create the test runner.
runner = testrunner( "minimal" );

% Configure the runner to have a code coverage plugin for the main folder
% of the toolbox.
coverageFolder = fullfile( rootFolder, "Coverage" );
coverageReport = matlab.unittest.plugins.codecoverage...
    .CoverageReport( coverageFolder, "MainFile", "CoverageReport.html" );
coveragePlugin = matlab.unittest.plugins.CodeCoveragePlugin...
    .forFolder( layoutRoot(), "IncludingSubfolders", true, ...
    "Producing", coverageReport );
runner.addPlugin( coveragePlugin )

% Run the tests.
results = runner.run( suite );
if nargout > 0
    nargoutchk( 1, 1 )
    varargout{1} = results;
end % if

% Open the coverage report.
web( fullfile( coverageFolder, coverageReport.MainFile ), "-browser" )

end % reportTestCoverage