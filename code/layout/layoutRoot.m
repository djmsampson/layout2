function folder = layoutRoot()
%layoutRoot  Folder containing the GUI Layout Toolbox
%
%   folder = layoutRoot() returns the full path to the folder containing
%   the GUI Layout Toolbox.
%
%   Examples:
%   >> folder = layoutRoot()
%   folder = 'C:\tools\layouts2\layout'
%
%   See also: layoutVersion

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $

folder = fileparts( mfilename( 'fullpath' ) );

end % layoutRoot