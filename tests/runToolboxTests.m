function results = runToolboxTests()
%RUNTOOLBOXTESTS Run the GUI Layout Toolbox tests.

rootFolder = fileparts( mfilename( 'fullpath' ) );
results = runtests( rootFolder, 'IncludeSubfolders', true, ...
    'IncludeSubpackages', true );

end % runToolboxTests
