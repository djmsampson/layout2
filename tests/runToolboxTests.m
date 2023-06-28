function results = runToolboxTests( headless )
%RUNTOOLBOXTESTS Run the GUI Layout Toolbox tests.

arguments
    headless(1, 1) logical = false
end % arguments

% Identify the current folder.
rootFolder = fileparts( mfilename( 'fullpath' ) );

% Disable the warning about name conflicts.
ID = 'MATLAB:dispatcher:nameConflict';
w = warning( 'query', ID );
warningCleanup = onCleanup( @() warning( w ) );
warning( 'off', ID )

% Create the test suite.
suite = testsuite( rootFolder, ...
    'IncludeSubfolders', true, ...
    'IncludeSubpackages', true );

% Filter the test suite if we're running in headless mode.
if headless    
    suiteIdx = 1 : length( suite );
    filterFun = @( idx ) ~isempty( suite(idx).Tags ) && ...
        all( strcmp( suite(idx).Tags, 'IncompatibleWithHeadlessMode' ) );
    excludeIdx = arrayfun( filterFun, suiteIdx );
    suite(excludeIdx) = [];
end % if

% Run the tests.
results = runtests( suite );

end % runToolboxTests