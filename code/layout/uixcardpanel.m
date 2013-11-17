function obj = uixcardpanel( varargin )
%uixcardpanel  Show one element from a list
%
%  b = uixcardpanel() creates a card panel in the current figure.
%
%  b = uixcardpanel(p1,v1,p2,v2,...) creates a card panel and sets
%  specified property p1 to value v1, etc.
%
%  See also: uixpanel, uixboxpanel

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 380 $ $Date: 2013-02-27 10:29:08 +0000 (Wed, 27 Feb 2013) $

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.CardPanel( varargin{:} );

% Auto-parent
if ~ismember( 'Parent', varargin(1:2:end) )
    obj.Parent = gcf();
end

end % uixcardpanel