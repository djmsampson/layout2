function obj = uixgrid( varargin )
%uixgrid  Arrange elements in a two-dimensional grid
%
%  b = uixgrid() creates a grid in the current figure.
%
%  b = uixgrid(p1,v1,p2,v2,...) creates a grid and sets specified property
%  p1 to value v1, etc.
%
%  See also: uixgridflex, uixhbox, uixvbox

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision$ $Date$

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.Grid( varargin{:} );

% Auto-parent
if ~ismember( 'Parent', varargin(1:2:end) )
    obj.Parent = gcf();
end

end % uixgrid