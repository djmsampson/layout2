function varargout = warning( varargin )
%uix.warning  Display warning message
%
%  uix.warning is a fully compatible wrapper for builtin warning that also
%  sets initial warning states.

%  Copyright 2024 The MathWorks, Inc.

% Initialize
persistent INITIALIZED
if isequal( INITIALIZED, [] )
    warning( 'off', 'uix:Deprecated' ) % disable
    INITIALIZED = true;
end

% Call builtin warning
[varargout{1:nargout}] = builtin( 'warning', varargin{:} );

end % uix.warning