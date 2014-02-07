function uninstall()
%uninstall  Uninstall GUI Layout Toolbox
%
%  uninstall() uninstalls GUI Layout Toolbox by removing its files from the
%  saved path.
%
%  See also: install

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 891 $ $Date: 2013-12-03 17:53:41 +0000 (Tue, 03 Dec 2013) $

% Folders to remove
thisFolder = fileparts( mfilename( 'fullpath' ) );
foldersToRemove = {
    fullfile(thisFolder, 'layout')
    fullfile(thisFolder, 'layoutdoc')
    };

% Capture path
oldPathList = path();

% Remove toolbox directory from saved path
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
savedPathCell = setdiff( savedPathCell, foldersToRemove, 'stable' );
path( sprintf( '%s;', userPathCell{:}, savedPathCell{:} ) )
savepath()

% Restore path minus toolbox directory
path( oldPathList )
rmpath( sprintf( '%s;', foldersToRemove{:} ) )

end % uninstall