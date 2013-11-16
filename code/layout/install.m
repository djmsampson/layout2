function install()
%install  Install GUI Layout Toolbox
%
%  install() installs GUI Layout Toolbox.
%
%  See also: uninstall

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $

root = fileparts( mfilename( 'fullpath' ) ); % this directory
addpath( root )
addpath( fullfile( root, 'layout' ) )
savepath()

end % install