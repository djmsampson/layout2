function layoutapp()
%layoutapp  App launcher for GUI Layout Toolbox
%
%  layoutapp() launches GUI Layout Toolbox as a MATLAB App.
%
%  See also: install, uninstall

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 887 $ $Date: 2013-11-26 10:53:41 +0000 (Tue, 26 Nov 2013) $

savedPathList = pathdef();
savedPathCell = textscan( savedPathList, '%s', 'Delimiter', ';' );
savedPathCell = savedPathCell{:};
toolPathCell = {fullfile( fileparts( mfilename( 'fullpath' ) ), 'layout')}; % subdirectory 'layout'
if all( ismember( toolPathCell, savedPathCell ) )
    if strcmp( questdlg( 'Uninstall GUI Layout Toolbox?', 'Installer', ...
            'Yes', 'No', 'Yes' ), 'Yes' )
        uninstall()
        uiwait( msgbox( 'Uninstalled GUI Layout Toolbox.', 'Installer', 'modal' ) )
    end
else % not installed
    if strcmp( questdlg( 'Install GUI Layout Toolbox?', 'Installer', ...
            'Yes', 'No', 'Yes' ), 'Yes' )
        install()
        uiwait( msgbox( 'Installed GUI Layout Toolbox.', 'Installer', 'modal' ) )
    end
end

end % layoutapp