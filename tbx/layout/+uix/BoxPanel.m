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
        TitleAccess = 'public' % 'private' when getting or setting Title, 'public' otherwise
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
        TitleForegroundColor % ForegroundColor companion
        TitleForegroundColor_I % backing for TitleForegroundColor
        TitleForegroundColorMode % TitleForegroundColor mode [auto|manual]
    end

    properties( Access = public, Hidden )
        TitleColorMode % TitleColor mode [auto|manual]
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
            foregroundColor = [0.1294 0.1294 0.1294]; % --mw-color-primary
            titleColor = [0.8706 0.9373 1.0000]; % --mw-backgroundColor-chatBubble

            % Create title bar
            titleBar = uix.HBox( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'BackgroundColor', titleColor );
            titleText = uicontrol( 'Parent', titleBar, ...
                'Style', 'text', 'HorizontalAlignment', 'left', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', titleColor ); % for Java

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

            value = obj.TitleBar.BackgroundColor;

        end % get.TitleColor_I

        function set.TitleColor_I( obj, value )

            % Set underlying
            obj.TitleBar.BackgroundColor = value;
            obj.TitleText.BackgroundColor = value;
            obj.MinimizeButton.BackgroundColor = value;
            obj.MaximizeButton.BackgroundColor = value;
            obj.DockButton.BackgroundColor = value;
            obj.UndockButton.BackgroundColor = value;
            obj.HelpButton.BackgroundColor = value;
            obj.CloseButton.BackgroundColor = value;

        end % set.TitleColor_I

        function set.TitleColorMode( obj, value )

            try
                value = char( value ); % convert
                assert( ismember( value, {'auto','manual'} ) ) % compare
                obj.TitleColorMode = value; % store
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Property ''TitleColorMode'' must be ''auto'' or ''manual''.' ) )
            end

        end % set.TitleColorMode

        function value = get.TitleForegroundColor( obj )

            value = obj.TitleForegroundColor_I; % delegate

        end % get.TitleForegroundColor

        function set.TitleForegroundColor( obj, value )

            obj.TitleForegroundColor_I = value; % apply
            obj.TitleForegroundColorMode = 'manual'; % flip mode
            obj.ForegroundColorMode = 'manual'; % mirror mode

        end % set.TitleForegroundColor

        function value = get.TitleForegroundColor_I( obj )

            value = obj.TitleText.ForegroundColor; % get underlying

        end % get.TitleForegroundColor_I

        function set.TitleForegroundColor_I( obj, value )

            % Set underlying
            obj.TitleText.ForegroundColor = value;
            obj.MinimizeButton.ForegroundColor = value;
            obj.MaximizeButton.ForegroundColor = value;
            obj.DockButton.ForegroundColor = value;
            obj.UndockButton.ForegroundColor = value;
            obj.HelpButton.ForegroundColor = value;
            obj.CloseButton.ForegroundColor = value;

            % Mirror
            obj.ForegroundColor_I = value;

        end % set.TitleForegroundColor_I

        function value = get.TitleForegroundColorMode( obj )

            value = obj.ForegroundColorMode; % delegate

        end % get.TitleForegroundColorMode

        function set.TitleForegroundColorMode( obj, value )

            obj.ForegroundColorMode = value; % delegate

        end % set.TitleForegroundColorMode

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
            t = obj.TitleText;
            e = hgconvertunits( f, t.Extent, t.Units, 'pixels', t.Parent );
            value = e(4);

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
            obj.TitleText.FontAngle = obj.FontAngle;

        end % onFontAngleChanged

        function onFontNameChanged( obj, ~, ~ )
            %onFontNameChanged  Event handler for FontName changes

            % Set
            obj.TitleText.FontName = obj.FontName;

        end % onFontNameChanged

        function onFontSizeChanged( obj, ~, ~ )
            %onFontSizeChanged  Event handler for FontSize changes

            % Set
            fontSize = obj.FontSize;
            obj.TitleText.FontSize = fontSize;
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
            obj.HelpButton.FontUnits = fontUnits;
            obj.CloseButton.FontUnits = fontUnits;
            obj.DockButton.FontUnits = fontUnits;
            obj.MinimizeButton.FontUnits = fontUnits;

        end % onFontUnitsChanged

        function onFontWeightChanged( obj, ~, ~ )
            %onFontWeightChanged  Event handler for FontWeight changes

            % Set
            obj.TitleText.FontWeight = obj.FontWeight;

        end % onFontWeightChanged

        function onForegroundColorChanged( obj, ~, ~ )
            %onForegroundColorChanged  Event handler for ForegroundColor changes

            obj.TitleForegroundColor = obj.ForegroundColor;

        end % onForegroundColorChanged

        function onTitleReturning( obj, ~, ~ )
            %onTitleReturning  Event handler for Title changes

            if strcmp( obj.TitleAccess, 'public' ) && isjsdrawing() == false
                obj.TitleAccess = 'private'; % start
                obj.Title = obj.TitleText.String; % transfer
            end

        end % onTitleReturning

        function onTitleReturned( obj, ~, ~ )
            %onTitleReturned  Event handler for Title changes

            if isjsdrawing() == false
                obj.Title = obj.NullTitle; % unset
            end
            obj.TitleAccess = 'public'; % finish

        end % onTitleReturned

        function onTitleChanged( obj, ~, ~ )
            %onTitleChanged  Event handler for Title changes

            if strcmp( obj.TitleAccess, 'public' ) && isjsdrawing() == false

                % Set
                obj.TitleAccess = 'private'; % start
                obj.TitleText.String = obj.Title; % transfer
                obj.Title = obj.NullTitle; % unset
                obj.TitleAccess = 'public'; % finish

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
            tW = iB(3);
            tW = max( tW, 0 ); % nonnegative
            [tT, tB] = extent( obj );
            tH = tB;
            tY = iB(4) - tB + tT - 1;
            p = obj.Padding_;
            cX = 1 + p;
            cW = iB(3) - 2 * p;
            cW = max( cW, 0 ); % nonnegative
            cH = iB(4) - tH - 2 * p;
            cH = max( cH, 0 ); % nonnegative
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
            map.TitleForegroundColor = '--mw-color-primary';
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

function [t, b] = extent( obj )

jt = [1,1,1,1,2,4,4,4,5,6,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,13,13,14,15,15,15,16,16,17,17,18,18,19,19,20,20,20,21,22,22,22,23,23,24,24,25,25,26,26,27,27,28,28,28,29,29,30,30,30,31,31,32,32,33,33,34,34,35,35,35,36,36,37,37,38,38,39,39,39,40,41,41,41,42,42,43,43,44,44,45,45,45,46,46,47,47,48,48,49,49,50,50,50,51,51,52,52,53,53,54,55,55,56,57,57,57,58,58,59,59,60,60,61,61,61,62,62,63,63,64,64,65,65,65,66,66,67,67,68,68,69,69,70,70,70,71,71,72,72,73,73,74,74,74,75,76,76,76,77,77,78,78,79,79,80,80,80,81,81,82,82,83,83,84,84,85,85,85,86,86,87,87,88,88,89,89,89,90,91,91,91,92,92];
jb = [2,3,5,8,9,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,79,81,83,85,87,89,91,93,95,97,99,101,103,105,106,109,111,112,115,117,118,121,124,125,128,130,131,134,136,137,140,142,143,146,148,149,152,154,155,158,160,161,164,166,167,170,172,174,176,178,180,182,184,186,188,190,192,194,197,198,200,203,204,206,209,210,212,215,216,218,221,222,224,227,228,230,233,234,236,240,241,244,246,247,250,252,253,256,258,259,262,264,265,268,270,271,274,276,277,280,282,283,286,288,290,292,294,296,298,300,302,304,306,308,310,313,314,316,319,320,322,325,326,328,331,332,334,337,338,340,343,344,346,349,350,352,355,356,359,361,362,365,367,368,371,373,374,377,379,380,383,385,386,389,391,392,395,397,398,401,403,405];

wt=[1,1,1,1,1,1,3,2,3,2,4,4,5,4,6,8,5,8,8,8,10,9,8,11,11,11,11,10,12,14,13,14,16,14,15,16,16,17,18,17,19,19,19,21,19,20,22,22,22,22,24,24,23,23,26,25,26,27,26,27,29,29,29,30,30,30,30,32,32,31,31,33,34,33,35,35,34,37,37,36,37,38,38,38,38,40,40,39,41,41,43,43,43,45,42,44,45,44,47,46,45,46,48,47,50,47,49,51,49,51,51,52,52,52,52,54,54,54,55,55,56,57,57,56,58,58,58,58,60,59,59,59,61,61,61,63,63,63,65,65,65,66,66,66,66,66,68,67,67,69,69,69,71,70,72,72,72,73,73,74,74,74,74,76,76,77,77,77,79,79,79,78,80,80,80,80,82,81,81,84,84,84,86,85,85,87,87,87,87,88,88,88,88,90,90,89,91,91,91,93];
wb=[1,2,3,5,6,8,11,12,13,14,17,19,20,22,25,27,27,30,30,31,35,35,36,41,41,42,43,43,47,51,50,54,57,55,58,60,61,64,65,66,69,70,71,75,74,76,80,81,82,83,87,87,88,89,93,94,95,97,99,100,103,105,106,108,109,111,112,115,116,117,118,121,122,124,127,127,129,132,133,134,136,138,139,140,142,145,146,146,150,151,154,157,158,160,159,163,164,165,168,169,170,171,174,176,179,177,180,184,183,186,187,190,191,192,193,197,198,198,202,203,204,208,209,209,213,214,215,216,220,220,221,223,226,227,228,231,232,233,237,238,239,241,243,244,245,246,250,250,251,255,256,257,260,261,264,265,267,268,269,271,273,274,275,279,280,282,283,285,288,289,290,291,294,295,297,298,301,301,303,306,307,309,312,312,313,317,318,319,321,323,324,325,327,330,331,331,335,336,337,341];

f = ancestor( obj, 'figure' );
s = min( obj.FontSize, 200 );
if isempty( f ) || ~isprop( f, 'JavaFrame_I' ) || ~isempty( f.JavaFrame_I )
    t = jt(s) / 1.25;
    b = jb(s) / 1.25;
else
    t = wt(s) / 1.25;
    b = wb(s) / 1.25;
end

end % extent