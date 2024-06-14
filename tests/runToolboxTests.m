function results = runToolboxTests()
%RUNTOOLBOXTESTS Run the GUI Layout Toolbox tests.
%
% results = runToolboxTests() runs all GLT tests and returns the results.

% Record the current folder (the tests directory).
rootFolder = fileparts( mfilename( 'fullpath' ) );

% Disable the warning about name conflicts.
ID = 'MATLAB:dispatcher:nameConflict';
w = warning( 'query', ID );
warningCleanup = onCleanup( @() warning( w ) );
warning( 'off', ID )

% Create the test suite, including tests in subfolders and subpackages.
suite = matlab.unittest.TestSuite.fromFolder( rootFolder, ...
    'IncludingSubfolders', true );

% Run the tests, recording text output.
runner = matlab.unittest.TestRunner.withTextOutput();
xmlPlugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
    "TestResults.xml" );
runner.addPlugin( xmlPlugin )
results = runner.run( suite );

end % runToolboxTests