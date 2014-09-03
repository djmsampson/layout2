function install()
%install  Install GUI Layout Toolbox
%
%  install() installs GUI Layout Toolbox by adding its files to the saved
%  path.
%
%  See also: uninstall

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 891 $ $Date: 2013-12-03 17:53:41 +0000 (Tue, 03 Dec 2013) $

% Folders to add
thisFolder = fileparts( mfilename( 'fullpath' ) );
foldersToAdd = {
    fullfile(thisFolder, 'layout')
    fullfile(thisFolder, 'layoutdoc')
    fullfile(thisFolder, 'patch')
    };

% Capture path
oldPathList = path();

% Add toolbox directory to saved path
userPathList = userpath();
if isempty( userPathList )
    userPathCell = cell( [0 1] );
else
    userPathCell = textscan( userPathList, '%s', 'Delimiter', ';' );
    userPathCell = userPathCell{:};
end
savedPathList = pathdef();
savedPathCell = textscan( savedPathList, '%s', 'Delimiter', ';' );
savedPathCell = savedPathCell{:};
savedPathCell = setdiff( savedPathCell, userPathCell, 'stable' );
savedPathCell = [foldersToAdd; savedPathCell];
path( sprintf( '%s;', userPathCell{:}, savedPathCell{:} ) )
savepath()

% Restore path plus toolbox directory
path( oldPathList )
addpath( sprintf( '%s;', foldersToAdd{:} ) )

end % install