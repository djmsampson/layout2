function obj = uixboxpanel( varargin )
%uixboxpanel  Arrange a single element inside a panel with a boxed title
%
%  b = uixboxpanel() creates a box panel in the current figure.
%
%  b = uixboxpanel(p1,v1,p2,v2,...) creates a box panel and sets specified
%  property p1 to value v1, etc.
%
%  See also: uixpanel, uixcardpanel

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision$ $Date$

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.BoxPanel( varargin{:} );

% Auto-parent
if ~ismember( 'Parent', varargin(1:2:end) )
    obj.Parent = gcf();
end

end % uixboxpanel