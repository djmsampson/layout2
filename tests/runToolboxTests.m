function results = runToolboxTests( headless )
%RUNTOOLBOXTESTS Run the GUI Layout Toolbox tests.
%
% results = runToolboxTests() runs all GLT tests and returns the results.
%
% results = runToolboxTests( true ) indicates that we are running in 
% headless MATLAB, and runs all GLT tests compatible with this mode of 
% execution and returns the results.
%
% results = runToolboxTests( false ) indicates that we are running in 
% desktop MATLAB, and runs all GLT tests and returns the results.

arguments
    headless(1, 1) logical = false
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

% Filter the test suite if we're running the tests in headless mode. Remove
% all tests which have the 'IncompatibleWithHeadlessMode' test tag.
if headless    
    suiteIdx = 1 : length( suite );
    filterFun = @( idx ) ~isempty( suite(idx).Tags ) && ...
        all( strcmp( suite(idx).Tags, 'IncompatibleWithHeadlessMode' ) );
    excludeIdx = arrayfun( filterFun, suiteIdx );
    suite(excludeIdx) = [];
end % if

% Run the tests, recording text output.
runner = testrunner( 'textoutput' );
results = runner.run( suite );

end % runToolboxTests