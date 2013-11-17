function uninstall()
%uninstall  Uninstall GUI Layout Toolbox
%
%  uninstall() uninstalls GUI Layout Toolbox by removing its files from the
%  saved path.
%
%  See also: install

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $

root = fileparts( mfilename( 'fullpath' ) ); % this directory
rmpath( root )
savepath()

end % uninstall