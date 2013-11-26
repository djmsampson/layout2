function unset( ~, ~, ~ )
%uiextras.unset  Clear a default property value from a parent object
%
%  This functionality has been removed.

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision$ $Date$

% Check inputs
narginchk( 2, 2 )

% Warn
warning( 'uiextras:Deprecated', 'uiextras.unset has been removed.' )

end % uiextras.unset