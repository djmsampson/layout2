function install()
%install  Install GUI Layout Toolbox
%
%  install() installs GUI Layout Toolbox by adding its files to the saved
%  path.
%
%  See also: uninstall

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision$ $Date$

root = fileparts( mfilename( 'fullpath' ) ); % this directory
addpath( root )
savepath()

end % install