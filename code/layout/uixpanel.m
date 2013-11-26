function obj = uixpanel( varargin )
%uixpanel  Arrange a single element inside a standard panel
%
%  b = uixpanel() creates a panel in the current figure.
%
%  b = uixpanel(p1,v1,p2,v2,...) creates a panel and sets specified
%  property p1 to value v1, etc.
%
%  See also: uixboxpanel, uixcardpanel, uipanel

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision$ $Date$

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.Panel( varargin{:} );

% Auto-parent
if ~ismember( 'Parent', varargin(1:2:end) )
    obj.Parent = gcf();
end

end % uixpanel