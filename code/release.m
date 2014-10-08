function release
%release  Build, test and package GUI Layout Toolbox

%  Copyright 2009-2014 The MathWorks, Inc.
%  $Revision: 921 $ $Date: 2014-06-03 11:11:36 +0100 (Tue, 03 Jun 2014) $

% Check MATLAB
assert( ~verLessThan( 'MATLAB', '8.4' ), 'MATLAB R2014b or higher is required.' )

% Check installation
thisDir = fileparts( mfilename( 'fullpath' ) );
v = ver( 'layout' );
switch numel( v )
    case 0
        error( 'GUI Layout Toolbox not found.' )
    case 1
        assert( strncmp( which( 'layoutRoot' ), thisDir, numel( thisDir ) ), ...
            'GUI Layout Toolbox code at %s is not on the MATLAB path.', thisDir )
    otherwise
        error( 'There are multiple copies of GUI Layout Toolbox on the MATLAB path.' )
end

% Package and rename
fprintf( 1, 'Packaging...' );
prj = fullfile( thisDir, 'GUI Layout Toolbox.prj' );
name = char( com.mathworks.toolbox_packaging.services.ToolboxPackagingService.openProject( prj ) );
com.mathworks.toolbox_packaging.services.ToolboxPackagingService.packageProject( name )
com.mathworks.toolbox_packaging.services.ToolboxPackagingService.closeProject( name )
oldMltbx = fullfile( thisDir, [name '.mltbx'] );
newMltbx = fullfile( fileparts( thisDir ), 'releases', [name ' ' v.Version '.mltbx'] );
movefile( oldMltbx, newMltbx )
fprintf( 1, ' OK.\n' );

% Check package
fprintf( 1, 'Checking package...' );
info = mlAddonGetProperties( newMltbx );
assert( strcmp( info.version, v.Version ), 'Package version %s does not match code version %s.', info.version, v.Version )
fprintf( 1, ' OK.\n' );

% Show message
fprintf( 1, 'Created %s\n', newMltbx );

end % release