function results = runToolboxTests( namedArgs )
%RUNTOOLBOXTESTS Run the GUI Layout Toolbox tests.
%
% results = runToolboxTests() runs all GLT tests and returns the results.
%
% results = runToolboxTests( 'ExcludeMouseTests', true ) excludes tests
% that use either the Java robot or MATLAB to perform mouse interactions 
% and returns the results.
%
% results = runToolboxTests( 'ExcludeMouseTests', false ) runs all GLT 
% tests and returns the results.

arguments    
    namedArgs.ExcludeMouseTests(1, 1) logical = false    
end % arguments

% Record the current folder (the tests directory).
rootFolder = fileparts( mfilename( 'fullpath' ) );

% Disable the warning about name conflicts.
ID = 'MATLAB:dispatcher:nameConflict';
w = warning( 'query', ID );
warningCleanup = onCleanup( @() warning( w ) );
warning( 'off', ID )

% Create the test suite, including tests in subfolders and subpackages.
suite = testsuite( rootFolder, ...
    'IncludeSubfolders', true, ...
    'IncludeSubpackages', true );

% Filter the test suite using the user-specified parameters. This
% determines the tests to exclude based on their tags.
if namedArgs.ExcludeMouseTests    
    suiteIdx = 1 : length( suite );
    filterFun = @( idx ) ~isempty( suite(idx).Tags ) && ...
        all( strcmp( suite(idx).Tags, 'MovesMouse' ) );
    excludeIdx = arrayfun( filterFun, suiteIdx );
    suite(excludeIdx) = [];
end % if

% Run the tests, recording text output.
runner = matlab.unittest.TestRunner.withTextOutput();
results = runner.run( suite );

end % runToolboxTests