classdef BoxPanel < uix.Panel
    %uix.BoxPanel  Box panel
    %
    %  p = uix.BoxPanel(p1,v1,p2,v2,...) constructs a box panel and sets
    %  parameter p1 to value v1, etc.
    %
    %  A box panel is a decorated container with a title box, border, and
    %  buttons to dock and undock, minimize, get help, and close.  A box
    %  panel shows one of its contents and hides the others.
    %
    %  See also: uix.Panel, uipanel, uix.CardPanel

    %  Copyright 2009-2025 The MathWorks, Inc.

    properties( Access = public, Dependent, AbortSet )
        TitleColor % title background color [RGB]
        Minimized % minimized [true|false]
        MinimizeFcn % minimize callback
        MaximizeFcn % maximize callback
        Docked % docked [true|false]
        DockFcn % dock callback
        UndockFcn % undock callback
        HelpFcn % help callback
        CloseRequestFcn % close request callback
    end

    properties( Dependent, SetAccess = private )
        TitleHeight % title panel height [pixels]
    end

    properties( Access = private )
        TitleBar % title bar
        TitleText % title text
        TitlePanel % title panel
        ShadowPanel % shadow panel
        ShadowContent % shadow content
        Title_ = get( 0, 'DefaultUipanelTitle' ) % backing for Title
        TitleAccess = 'public' % 'private' when getting or setting Title, 'public' otherwise
        TitleColorMode_ = 'auto' % backing for TitleColorMode
        MinimizeButton % button
        MaximizeButton % button
        DockButton % button
        UndockButton % button
        HelpButton % button
        CloseButton % button
        Minimized_ = false % backing for Minimized
        Docked_ = true % backing for Docked
        FigureSelectionListener % listener
    end

    properties( Constant, Access = private )
        NullTitle = char.empty( [2 0] ) % an obscure empty string, the actual panel Title
        BlankTitle = ' ' % a non-empty blank string, the empty uicontrol String
        DummyControl = matlab.ui.control.UIControl() % dummy uicontrol
    end

    properties( Access = public, Dependent, AbortSet )
        MinimizeTooltip % tooltip
        MaximizeTooltip % tooltip
        DockTooltip % tooltip
        UndockTooltip % tooltip
        HelpTooltip % tooltip
        CloseTooltip % tooltip
    end

    properties( Access = public, Dependent, AbortSet, Hidden )
        MinimizeTooltipString % now MinimizeTooltip
        MaximizeTooltipString % now MaximizeTooltip
        DockTooltipString % now DockTooltip
        UndockTooltipString % now UndockTooltip
        HelpTooltipString % now HelpTooltip
        CloseTooltipString % now CloseTooltip
    end % deprecated

    properties( Access = public, Dependent, Hidden )
        TitleColor_I % backing for TitleColor
        TitleColorMode % title color mode [auto|manual]
        FourgroundColor
        FourgroundColor_I
        FourgroundColorMode
    end

    events( Hidden, NotifyAccess = private )
        Minimizing
        Maximizing
        Docking
        Undocking
        Helping
        Closing
    end

    methods

        function obj = BoxPanel( varargin )
            %uix.BoxPanel  Box panel constructor
            %
            %  p = uix.BoxPanel() constructs a box panel.
            %
            %  p = uix.BoxPanel(p1,v1,p2,v2,...) sets parameter p1 to value
            %  v1, etc.

            % Define default colors
            foregroundColor = [0 1 0];
            titleColor = [1 0 0];

            % Create title bar
            titleBar = uix.HBox( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'BackgroundColor', titleColor );
            titleText = uicontrol( 'Parent', [], ...
                'Style', 'text', 'String', obj.BlankTitle, ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', titleColor ); % for Java
            titlePanel = uipanel( 'Parent', [], ...
                'BorderType', 'none', 'BorderWidth', 0, ...
                'Title', obj.BlankTitle, ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', titleColor ); % for JavaScript

            % Create shadow
            shadowPanel = uipanel( 'Internal', true, ...
                'Parent', obj, 'Visible', 'on', ...
                'Units', 'normalized', 'Position', [-2 0 1 1], ...
                'BackgroundColor', 'b', ... % for debugging
                'BorderType', 'none', 'BorderWidth', 0, ...
                'Title', obj.BlankTitle ); % same size, off screen
            if isprop( shadowPanel, 'AutoResizeChildren' )
                shadowPanel.AutoResizeChildren = 'off';
            end
            shadowContent = uicontainer( 'Internal', true, ...
                'Parent', shadowPanel, 'Visible', 'on', ...
                'Units', 'normalized', 'Position', [0 0 1 1], ...
                'BackgroundColor', 'c', ... % for debugging
                'SizeChangedFcn', @obj.onInnerSizeChanged ); % fill panel

            % Create buttons
            minimizeButton = uicontrol( 'Parent', [], ...
                'Style', 'text', 'HorizontalAlignment', 'center', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', titleColor, ...
                'Enable', 'on', 'FontWeight', 'bold', ...
                'String', char( 9652 ), ...
                'TooltipString', 'Collapse this panel' );
            maximizeButton = uicontrol( 'Parent', [], ...
                'Style', 'text', 'HorizontalAlignment', 'center', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', titleColor, ...
                'Enable', 'on', 'FontWeight', 'bold', ...
                'String', char( 9662 ), ...
                'TooltipString', 'Expand this panel' );
            dockButton = uicontrol( 'Parent', [], ...
                'Style', 'text', 'HorizontalAlignment', 'center', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', titleColor, ...
                'Enable', 'on', 'FontWeight', 'bold', ...
                'String', char( 8600 ), ...
                'TooltipString', 'Dock this panel' );
            undockButton = uicontrol( 'Parent', [], ...
                'Style', 'text', 'HorizontalAlignment', 'center', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', titleColor, ...
                'Enable', 'on', 'FontWeight', 'bold', ...
                'String', char( 8599 ), ...
                'TooltipString', 'Undock this panel' );
            helpButton = uicontrol( 'Parent', [], ...
                'Style', 'text', 'HorizontalAlignment', 'center', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', titleColor, ...
                'Enable', 'on', 'FontWeight', 'bold', ...
                'String', '?', ...
                'TooltipString', 'Get help on this panel' );
            closeButton = uicontrol( 'Parent', [], ...
                'Style', 'text', 'HorizontalAlignment', 'center', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', titleColor, ...
                'Enable', 'on', 'FontWeight', 'bold', ...
                'String', char( 215 ), ...
                'TooltipString', 'Close this panel' );

            % Store properties
            obj.Title = obj.NullTitle;
            obj.TitleBar = titleBar;
            obj.TitleText = titleText;
            obj.TitlePanel = titlePanel;
            obj.ShadowPanel = shadowPanel;
            obj.ShadowContent = shadowContent;
            obj.MinimizeButton = minimizeButton;
            obj.MaximizeButton = maximizeButton;
            obj.DockButton = dockButton;
            obj.UndockButton = undockButton;
            obj.HelpButton = helpButton;
            obj.CloseButton = closeButton;

            % Create listeners
            addlistener( obj, 'BorderWidth', 'PostSet', ...
                @obj.onBorderWidthChanged );
            addlistener( obj, 'BorderType', 'PostSet', ...
                @obj.onBorderTypeChanged );
            addlistener( obj, 'FontAngle', 'PostSet', ...
                @obj.onFontAngleChanged );
            addlistener( obj, 'FontName', 'PostSet', ...
                @obj.onFontNameChanged );
            addlistener( obj, 'FontSize', 'PostSet', ...
                @obj.onFontSizeChanged );
            addlistener( obj, 'FontUnits', 'PostSet', ...
                @obj.onFontUnitsChanged );
            addlistener( obj, 'FontWeight', 'PostSet', ...
                @obj.onFontWeightChanged );
            addlistener( obj, 'ForegroundColor', 'PostSet', ...
                @obj.onForegroundColorChanged );
            addlistener( obj, 'Title', 'PreGet', ...
                @obj.onTitleReturning );
            addlistener( obj, 'Title', 'PostGet', ...
                @obj.onTitleReturned );
            addlistener( obj, 'Title', 'PostSet', ...
                @obj.onTitleChanged );
            addlistener( obj, 'Minimizing', ...
                @obj.onButtonClicked );
            addlistener( obj, 'Maximizing', ...
                @obj.onButtonClicked );
            addlistener( obj, 'Docking', ...
                @obj.onButtonClicked );
            addlistener( obj, 'Undocking', ...
                @obj.onButtonClicked );
            addlistener( obj, 'Helping', ...
                @obj.onButtonClicked );
            addlistener( obj, 'Closing', ...
                @obj.onButtonClicked );

            % Set properties
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end

        end % constructor

    end % structors

    methods

        function value = get.TitleColor( obj )

            value = obj.TitleColor_I;

        end % get.TitleColor

        function set.TitleColor( obj, value )

            try
                obj.TitleColor_I = value; % delegate
                obj.TitleColorMode = 'manual'; % flip
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Property ''TitleColor'' must be a colorspec.' ) )
            end

        end % set.TitleColor

        function value = get.TitleColor_I( obj )

            disp get.TitleColor_I

            value = obj.TitleBar.BackgroundColor;

        end % get.TitleColor_I

        function set.TitleColor_I( obj, value )

            % Set underlying
            obj.TitleBar.BackgroundColor = value;
            obj.TitleText.BackgroundColor = value;
            obj.TitlePanel.BackgroundColor = value;
            obj.MinimizeButton.BackgroundColor = value;
            obj.MaximizeButton.BackgroundColor = value;
            obj.DockButton.BackgroundColor = value;
            obj.UndockButton.BackgroundColor = value;
            obj.HelpButton.BackgroundColor = value;
            obj.CloseButton.BackgroundColor = value;

        end % set.TitleColor_I

        function value = get.TitleColorMode( obj )

            value = obj.TitleColorMode_;

        end % get.TitleColorMode

        function set.TitleColorMode( obj, value )

            try
                value = char( value ); % convert
                assert( ismember( value, {'auto','manual'} ) ) % compare
                obj.TitleColorMode_ = value; % store
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Property ''TitleColorMode'' must be ''auto'' or ''manual''.' ) )
            end

        end % set.TitleColorMode

        function value = get.FourgroundColor( obj )

            value = obj.FourgroundColor_I; % delegate

        end % get.FourgroundColor

        function set.FourgroundColor( obj, value )

            obj.FourgroundColor_I = value; % apply
            obj.FourgroundColorMode = 'manual'; % flip mode
            obj.ForegroundColorMode = 'manual'; % mirror mode

        end % set.FourgroundColor

        function value = get.FourgroundColor_I( obj )

            value = obj.TitleText.ForegroundColor; % get underlying

        end % get.FourgroundColor_I

        function set.FourgroundColor_I( obj, value )

            % Set underlying
            obj.TitleText.ForegroundColor = value;
            obj.TitlePanel.ForegroundColor = value;
            obj.MinimizeButton.ForegroundColor = value;
            obj.MaximizeButton.ForegroundColor = value;
            obj.DockButton.ForegroundColor = value;
            obj.UndockButton.ForegroundColor = value;
            obj.HelpButton.ForegroundColor = value;
            obj.CloseButton.ForegroundColor = value;

            % Mirror
            obj.ForegroundColor_I = value;

        end % set.FourgroundColor_I

        function value = get.FourgroundColorMode( obj )

            value = obj.ForegroundColorMode; % delegate

        end % get.FourgroundColorMode

        function set.FourgroundColorMode( obj, value )

            obj.ForegroundColorMode = value; % delegate

        end % set.FourgroundColorMode

        function value = get.Minimized( obj )

            value = obj.Minimized_;

        end % get.Minimized

        function set.Minimized( obj, value )

            % Check
            if isequal( value, true ) || isequal( value, 'on' )
                value = true;
            elseif isequal( value, false ) || isequal( value, 'off' )
                value = false;
            else
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be true or false.', ...
                    'Minimized' ) )
            end

            % Set
            obj.Minimized_ = value;

            % Update buttons
            obj.redrawButtons()

        end % set.Minimized

        function value = get.MinimizeFcn( obj )

            value = obj.MinimizeButton.Callback;

        end % get.MinimizeFcn

        function set.MinimizeFcn( obj, value )

            % Set callbacks
            try
                obj.MinimizeButton.Callback = value;
                obj.MaximizeButton.Callback = value; % and MaximizeFcn
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a function handle or cell array.', ...
                    'MinimizeFcn' ) )
            end

            % Update buttons
            obj.redrawButtons()

        end % set.MinimizeFcn

        function value = get.MaximizeFcn( obj )

            value = obj.MaximizeButton.Callback;

        end % get.MaximizeFcn

        function set.MaximizeFcn( obj, value )

            % Set callbacks
            try
                obj.MaximizeButton.Callback = value;
                obj.MinimizeButton.Callback = value; % and MinimizeFcn
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a function handle or cell array.', ...
                    'MaximizeFcn' ) )
            end

            % Update buttons
            obj.redrawButtons()

        end % set.MaximizeFcn

        function value = get.Docked( obj )

            value = obj.Docked_;

        end % get.Docked

        function set.Docked( obj, value )

            % Check
            if isequal( value, true ) || isequal( value, 'on' )
                value = true;
            elseif isequal( value, false ) || isequal( value, 'off' )
                value = false;
            else
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be true or false.', ...
                    'Docked' ) )
            end

            % Set
            obj.Docked_ = value;

            % Update buttons
            obj.redrawButtons()

        end % set.Docked

        function value = get.DockFcn( obj )

            value = obj.DockButton.Callback;

        end % get.DockFcn

        function set.DockFcn( obj, value )

            % Set callbacks
            try
                obj.DockButton.Callback = value;
                obj.UndockButton.Callback = value; % and UndockFcn
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a function handle or cell array.', ...
                    'DockFcn' ) )
            end

            % Update buttons
            obj.redrawButtons()

        end % set.DockFcn

        function value = get.UndockFcn( obj )

            value = obj.UndockButton.Callback;

        end % get.UndockFcn

        function set.UndockFcn( obj, value )

            % Set callbacks
            try
                obj.UndockButton.Callback = value;
                obj.DockButton.Callback = value; % and DockFcn
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a function handle or cell array.', ...
                    'UndockFcn' ) )
            end

            % Update buttons
            obj.redrawButtons()

        end % set.UndockFcn

        function value = get.HelpFcn( obj )

            value = obj.HelpButton.Callback;

        end % get.HelpFcn

        function set.HelpFcn( obj, value )

            % Set callback
            try
                obj.HelpButton.Callback = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a function handle or cell array.', ...
                    'HelpFcn' ) )
            end

            % Update buttons
            obj.redrawButtons()

        end % set.HelpFcn

        function value = get.CloseRequestFcn( obj )

            value = obj.CloseButton.Callback;

        end % get.CloseRequestFcn

        function set.CloseRequestFcn( obj, value )

            % Set callback
            try
                obj.CloseButton.Callback = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a function handle or cell array.', ...
                    'CloseRequestFcn' ) )
            end

            % Update buttons
            obj.redrawButtons()

        end % set.CloseRequestFcn

        function value = get.TitleHeight( obj )

            f = ancestor( obj, 'figure' );
            if isempty( f )
                value = NaN; % unreachable
            elseif isprop( f, 'JavaFrame_I' ) && ~isempty( f.JavaFrame_I ) % Java
                t = obj.TitleText;
                e = hgconvertunits( f, t.Extent, t.Units, 'pixels', t.Parent );
                value = e(4); % text extent
                fprintf( 1, "[Ja] Panel height = %f px\n", value ); % TODO remove
            else % Javascript
                s = obj.ShadowPanel;
                op = hgconvertunits( f, s.OuterPosition, s.Units, 'pixels', s.Parent );
                ip = hgconvertunits( f, s.InnerPosition, s.Units, 'pixels', s.Parent );
                value = op(4) - ip(4) - op(3) + ip(3);
                value = max( value, 0 );
                fprintf( 1, "[JS] Panel height = %f px\n", value ); % TODO remove
            end

        end % get.TitleHeight

    end % accessors

    methods

        function value = get.MinimizeTooltip( obj )

            value = obj.MinimizeButton.TooltipString;

        end % get.MinimizeTooltip

        function set.MinimizeTooltip( obj, value )

            try
                obj.MinimizeButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'MinimizeTooltip' ) )
            end

        end % set.MinimizeTooltip

        function value = get.MaximizeTooltip( obj )

            value = obj.MaximizeButton.TooltipString;

        end % get.MaximizeTooltip

        function set.MaximizeTooltip( obj, value )

            try
                obj.MaximizeButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'MaximizeTooltip' ) )
            end

        end % set.MaximizeTooltip

        function value = get.UndockTooltip( obj )

            value = obj.UndockButton.TooltipString;

        end % get.UndockTooltip

        function set.UndockTooltip( obj, value )

            try
                obj.UndockButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'UndockTooltip' ) )
            end

        end % set.UndockTooltip

        function value = get.DockTooltip( obj )

            value = obj.DockButton.TooltipString;

        end % get.DockTooltip

        function set.DockTooltip( obj, value )

            try
                obj.DockButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'DockTooltip' ) )
            end

        end % set.DockTooltip

        function value = get.HelpTooltip( obj )

            value = obj.HelpButton.TooltipString;

        end % get.HelpTooltip

        function set.HelpTooltip( obj, value )

            try
                obj.HelpButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'HelpTooltip' ) )
            end

        end % set.HelpTooltip

        function value = get.CloseTooltip( obj )

            value = obj.CloseButton.TooltipString;

        end % get.CloseTooltip

        function set.CloseTooltip( obj, value )

            try
                obj.CloseButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'CloseTooltip' ) )
            end

        end % set.CloseTooltip

        function value = get.MinimizeTooltipString( obj )

            value = obj.MinimizeButton.TooltipString;

        end % get.MinimizeTooltipString

        function set.MinimizeTooltipString( obj, value )

            try
                obj.MinimizeButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'MinimizeTooltipString' ) )
            end

        end % set.MinimizeTooltipString

        function value = get.MaximizeTooltipString( obj )

            value = obj.MaximizeButton.TooltipString;

        end % get.MaximizeTooltipString

        function set.MaximizeTooltipString( obj, value )

            try
                obj.MaximizeButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'MaximizeTooltipString' ) )
            end

        end % set.MaximizeTooltipString

        function value = get.UndockTooltipString( obj )

            value = obj.UndockButton.TooltipString;

        end % get.UndockTooltipString

        function set.UndockTooltipString( obj, value )

            try
                obj.UndockButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'UndockTooltipString' ) )
            end

        end % set.UndockTooltipString

        function value = get.DockTooltipString( obj )

            value = obj.DockButton.TooltipString;

        end % get.DockTooltipString

        function set.DockTooltipString( obj, value )

            try
                obj.DockButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'DockTooltipString' ) )
            end

        end % set.DockTooltipString

        function value = get.HelpTooltipString( obj )

            value = obj.HelpButton.TooltipString;

        end % get.HelpTooltipString

        function set.HelpTooltipString( obj, value )

            try
                obj.HelpButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'HelpTooltipString' ) )
            end

        end % set.HelpTooltipString

        function value = get.CloseTooltipString( obj )

            value = obj.CloseButton.TooltipString;

        end % get.CloseTooltipString

        function set.CloseTooltipString( obj, value )

            try
                obj.CloseButton.TooltipString = value;
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Value of ''%s'' must be a character vector or a string.', ...
                    'CloseTooltipString' ) )
            end

        end % set.CloseTooltipString

    end % tooltip accessors

    methods( Access = private )

        function onBorderWidthChanged( obj, ~, ~ )
            %onBorderWidthChanged  Event handler for BorderWidth changes

            % Mark as dirty
            obj.Dirty = true;

        end % onBorderWidthChanged

        function onBorderTypeChanged( obj, ~, ~ )
            %onBorderTypeChanged  Event handler for BorderType changes

            % Mark as dirty
            obj.Dirty = true;

        end % onBorderTypeChanged

        function onFontAngleChanged( obj, ~, ~ )
            %onFontAngleChanged  Event handler for FontAngle changes

            % Set
            fontAngle = obj.FontAngle;
            obj.TitleText.FontAngle = fontAngle;
            obj.TitlePanel.FontAngle = fontAngle;
            obj.ShadowPanel.FontAngle = fontAngle;

        end % onFontAngleChanged

        function onFontNameChanged( obj, ~, ~ )
            %onFontNameChanged  Event handler for FontName changes

            % Set
            fontName = obj.FontName;
            obj.TitleText.FontName = fontName;
            obj.TitlePanel.FontName = fontName;
            obj.ShadowPanel.FontName = fontName;

            % Mark as dirty
            obj.Dirty = true;

        end % onFontNameChanged

        function onFontSizeChanged( obj, ~, ~ )
            %onFontSizeChanged  Event handler for FontSize changes

            % Set
            fontSize = obj.FontSize;
            obj.TitleText.FontSize = fontSize;
            obj.TitlePanel.FontSize = fontSize;
            obj.ShadowPanel.FontSize = fontSize;
            obj.MinimizeButton.FontSize = fontSize;
            obj.MaximizeButton.FontSize = fontSize;
            obj.DockButton.FontSize = fontSize;
            obj.UndockButton.FontSize = fontSize;
            obj.HelpButton.FontSize = fontSize;
            obj.CloseButton.FontSize = fontSize;

            % Mark as dirty
            obj.Dirty = true;

        end % onFontSizeChanged

        function onFontUnitsChanged( obj, ~, ~ )
            %onFontUnitsChanged  Event handler for FontUnits changes

            % Set
            fontUnits = obj.FontUnits;
            obj.TitleText.FontUnits = fontUnits;
            obj.TitlePanel.FontUnits = fontUnits;
            obj.ShadowPanel.FontUnits = fontUnits;
            obj.HelpButton.FontUnits = fontUnits;
            obj.CloseButton.FontUnits = fontUnits;
            obj.DockButton.FontUnits = fontUnits;
            obj.MinimizeButton.FontUnits = fontUnits;

        end % onFontUnitsChanged

        function onFontWeightChanged( obj, ~, ~ )
            %onFontWeightChanged  Event handler for FontWeight changes

            % Set
            fontWeight = obj.FontWeight;
            obj.TitleText.FontWeight = fontWeight;
            obj.TitlePanel.FontWeight = fontWeight;
            obj.ShadowPanel.FontWeight = fontWeight;

        end % onFontWeightChanged

        function onForegroundColorChanged( obj, ~, ~ )
            %onForegroundColorChanged  Event handler for ForegroundColor changes

            obj.FourgroundColor = obj.ForegroundColor;

        end % onForegroundColorChanged

        function onTitleReturning( obj, ~, ~ )
            %onTitleReturning  Event handler for Title changes

            if strcmp( obj.TitleAccess, 'public' ) && isjsdrawing() == false
                obj.TitleAccess = 'private'; % start
                obj.Title = obj.Title_;
            end

        end % onTitleReturning

        function onTitleReturned( obj, ~, ~ )
            %onTitleReturned  Event handler for Title changes

            if isjsdrawing() == false
                obj.Title = obj.NullTitle; % unset Title
            end
            obj.TitleAccess = 'public'; % finish

        end % onTitleReturned

        function onTitleChanged( obj, ~, ~ )
            %onTitleChanged  Event handler for Title changes

            if strcmp( obj.TitleAccess, 'public' ) && isjsdrawing() == false

                % Set
                obj.TitleAccess = 'private'; % start
                title = obj.Title; % get
                if isempty( title )
                    obj.TitleText.String = obj.BlankTitle;
                    obj.TitlePanel.Title = obj.BlankTitle;
                    obj.ShadowPanel.Title = obj.BlankTitle;
                else
                    obj.TitleText.String = title;
                    obj.TitlePanel.Title = title;
                    obj.ShadowPanel.Title = title;
                end
                obj.Title_ = title; % store
                obj.Title = obj.NullTitle; % unset Title
                obj.TitleAccess = 'public'; % finish

                % Mark as dirty
                obj.Dirty = true; % TODO remove

            end

        end % onTitleChanged

        function onFigureSelectionChanged( obj, ~, eventData )
            %onFigureSelectionChanged  Event handler for figure clicks

            % Raise event if title bar button was clicked
            switch eventData.AffectedObject.SelectionType
                case 'normal' % single left click
                    if isempty( eventData.AffectedObject.CurrentObject ) % none
                        % do nothing
                    else
                        switch eventData.AffectedObject.CurrentObject
                            case obj.MinimizeButton
                                notify( obj, 'Minimizing' )
                            case obj.MaximizeButton
                                notify( obj, 'Maximizing' )
                            case obj.DockButton
                                notify( obj, 'Docking' )
                            case obj.UndockButton
                                notify( obj, 'Undocking' )
                            case obj.HelpButton
                                notify( obj, 'Helping' )
                            case obj.CloseButton
                                notify( obj, 'Closing' )
                            otherwise
                                % do nothing
                        end
                    end
                otherwise % other interaction
                    % do nothing
            end

        end % onFigureSelectionChanged

        function onButtonClicked( obj, source, eventData )
            %onButtonClicked  Event handler for title bar button clicks

            % Retrieve callback corresponding to event type
            switch eventData.EventName
                case 'Minimizing'
                    callback = obj.MinimizeButton.Callback;
                case 'Maximizing'
                    callback = obj.MaximizeButton.Callback;
                case 'Docking'
                    callback = obj.DockButton.Callback;
                case 'Undocking'
                    callback = obj.UndockButton.Callback;
                case 'Helping'
                    callback = obj.HelpButton.Callback;
                case 'Closing'
                    callback = obj.CloseRequestButton.Callback;
                otherwise
                    return
            end

            % Call callback
            if ischar( callback ) && isequal( callback, '' )
                % do nothing
            elseif ischar( callback )
                feval( callback, source, eventData )
            elseif isa( callback, 'function_handle' )
                callback( source, eventData )
            elseif iscell( callback )
                feval( callback{1}, source, eventData, callback{2:end} )
            end

        end % onButtonClicked

        function onInnerSizeChanged( obj, ~, ~ )

            % Mark as dirty
            obj.Dirty = true;

        end % onInnerSizeChanged

    end % event handlers

    methods( Access = protected )

        function redraw( obj )
            %redraw  Redraw
            %
            %  p.redraw() redraws the panel.

            % Compute positions
            iB = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            tX = 1;
            tW = max( iB(3), 1 );
            tH = obj.TitleHeight;
            tY = 1 + iB(4) - tH;
            p = obj.Padding_;
            cX = 1 + p;
            cW = max( iB(3) - 2 * p, 1 );
            cH = max( iB(4) - tH - 2 * p, 1 );
            cY = tY - p - cH;

            % Redraw title bar
            titleBar = obj.TitleBar;
            uix.setPosition( titleBar, [tX tY tW tH], 'pixels' )
            titleBar.Widths(2:end) = tH; % square buttons

            % Redraw contents
            contents = obj.Contents_;
            for ii = 1:numel( contents )
                uix.setPosition( contents(ii), [cX cY cW cH], 'pixels' )
            end

        end % redraw

        function reparent( obj, oldFigure, newFigure )
            %reparent  Reparent container
            %
            %  c.reparent(a,b) reparents the container c from the figure a
            %  to the figure b.

            % Update title text
            oldType = figuretype( oldFigure );
            newType = figuretype( newFigure );
            if ~strcmp( oldType, newType )
                switch oldType
                    case 'java'
                        obj.TitleText.Parent = [];
                    case 'js'
                        obj.TitlePanel.Parent = [];
                end
                switch newType
                    case 'java'
                        obj.TitleText.Parent = obj.TitleBar;
                        obj.redrawButtons()
                    case 'js'
                        obj.TitlePanel.Parent = obj.TitleBar;
                        obj.redrawButtons()
                end
            end

            % Update listeners
            if isempty( newFigure )
                figureSelectionListener = [];
            else
                figureSelectionListener = event.proplistener( ...
                    newFigure, findprop( newFigure, 'CurrentObject' ), ...
                    'PostSet', @obj.onFigureSelectionChanged );
            end
            obj.FigureSelectionListener = figureSelectionListener;

            % Call superclass method
            reparent@uix.Panel( obj, oldFigure, newFigure )

        end % reparent

    end % template methods

    methods( Access = protected, Static )

        function map = getThemeMap()
            %getThemeMap  Map class properties to theme attributes

            map = getThemeMap@uix.Panel();
            map.ForegroundColor = '--mw-color-primary';
            map.FourgroundColor = '--mw-color-primary';
            map.TitleColor = '--mw-backgroundColor-chatBubble';

        end % getThemeMap

    end % protected static methods

    methods( Access = private )

        function redrawButtons( obj )
            %redrawButtons  Update buttons
            %
            %  p.redrawButtons() attaches used buttons and detaches unused
            %  buttons.

            % Detach all
            obj.MinimizeButton.Parent = [];
            obj.MaximizeButton.Parent = [];
            obj.DockButton.Parent = [];
            obj.UndockButton.Parent = [];
            obj.HelpButton.Parent = [];
            obj.CloseButton.Parent = [];

            % Attach maximize or minimize
            if isempty( obj.MinimizeButton.Callback )
                % OK
            elseif obj.Minimized_
                obj.MaximizeButton.Parent = obj.TitleBar;
            else
                obj.MinimizeButton.Parent = obj.TitleBar;
            end

            % Attach dock or undock
            if isempty( obj.DockButton.Callback )
                % OK
            elseif obj.Docked_
                obj.UndockButton.Parent = obj.TitleBar;
            else
                obj.DockButton.Parent = obj.TitleBar;
            end

            % Attach help
            if isempty( obj.HelpButton.Callback )
                % OK
            else
                obj.HelpButton.Parent = obj.TitleBar;
            end

            % Attach close
            if isempty( obj.CloseButton.Callback )
                % OK
            else
                obj.CloseButton.Parent = obj.TitleBar;
            end

            % Set sizes
            obj.TitleBar.Widths(2:end) = obj.TitleBar.Position(4);

        end % redrawButtons

    end % helper methods

end % classdef

function tf = isjsdrawing()
%isjsdrawing  Detect JavaScript drawing, which accesses properties

s = dbstack();
tf = false;
for ii = 1:numel( s )
    n = strsplit( s(ii).name, '.' );
    if strcmp( n{1}, 'WebComponentController' ), tf = true; break; end
end

end % isjsdrawing

function t = figuretype( o )
%figuretype  Figure type -- 'java', 'js', or 'none'

f = ancestor( o, 'figure' );
if isempty( f )
    t = 'none';
elseif isprop( f, 'JavaFrame_I' ) && ~isempty( f.JavaFrame_I )
    t = 'java';
else
    t = 'js';
end

end % figuretype