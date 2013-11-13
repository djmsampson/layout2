function unset( ~, ~, ~ )
%uiextras.unset  Clear a default property value from a parent object
%
%  This functionality has been removed.

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $

% Check inputs
narginchk( 2, 2 )

% Warn
warning( 'uiextras:Deprecated', 'uiextras.unset has been removed.' )

end % uiextras.unset