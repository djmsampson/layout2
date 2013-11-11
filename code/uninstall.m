function uninstall()
%uninstall  Uninstall GUI Layout Toolbox
%
%  uninstall() uninstalls GUI Layout Toolbox.
%
%  See also: install

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $

root = layoutRoot();
rmpath( root )
rmpath( fullfile( root, 'layout' ) )
savepath()

end % uninstall