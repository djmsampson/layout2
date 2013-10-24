classdef BoxPanel < uix.Box
    
    properties( Access = public, Dependent, AbortSet )
        BorderType
        CloseRequestFcn
        Docked
        DockFcn
        FontAngle
        FontName
        FontSize
        FontUnits
        FontWeight
        HelpFcn
        HighlightColor
        Minimized
        MinimizeFcn
        ShadowColor
        Title
        TitleForegroundColor
        TitleBackgroundColor
    end
    
    properties( Access = private )
        TitleText
        TitlePanel
        ContentsPanel
        HelpButton
        CloseButton
        DockButton
        MinimizeButton
        CData
        Docked_ = true
        Minimized_ = false
    end
    
    methods
        
        function obj = BoxPanel( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.Box( notmypv{:} );
            
            % Create decorations
            titleColor = [0.75 0.9 1.0];
            contentsPanel = uipanel( 'Internal', true, 'Parent', obj, ...
                'Units', 'normalized', 'Position', [0 0 1 1], ...
                'HitTest', 'off', 'BorderType', 'etchedin', ...
                'BackgroundColor', obj.BackgroundColor );
            titlePanel = uipanel( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'HitTest', 'off', ...
                'BorderType', 'etchedin', ...
                'BackgroundColor', titleColor );
            titleText = uicontrol( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'HitTest', 'off', 'Style', 'text', ...
                'String', '', 'HorizontAlalignment', 'left', ...
                'BackgroundColor', titleColor );
            
            % Create buttons
            cData.Close = uix.loadIcon( 'panelClose.png' );
            cData.Dock = uix.loadIcon( 'panelDock.png' );
            cData.Undock = uix.loadIcon( 'panelUndock.png' );
            cData.Help = uix.loadIcon( 'panelHelp.png' );
            cData.Minimize = uix.loadIcon( 'panelMinimize.png' );
            cData.Maximize = uix.loadIcon( 'panelMaximize.png' );
            closeButton = uicontrol( 'Internal', true, 'Parent', obj, ...
                'Style', 'checkbox', 'CData', cData.Close, ...
                'BackgroundColor', titleColor, 'Visible', 'off', ...
                'TooltipString', 'Close this panel' );
            dockButton = uicontrol( 'Internal', true, 'Parent', obj, ...
                'Style', 'checkbox', 'CData', cData.Undock, ...
                'BackgroundColor', titleColor, 'Visible', 'off', ...
                'TooltipString', 'Undock this panel' );
            helpButton = uicontrol( 'Internal', true, 'Parent', obj, ...
                'Style', 'checkbox', 'CData', cData.Help, ...
                'BackgroundColor', titleColor, 'Visible', 'off', ...
                'TooltipString', 'Get help on this panel' );
            minimizeButton = uicontrol( 'Internal', true, 'Parent', obj, ...
                'Style', 'checkbox', 'CData', cData.Minimize, ...
                'BackgroundColor', titleColor, 'Visible', 'off', ...
                'TooltipString', 'Minimize this panel' );
            
            % Store properties
            obj.TitlePanel = titlePanel;
            obj.TitleText = titleText;
            obj.ContentsPanel = contentsPanel;
            obj.HelpButton = helpButton;
            obj.CloseButton = closeButton;
            obj.DockButton = dockButton;
            obj.MinimizeButton = minimizeButton;
            obj.CData = cData;
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.BorderType( obj )
            
            value = obj.TitlePanel.BorderType;
            
        end % get.BorderType
        
        function set.BorderType( obj, value )
            
            % Set
            obj.TitlePanel.BorderType = value;
            obj.ContentsPanel.BorderType = value;
            
        end % set.BorderType
        
        function value = get.FontAngle( obj )
            
            value = obj.TitleText.FontAngle;
            
        end % get.FontAngle
        
        function set.FontAngle( obj, value )
            
            % Set
            obj.TitleText.FontAngle = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.FontAngle
        
        function value = get.FontName( obj )
            
            value = obj.TitleText.FontName;
            
        end % get.FontName
        
        function set.FontName( obj, value )
            
            % Set
            obj.TitleText.FontName = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.FontName
        
        function value = get.FontSize( obj )
            
            value = obj.TitleText.FontSize;
            
        end % get.FontSize
        
        function set.FontSize( obj, value )
            
            % Set
            obj.TitleText.FontSize = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.FontSize
        
        function value = get.FontUnits( obj )
            
            value = obj.TitleText.FontUnits;
            
        end % get.FontUnits
        
        function set.FontUnits( obj, value )
            
            obj.TitleText.FontUnits = value;
            
        end % set.FontUnits
        
        function value = get.FontWeight( obj )
            
            value = obj.TitleText.FontWeight;
            
        end % get.FontWeight
        
        function set.FontWeight( obj, value )
            
            % Set
            obj.TitleText.FontWeight = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.FontWeight
        
        function value = get.HighlightColor( obj )
            
            value = obj.TitlePanel.HighlightColor;
            
        end % get.HighlightColor
        
        function set.HighlightColor( obj, value )
            
            obj.TitlePanel.HighlightColor = value;
            obj.ContentsPanel.HighlightColor = value;
            
        end % set.HighlightColor
        
        function value = get.ShadowColor( obj )
            
            value = obj.TitlePanel.ShadowColor;
            
        end % get.ShadowColor
        
        function set.ShadowColor( obj, value )
            
            obj.TitlePanel.ShadowColor = value;
            obj.ContentsPanel.ShadowColor = value;
            
        end % set.ShadowColor
        
        function value = get.Title( obj )
            
            value = obj.TitleText.String;
            
        end % get.Title
        
        function set.Title( obj, value )
            
            obj.TitleText.String = value;
            
        end % set.Title
        
        function value = get.TitleForegroundColor( obj )
            
            value = obj.TitleText.ForegroundColor;
            
        end % get.TitleForegroundColor
        
        function set.TitleForegroundColor( obj, value )
            
            obj.TitleText.ForegroundColor = value;
            
        end % set.TitleForegroundColor
        
        function value = get.TitleBackgroundColor( obj )
            
            value = obj.TitlePanel.BackgroundColor;
            
        end % get.TitleBackgroundColor
        
        function set.TitleBackgroundColor( obj, value )
            
            obj.TitlePanel.BackgroundColor = value;
            obj.TitleText.BackgroundColor = value;
            obj.HelpButton.BackgroundColor = value;
            obj.CloseButton.BackgroundColor = value;
            obj.DockButton.BackgroundColor = value;
            obj.MinimizeButton.BackgroundColor = value;
            
        end % set.TitleBackgroundColor
        
        function value = get.CloseRequestFcn( obj )
            
            value = obj.CloseButton.Callback;
            
        end % get.CloseRequestFcn
        
        function set.CloseRequestFcn( obj, value )
            
            % Set
            obj.CloseButton.Callback = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.CloseRequestFcn
        
        function value = get.DockFcn( obj )
            
            value = obj.DockButton.Callback;
            
        end % get.DockFcn
        
        function set.DockFcn( obj, value )
            
            % Set
            obj.DockButton.Callback = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.DockFcn
        
        function value = get.HelpFcn( obj )
            
            value = obj.HelpButton.Callback;
            
        end % get.HelpFcn
        
        function set.HelpFcn( obj, value )
            
            % Set
            obj.HelpButton.Callback = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.HelpFcn
        
        function value = get.MinimizeFcn( obj )
            
            value = obj.MinimizeButton.Callback;
            
        end % get.MinimizeFcn
        
        function set.MinimizeFcn( obj, value )
            
            % Set
            obj.MinimizeButton.Callback = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.MinimizeFcn
        
        function value = get.Docked( obj )
            
            value = obj.Docked_;
            
        end % get.Docked
        
        function set.Docked( obj, value )
            
            % Check
            assert( isequal( value, true ) || isequal( value, false ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Docked'' must be true or false.' )
            
            % Set
            obj.Docked_ = value;
            
            % Update button
            dockButton = obj.DockButton;
            if value
                dockButton.CData = obj.CData.Undock;
                dockButton.TooltipString = 'Undock this panel';
            else
                dockButton.CData = obj.CData.Dock;
                dockButton.TooltipString = 'Dock this panel';
            end
            
        end % set.Docked
        
        function value = get.Minimized( obj )
            
            value = obj.Minimized_;
            
        end % get.Minimized
        
        function set.Minimized( obj, value )
            
            % Check
            assert( isequal( value, true ) || isequal( value, false ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Minimized'' must be true or false.' )
            
            % Set
            obj.Minimized_ = value;
            
            % Update button
            minimizeButton = obj.MinimizeButton;
            if value
                minimizeButton.CData = obj.CData.Maximize;
                minimizeButton.TooltipString = 'Maximize this panel';
            else
                minimizeButton.CData = obj.CData.Minimize;
                minimizeButton.TooltipString = 'Minimize this panel';
            end
            
        end % set.Minimized
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            
            % Compute positions of decorations
            titleText = obj.TitleText;
            textHeight = hgconvertunits( ancestor( obj, 'figure' ), ...
                [titleText.FontSize 0 0 0], titleText.FontUnits, ...
                'pixels', obj.Parent );
            titleHeight = ceil( textHeight(1) * 1.2 );
            textPosition = [3, bounds(4) - titleHeight - 1, ...
                bounds(3) - 4, titleHeight];
            panelPosition = [1, bounds(4) - titleHeight - 3, ...
                bounds(3), titleHeight + 4];
            buttonHeight = 9;
            buttonWidth = 10;
            buttonX = bounds(3) - buttonWidth - 4;
            buttonY = bounds(4) - titleHeight / 2 - buttonHeight / 2 - 1;
            closeButtonEnabled = ~isempty( obj.CloseRequestFcn );
            if closeButtonEnabled
                closePosition = [buttonX, buttonY, buttonWidth, buttonHeight];
                buttonX = buttonX - buttonWidth - 4;
            end
            dockButtonEnabled = ~isempty( obj.DockFcn );
            if dockButtonEnabled
                dockPosition = [buttonX, buttonY, buttonWidth, buttonHeight];
                buttonX = buttonX - buttonWidth - 4;
            end
            minimizeButtonEnabled = ~isempty( obj.MinimizeFcn );
            if minimizeButtonEnabled
                minimizePosition = [buttonX, buttonY, buttonWidth, buttonHeight];
                buttonX = buttonX - buttonWidth - 4;
            end
            helpButtonEnabled = ~isempty( obj.HelpFcn );
            if helpButtonEnabled
                helpPosition = [buttonX, buttonY, buttonWidth, buttonHeight];
            end
            
            % Set positions of decorations
            obj.TitleText.Position = textPosition;
            obj.TitlePanel.Position = panelPosition;
            if closeButtonEnabled
                obj.CloseButton.Position = closePosition;
                obj.CloseButton.Visible = 'on';
            else
                obj.CloseButton.Visible = 'off';
            end
            if dockButtonEnabled
                obj.DockButton.Position = dockPosition;
                obj.DockButton.Visible = 'on';
            else
                obj.DockButton.Visible = 'off';
            end
            if minimizeButtonEnabled
                obj.MinimizeButton.Position = minimizePosition;
                obj.MinimizeButton.Visible = 'on';
            else
                obj.MinimizeButton.Visible = 'off';
            end
            if helpButtonEnabled
                obj.HelpButton.Position = helpPosition;
                obj.HelpButton.Visible = 'on';
            else
                obj.HelpButton.Visible = 'off';
            end
            
            % Compute positions of contents
            c = numel( obj.Contents_ );
            widths = -ones( [c 1] );
            minimumWidths = ones( [c 1] );
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            xSizes = uix.calcPixelSizes( bounds(3) - 4, widths, ...
                minimumWidths, padding, spacing );
            xPositions = [cumsum( [0; xSizes(1:c-1,:)] ) + padding + ...
                spacing * transpose( 0:c-1 ) + 3, xSizes];
            yPositions = [padding + 3, max( bounds(4) - 2 * padding - ...
                titleHeight - 6, 1 )];
            yPositions = repmat( yPositions, [c 1] );
            positions = [xPositions(:,1), yPositions(:,1), ...
                xPositions(:,2), yPositions(:,2)];
            
            % Set positions of contents
            children = obj.Contents_;
            for ii = 1:numel( children )
                child = children(ii);
                child.Units = 'pixels';
                if isa( child, 'matlab.graphics.axis.Axes' )
                    child.( child.ActivePositionProperty ) = positions(ii,:);
                else
                    child.Position = positions(ii,:);
                end
            end
            
        end % redraw
        
    end % template methods
    
end % classdef