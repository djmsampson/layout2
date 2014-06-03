function obj = Empty( varargin )
%uiextras.Empty  Create an empty space
%
%   obj = uiextras.Empty() creates a placeholder that can be used to add
%   gaps between elements in layouts.
%
%   obj = uiextras.Empty(param,value,...) also sets one or more property
%   values.
%
%   See the <a href="matlab:doc uiextras.Empty">documentation</a> for more detail and the list of properties.
%
%   Examples:
%   >> f = figure();
%   >> box = uiextras.HBox( 'Parent', f );
%   >> uicontrol( 'Parent', box, 'Background', 'r' )
%   >> uiextras.Empty( 'Parent', box )
%   >> uicontrol( 'Parent', box, 'Background', 'b' )

%   Copyright 2009-2013 The MathWorks, Inc.
%   $Revision$ $Date$

% Warn
% warning( 'uiextras:Deprecated', ...
%     'uiextras.Empty will be removed in a future release.' )

% Call uix constructor
obj = matlab.ui.control.UIControl( varargin{:}, 'Visible', 'off' );

end % uiextras.Empty