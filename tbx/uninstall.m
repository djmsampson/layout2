function uninstall()
%uninstall  Uninstall GUI Layout Toolbox
%
%  uninstall() uninstalls GUI Layout Toolbox by removing its files from the
%  saved path.
%
%  See also: install

%  Copyright 2009-2014 The MathWorks, Inc.
%  $Revision: 921 $ $Date: 2014-06-03 11:11:36 +0100 (Tue, 03 Jun 2014) $

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