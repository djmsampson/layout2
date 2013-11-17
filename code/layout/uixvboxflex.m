function obj = uixvboxflex( varargin )
%uixvboxflex  Arrange elements vertically with draggable dividers
%
%  b = uixvboxflex() creates a flexible box in the current figure.
%
%  b = uixvboxflex(p1,v1,p2,v2,...) creates a flexible box and sets
%  specified property p1 to value v1, etc.
%
%  See also: uixvbox, uixvbuttonbox, uixhboxflex, uixgridflex

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 380 $ $Date: 2013-02-27 10:29:08 +0000 (Wed, 27 Feb 2013) $

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.VBoxFlex( varargin{:} );

% Auto-parent
if ~ismember( 'Parent', varargin(1:2:end) )
    obj.Parent = gcf();
end

end % uixvboxflex