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
        TextColor % ForegroundColor companion
        TextColor_I % backing for TextColor
        TextColorMode % TextColor mode [auto|manual]
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

            % Synchronize ForegroundColor without flipping mode
            obj.ForegroundColor_I = foregroundColor;

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

        function value = get.TextColor( obj )

            value = obj.TextColor_I; % delegate

        end % get.TextColor

        function set.TextColor( obj, value )

            obj.TextColor_I = value; % apply
            obj.TextColorMode = 'manual'; % flip mode
            obj.ForegroundColorMode = 'manual'; % mirror mode

        end % set.TextColor

        function value = get.TextColor_I( obj )

            value = obj.TitleText.ForegroundColor; % get underlying

        end % get.TextColor_I

        function set.TextColor_I( obj, value )

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

        end % set.TextColor_I

        function value = get.TextColorMode( obj )

            value = obj.ForegroundColorMode; % delegate

        end % get.TextColorMode

        function set.TextColorMode( obj, value )

            obj.ForegroundColorMode = value; % delegate

        end % set.TextColorMode

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

            obj.TextColor = obj.ForegroundColor;

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

            % Compute available space
            iB = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );

            % Compute title bar position
            tX = 1; % full width
            tW = iB(3); % full width
            [tA, tD] = fontmetrics( obj ); % ascent and descent
            tP = 0.1 * ( tD - tA ); % padding
            tP = min( tP, tA ); % not more than ascent
            tH = tD + tP;
            tY = 1 + iB(4) - tD + tA - 2 * tP;

            % Compute contents position
            cP = obj.Padding_;
            cX = 1 + cP;
            cW = iB(3) - 2 * cP;
            cW = max( cW, 0 ); % nonnegative
            cH = iB(4) - tD + tA - 2 * tP - 2 * cP;
            cH = max( cH, 0 ); % nonnegative
            cY = 1 + iB(4) - tD + tA - 2 * tP - cH - cP;

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
            map.TextColor = '--mw-color-primary';
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
            obj.TitleBar.Widths(2:end) = obj.TitleBar.Position(4) * 0.5;

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

function [a, d] = fontmetrics( obj )
%fontmetrics  Font metrics
%
%  [a,d] = fontmetrics(b) returns the distances from the top to the ascent
%  a and the descent d in pixels.

% Java font metrics
ja = [ ...
       0     0     1     3     4     5     6     7     7     8 ...
       9    10    11    12    13    12    13    14    15    16 ...
      17    17    18    19    20    21    22    23    23    24 ...
      25    26    27    27    28    29    30    31    31    32 ...
      33    34    35    35    36    37    38    39    40    40 ...
      41    42    43    44    44    45    46    47    48    49 ...
      49    50    51    52    53    54    55    56    57    58 ...
      59    59    60    61    62    63    63    64    65    66 ...
      67    67    68    69    70    71    72    72    73    74 ...
      75    76    76    77    78    79    80    81    81    82 ...
      83    84    85    85    86    87    88    89    90    90 ...
      91    92    93    94    94    95    96    97    98    98 ...
      99   100   101   102   103   103   104   106   107   108 ...
     108   109   110   111   112   113   113   114   115   116 ...
     117   117   118   119   120   121   122   122   123   124 ...
     125   126   126   127   128   129   130   130   131   132 ...
     133   134   135   135   136   137   138   139   139   140 ...
     141   142   143   144   144   145   146   147   148   148 ...
     149   150   151   152   153   153   154   155   156   158 ...
     158   159   160   161   162   162   163   164   165   166 ...
    ]/2.25;
jd = [ ...
       3     6    10    14    18    22    25    29    32    36 ...
      40    43    47    50    54    58    61    65    68    72 ...
      76    80    84    87    91    95    98   102   105   109 ...
     112   116   120   124   128   131   135   138   142   146 ...
     149   153   157   160   164   167   171   175   178   182 ...
     186   189   193   197   200   204   207   211   215   218 ...
     222   226   229   233   236   241   245   248   252   256 ...
     259   263   267   270   274   277   281   285   288   292 ...
     296   299   303   306   310   314   317   321   325   328 ...
     332   336   339   343   346   350   354   357   361   365 ...
     368   372   375   379   383   386   390   394   397   401 ...
     405   408   412   415   419   423   426   430   434   437 ...
     441   444   448   452   455   459   463   467   471   475 ...
     478   482   485   489   493   496   500   504   507   511 ...
     514   518   522   525   529   533   536   540   544   547 ...
     551   554   558   562   565   569   573   576   580   583 ...
     587   591   594   598   602   605   609   613   616   620 ...
     623   627   631   634   638   642   645   649   652   656 ...
     660   663   667   671   674   678   682   685   689   693 ...
     697   701   704   708   712   715   719   722   726   730 ...
    ]/2.25;

% JavaScript font metrics
wa = [ ...
       1     4     2     4     5     7     8     9    11    11 ...
      10    12    15    14    15    16    17    18    19    19 ...
      22    24    25    23    25    28    27    29    30    32 ...
      32    33    33    36    37    37    38    39    40    41 ...
      42    43    44    46    46    46    47    50    50    51 ...
      51    53    54    56    56    57    59    58    59    60 ...
      63    63    64    65    66    67    68    70    71    73 ...
      71    72    74    75    76    77    78    80    79    82 ...
      84    82    85    85    86    88    88    89    91    92 ...
      94    93    93    97    96    99    99    99   101   102 ...
     101   105   106   106   106   107   111   110   110   112 ...
     113   114   116   117   118   119   120   120   121   121 ...
     123   124   126   127   128   129   130   129   133   134 ...
     133   134   135   137   138   139   140   141   141   144 ...
     143   146   145   146   148   149   151   151   152   154 ...
     155   154   157   156   158   159   160   162   162   161 ...
     165   166   166   168   167   169   170   171   173   173 ...
     175   176   175   177   179   179   182   181   183   183 ...
     184   186   187   189   190   188   190   193   192   194 ...
     194   196   197   198   200   201   201   203   202   204 ...
     ]/2.25;
wd = [ ...
       4     9    11    15    19    24    28    32    35    40 ...
      41    45    51    54    58    62    66    70    73    76 ...
      82    86    90    91    96   102   103   108   111   116 ...
     120   123   126   131   135   138   141   146   149   153 ...
     158   162   166   170   174   176   180   186   188   192 ...
     195   200   204   208   212   216   220   222   226   230 ...
     236   239   242   246   250   254   258   262   266   271 ...
     272   276   280   284   288   292   296   301   302   308 ...
     312   314   320   322   326   331   334   338   342   346 ...
     351   352   356   363   364   370   372   376   381   384 ...
     386   393   396   400   402   406   413   415   418   423 ...
     427   430   435   438   443   447   450   452   456   460 ...
     464   468   472   476   480   484   488   490   496   500 ...
     503   506   510   514   518   522   526   530   533   538 ...
     540   546   548   552   556   560   565   568   572   576 ...
     580   582   588   590   595   598   602   606   610   612 ...
     618   622   625   630   632   636   640   644   648   652 ...
     657   660   662   666   672   675   680   682   687   690 ...
     694   698   702   707   710   712   717   722   724   728 ...
     732   737   740   744   749   752   756   761   762   767 ...
     ]/2.25;

f = ancestor( obj, 'figure' );
s = min( obj.FontSize, 200 );
if isempty( f ) || ~isprop( f, 'JavaFrame_I' ) || ~isempty( f.JavaFrame_I )
    a = ja(s);
    d = jd(s);
else
    a = wa(s);
    d = wd(s);
end

end % fontmetrics