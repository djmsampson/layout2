function obj = uixgridflex( varargin )
%uixgridflex  Arrange elements in a two-dimensional grid with draggable dividers
%
%  b = uixgridflex() creates a flexible grid in the current figure.
%
%  b = uixgridflex(p1,v1,p2,v2,...) creates a flexible grid and sets
%  specified property p1 to value v1, etc.
%
%  See also: uixgrid, uixhboxflex, uixvboxflex

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 380 $ $Date: 2013-02-27 10:29:08 +0000 (Wed, 27 Feb 2013) $

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.GridFlex( varargin{:} );

% Auto-parent
if ~ismember( 'Parent', varargin(1:2:end) )
    obj.Parent = gcf();
end

end % uixgridflex