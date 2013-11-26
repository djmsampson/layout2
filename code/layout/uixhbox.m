function obj = uixhbox( varargin )
%uixhbox  Arrange elements horizontally in a single row
%
%  b = uixhbox() creates a box in the current figure.
%
%  b = uixhbox(p1,v1,p2,v2,...) creates a box and sets specified property
%  p1 to value v1, etc.
%
%  See also: uixhboxflex, uixhbuttonbox, uixvbox, uixgrid

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision$ $Date$

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.HBox( varargin{:} );

% Auto-parent
if ~ismember( 'Parent', varargin(1:2:end) )
    obj.Parent = gcf();
end

end % uixhbox