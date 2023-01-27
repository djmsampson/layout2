function results = runToolboxTests()
%RUNTOOLBOXTESTS Run the GUI Layout Toolbox tests.

% Identify the current folder.
rootFolder = fileparts( mfilename( 'fullpath' ) );

% Disable the warning about name conflicts.
ID = "MATLAB:dispatcher:nameConflict";
w = warning( "query", ID );
warningCleanup = onCleanup( @() warning( w ) );
warning( "off", ID )

% Run the tests.
results = runtests( rootFolder, 'IncludeSubfolders', true, ...
    'IncludeSubpackages', true );

end % runToolboxTests