function results = runToolboxTests()
%RUNTOOLBOXTESTS Run the GUI Layout Toolbox tests.
%
% results = runToolboxTests() runs all GLT tests and returns the results.

% Record the current folder (the tests directory).
rootFolder = fileparts( mfilename( 'fullpath' ) );

% Create the test suite from the tests root folder, including the tests
% located in the inner namespaces.
before18a = verLessThan( 'matlab', '9.4' );
before22a = verLessThan( 'matlab', '9.12' ); %#ok<VERLESSMATLAB>
if before22a
    % Before R2022a, fromFolder did not include inner namespaces.
    suite = [matlab.unittest.TestSuite.fromFolder( rootFolder ), ...
        matlab.unittest.TestSuite.fromPackage( 'uiextrastests' ), ...
        matlab.unittest.TestSuite.fromPackage( 'uixtests' )];
    if ~before18a
        % If we're between R2018a - R2021b, append the tests that use the 
        % App Testing Framework.
        suite = [suite, ...
            matlab.unittest.TestSuite.fromPackage( 'gesturetests' )];
    end % if
else
    % We're in R2022a onwards, and fromFolder will include the tests in
    % inner namespaces when the 'IncludingSubfolders' option is true.
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