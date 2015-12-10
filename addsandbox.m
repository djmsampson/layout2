function addsandbox()
%addsandbox  Add sandbox to installed path
%
%  addsandbox() adds the GUI Layout Toolbox sandbox to the saved path.
%
%  See also: rmsandbox

%  Copyright 2009-2015 The MathWorks, Inc.
%  $Revision: 921 $ $Date: 2014-06-03 11:11:36 +0100 (Tue, 03 Jun 2014) $

% Folders to add
thisFolder = fileparts( mfilename( 'fullpath' ) );
foldersToAdd = {
    fullfile( thisFolder, 'tbx', 'layout')
    fullfile( thisFolder, 'tbx', 'layoutdoc')
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

end % addsandbox