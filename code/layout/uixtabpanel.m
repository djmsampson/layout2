function obj = uixtabpanel( varargin )
%uixtabpanel  Arrange elements in a panel with tabs for selecting which is visible
%
%  b = uixtabpanel() creates a tab panel in the current figure.
%
%  b = uixtabpanel(p1,v1,p2,v2,...) creates a tab panel and sets specified
%  property p1 to value v1, etc.
%
%  See also: uitabgroup, uitab

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 380 $ $Date: 2013-02-27 10:29:08 +0000 (Wed, 27 Feb 2013) $

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.TabPanel( varargin{:} );

% Auto-parent
if ~ismember( 'Parent', varargin(1:2:end) )
    obj.Parent = gcf();
end

end % uixtabpanel