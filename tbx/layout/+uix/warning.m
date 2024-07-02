function varargout = warning( varargin )
%uix.warning  Display warning message
%
%  uix.warning is a fully compatible wrapper for builtin warning that also
%  configures initial warning states.

%  Copyright 2024 The MathWorks, Inc.

% Set up
persistent SETUP; if isequal( SETUP, [] ), setup(), SETUP = true; end

% Call builtin warning
[varargout{1:nargout}] = warning( varargin{:} );

end % uix.warning

function setup()
%setup  Set up

warning( 'off', 'uix:Deprecated' )

end % setup