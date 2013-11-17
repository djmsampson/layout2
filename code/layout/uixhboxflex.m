function obj = uixhboxflex( varargin )
%uixhboxflex  Arrange elements horizontally with draggable dividers
%
%  b = uixhboxflex() creates a flexible box in the current figure.
%
%  b = uixhboxflex(p1,v1,p2,v2,...) creates a flexible box and sets
%  specified property p1 to value v1, etc.
%
%  See also: uixhbox, uixhbuttonbox, uixvboxflex, uixgridflex

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 380 $ $Date: 2013-02-27 10:29:08 +0000 (Wed, 27 Feb 2013) $

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.HBoxFlex( varargin{:} );

% Auto-parent
if ~ismember( 'Parent', varargin(1:2:end) )
    obj.Parent = gcf();
end

end % uixhboxflex