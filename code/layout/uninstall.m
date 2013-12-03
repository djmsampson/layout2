function uninstall()
%uninstall  Uninstall GUI Layout Toolbox
%
%  uninstall() uninstalls GUI Layout Toolbox by removing its files from the
%  saved path.
%
%  See also: install

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision$ $Date$

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
toolPathCell = {fileparts( mfilename( 'fullpath' ) )}; % this directory
savedPathCell = setdiff( savedPathCell, toolPathCell, 'stable' );
path( sprintf( '%s;', userPathCell{:}, savedPathCell{:} ) )
savepath()

% Restore path minus toolbox directory
path( oldPathList )
rmpath( sprintf( '%s;', toolPathCell{:} ) )

end % uninstall