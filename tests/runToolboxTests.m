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

% Create the test suite, including tests in inner namespaces. There was a
% behavior change in fromFolder in R2022a (9.12).
if verLessThan( 'matlab', '9.12' ) %#ok<VERLESSMATLAB>
    suite = [matlab.unittest.TestSuite.fromFolder( rootFolder ), ...
        matlab.unittest.TestSuite.fromPackage( 'gesturetests' ), ...
        matlab.unittest.TestSuite.fromPackage( 'uiextrastests' ), ...
        matlab.unittest.TestSuite.fromPackage( 'uixtests' )];
else
    suite = matlab.unittest.TestSuite.fromFolder( rootFolder, ...
        'IncludingSubfolders', true );
end % if

% Record text output.
runner = matlab.unittest.TestRunner.withTextOutput();
if ~verLessThan( 'matlab', '8.6' ) % R2015b
    xmlPlugin = matlab.unittest.plugins.XMLPlugin...
        .producingJUnitFormat( 'TestResults.xml' );
    runner.addPlugin( xmlPlugin )
end % if

% Run the tests.
results = runner.run( suite );

end % runToolboxTests