function install()
%install  Install GUI Layout Toolbox
%
%  install() installs GUI Layout Toolbox by adding its files to the saved
%  path.
%
%  See also: uninstall

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision$ $Date$

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
toolPathCell = {fileparts( mfilename( 'fullpath' ) )}; % this directory
savedPathCell = [toolPathCell; savedPathCell];
path( sprintf( '%s;', userPathCell{:}, savedPathCell{:} ) )
savepath()

% Restore path plus toolbox directory
path( oldPathList )
addpath( sprintf( '%s;', toolPathCell{:} ) )

end % install