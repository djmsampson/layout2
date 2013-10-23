function obj = Empty()
%uiextras.Empty  Create an empty space
%
%   obj = uiextras.Empty() creates an empty space object that can be
%   used in layouts to add gaps between other elements.
%
%   obj = uiextras.Empty(param,value,...) also sets one or more
%   property values.
%
%   See the <a href="matlab:doc uiextras.Empty">documentation</a> for more detail and the list of properties.
%
%   Examples:
%   >> f = figure();
%   >> box = uiextras.HBox( 'Parent', f );
%   >> uicontrol( 'Parent', box, 'Background', 'r' )
%   >> uiextras.Empty( 'Parent', box )
%   >> uicontrol( 'Parent', box, 'Background', 'b' )
%
%   See also: uiextras.HBox

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 287 $
%   $Date: 2010-07-14 12:21:33 +0100 (Wed, 14 Jul 2010) $

% Warn
warning( 'uiextras:Deprecated', ...
    'uiextras.Empty is deprecated.  Please use gobjects instead.' )

% Do
obj = gobjects( 1 );

end % uiextras.Empty