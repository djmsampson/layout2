function uninstall()
%uninstall  Uninstall GUI Layout Toolbox
%
%  uninstall() uninstalls GUI Layout Toolbox by removing its files from the
%  saved path.
%
%  See also: install

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision$ $Date$

root = fileparts( mfilename( 'fullpath' ) ); % this directory
rmpath( root )
savepath()

end % uninstall