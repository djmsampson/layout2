classdef BoxPanel < uix.Container
    
    properties( Dependent )
        Title % title
        BorderWidth % border width [pixels]
        BorderType % border type [none|line|beveledin|beveledout|etchedin|etchedout]
        FontAngle % font angle [normal|italic|oblique]
        FontName % font name
        FontSize % font size
        FontUnits % font units
        FontWeight % font weight [normal|bold]
        ForegroundColor % title text color [RGB]
        HighlightColor % border highlight color [RGB]
        ShadowColor % border shadow color [RGB]
        TitleColor % title background color [RGB]
        CloseRequestFcn % close request callback
        Docked % docked [true|false]
        DockFcn % dock callback
        HelpFcn % help callback
        Minimized % minimized [true|false]
        MinimizeFcn % minimize callback
    end
    
    properties( Access = private )
        LocationObserver % location observer
        Titlebar % titlebar
        TopBorder % border image
        MiddleBorder % border image
        BottomBorder % border image
        LeftBorder % border image
        RightBorder % border image
        BorderWidth_ = 0 % backing for BorderWidth
        BorderType_ = 'none' % backing for BorderType
        HighlightColor_ = [1 1 1] % backing for HighlightColor
        ShadowColor_ = [0.7 0.7 0.7] % backing for ShadowColor
        HelpButton % title button
        CloseButton % title button
        DockButton % title button
        MinimizeButton % title button
        Docked_ = true % backing for Docked
        Minimized_ = false % backing for Minimized
    end
    
    properties( Access = private, Constant )
        ButtonCData = uix.BoxPanel.getButtonCData() % button image data
    end
    
    methods
        
        function obj = BoxPanel( varargin )
            %uix.BoxPanel  Box panel
            
            % Call superclass constructor
            obj@uix.Container()
            
            % Create location observer
            locationObserver = uix.LocationObserver( obj );
            
            % Create title and borders
            titlebar = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'text', 'Units', 'pixels', ...
                'HorizontalAlignment', 'left' );
            topBorder = uix.Image( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels' );
            middleBorder = uix.Image( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels' );
            bottomBorder = uix.Image( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels' );
            leftBorder = uix.Image( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels' );
            rightBorder = uix.Image( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels' );
            
            % Create buttons
            cData = obj.ButtonCData;
            closeButton = matlab.ui.control.StyleControl( ...
                'Internal', true, 'Parent', obj, 'Style', 'checkbox', ...
                'CData', cData.Close, 'Visible', 'off', ...
                'TooltipString', 'Close this panel' );
            dockButton = matlab.ui.control.StyleControl( ...
                'Internal', true, 'Parent', obj, 'Style', 'checkbox', ...
                'CData', cData.Undock, 'Visible', 'off', ...
                'TooltipString', 'Undock this panel' );
            helpButton = matlab.ui.control.StyleControl( ...
                'Internal', true, 'Parent', obj, 'Style', 'checkbox', ...
                'CData', cData.Help, 'Visible', 'off', ...
                'TooltipString', 'Get help on this panel' );
            minimizeButton = matlab.ui.control.StyleControl( ...
                'Internal', true, 'Parent', obj, 'Style', 'checkbox', ...
                'CData', cData.Minimize, 'Visible', 'off', ...
                'TooltipString', 'Minimize this panel' );
            
            % Store properties
            obj.LocationObserver = locationObserver;
            obj.Titlebar = titlebar;
            obj.TopBorder = topBorder;
            obj.MiddleBorder = middleBorder;
            obj.BottomBorder = bottomBorder;
            obj.LeftBorder = leftBorder;
            obj.RightBorder = rightBorder;
            obj.HelpButton = helpButton;
            obj.CloseButton = closeButton;
            obj.DockButton = dockButton;
            obj.MinimizeButton = minimizeButton;
            
            % Set properties
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.BorderWidth( obj )
            
            value = obj.BorderWidth_;
            
        end % get.BorderWidth
        
        function set.BorderWidth( obj, value )
            
            obj.BorderWidth_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.BorderWidth
        
        function value = get.BorderType( obj )
            
            value = obj.BorderType_;
            
        end % get.BorderType
        
        function set.BorderType( obj, value )
            
            obj.BorderType_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.BorderType
        
        function value = get.FontAngle( obj )
            
            value = obj.Titlebar.FontAngle;
            
        end % get.FontAngle
        
        function set.FontAngle( obj, value )
            
            obj.Titlebar.FontAngle = value;
            
        end % set.FontAngle
        
        function value = get.FontName( obj )
            
            value = obj.Titlebar.FontName;
            
        end % get.FontName
        
        function set.FontName( obj, value )
            
            % Set
            obj.Titlebar.FontName = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.FontName
        
        function value = get.FontSize( obj )
            
            value = obj.Titlebar.FontSize;
            
        end % get.FontSize
        
        function set.FontSize( obj, value )
            
            % Set
            obj.Titlebar.FontSize = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.FontSize
        
        function value = get.FontUnits( obj )
            
            value = obj.Titlebar.FontUnits;
            
        end % get.FontUnits
        
        function set.FontUnits( obj, value )
            
            obj.Titlebar.FontUnits = value;
            
        end % set.FontUnits
        
        function value = get.FontWeight( obj )
            
            value = obj.Titlebar.FontWeight;
            
        end % get.FontWeight
        
        function set.FontWeight( obj, value )
            
            obj.Titlebar.FontWeight = value;
            
        end % set.FontWeight
        
        function value = get.ForegroundColor( obj )
            
            value = obj.Titlebar.ForegroundColor;
            
        end % get.ForegroundColor
        
        function set.ForegroundColor( obj, value )
            
            obj.Titlebar.ForegroundColor = value;
            
        end % set.ForegroundColor
        
        function value = get.HighlightColor( obj )
            
            value = obj.HighlightColor_;
            
        end % get.HighlightColor
        
        function set.HighlightColor( obj, value )
            
            % Set
            obj.HighlightColor_ = value;
            
            % Redraw borders
            obj.redrawBorders()
            
        end % set.HighlightColor
        
        function value = get.ShadowColor( obj )
            
            value = obj.ShadowColor_;
            
        end % get.ShadowColor
        
        function set.ShadowColor( obj, value )
            
            % Set
            obj.ShadowColor_ = value;
            
            % Redraw borders
            obj.redrawBorders()
            
        end % set.ShadowColor
        
        function value = get.Title( obj )
            
            value = obj.Titlebar.String;
            
        end % get.Title
        
        function set.Title( obj, value )
            
            obj.Titlebar.String = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Title
        
        function value = get.TitleColor( obj )
            
            value = obj.Titlebar.BackgroundColor;
            
        end % get.TitleColor
        
        function set.TitleColor( obj, value )
            
            obj.Titlebar.BackgroundColor = value;
            obj.HelpButton.BackgroundColor = value;
            obj.CloseButton.BackgroundColor = value;
            obj.DockButton.BackgroundColor = value;
            obj.MinimizeButton.BackgroundColor = value;
            
        end % set.TitleColor
        
        function value = get.CloseRequestFcn( obj )
            
            value = obj.CloseButton.Callback;
            
        end % get.CloseRequestFcn
        
        function set.CloseRequestFcn( obj, value )
            
            % Set
            obj.CloseButton.Callback = value;
            
            % Redraw buttons
            obj.redrawButtons()
            
        end % set.CloseRequestFcn
        
        function value = get.DockFcn( obj )
            
            value = obj.DockButton.Callback;
            
        end % get.DockFcn
        
        function set.DockFcn( obj, value )
            
            % Set
            obj.DockButton.Callback = value;
            
            % Redraw buttons
            obj.redrawButtons()
            
        end % set.DockFcn
        
        function value = get.HelpFcn( obj )
            
            value = obj.HelpButton.Callback;
            
        end % get.HelpFcn
        
        function set.HelpFcn( obj, value )
            
            % Set
            obj.HelpButton.Callback = value;
            
            % Redraw buttons
            obj.redrawButtons()
            
        end % set.HelpFcn
        
        function value = get.MinimizeFcn( obj )
            
            value = obj.MinimizeButton.Callback;
            
        end % get.MinimizeFcn
        
        function set.MinimizeFcn( obj, value )
            
            % Set
            obj.MinimizeButton.Callback = value;
            
            % Redraw buttons
            obj.redrawButtons()
            
        end % set.MinimizeFcn
        
        function value = get.Docked( obj )
            
            value = obj.Docked_;
            
        end % get.Docked
        
        function set.Docked( obj, value )
            
            % Check
            assert( islogical( value ) && isequal( size( value ), [1 1] ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Docked'' must be true or false.' )
            
            % Set
            obj.Docked_ = value;
            
            % Update button
            dockButton = obj.DockButton;
            if value
                dockButton.CData = obj.ButtonCData.Undock;
                dockButton.TooltipString = 'Undock this panel';
            else
                dockButton.CData = obj.ButtonCData.Dock;
                dockButton.TooltipString = 'Dock this panel';
            end
            
        end % set.Docked
        
        function value = get.Minimized( obj )
            
            value = obj.Minimized_;
            
        end % get.Minimized
        
        function set.Minimized( obj, value )
            
            % Check
            assert( islogical( value ) && isequal( size( value ), [1 1] ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Minimized'' must be true or false.' )
            
            % Set
            obj.Minimized_ = value;
            
            % Update button
            minimizeButton = obj.MinimizeButton;
            if value
                minimizeButton.CData = obj.ButtonCData.Maximize;
                minimizeButton.TooltipString = 'Maximize this panel';
            else
                minimizeButton.CData = obj.ButtonCData.Minimize;
                minimizeButton.TooltipString = 'Minimize this panel';
            end
            
        end % set.Minimized
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw
            %
            %  p.redraw() redraws the panel.
            %
            %  See also: redrawBorders, redrawButtons
            
            % Compute positions
            location = obj.LocationObserver.Location;
            width = ceil( location(1) + location(3) ) - floor( location(1) );
            height = ceil( location(2) + location(4) ) - floor( location(2) );
            titleHeight = obj.Titlebar.Extent(4);
            switch obj.BorderType_
                case 'none'
                    borderSize = 0;
                case {'line','beveledin','beveledout'}
                    borderSize = obj.BorderWidth_;
                case {'etchedin','etchedout'}
                    borderSize = obj.BorderWidth_ * 2;
            end
            padding = obj.Padding_;
            xSizes = max( [width - 2 * borderSize, ...
                1 + 2 * padding] );
            ySizes = [titleHeight; max( [height - ...
                3 * borderSize - titleHeight, 1 + 2 * padding] )];
            titlePosition = [1 + borderSize, 1 + 2 * borderSize + ySizes(2), ...
                xSizes, ySizes(1)];
            contentsPosition = [1 + borderSize + padding, ...
                1 + borderSize + padding, xSizes - 2 * padding, ...
                ySizes(2) - 2 * padding];
            topPosition = [1 + borderSize, 1 + 2 * borderSize + ...
                sum( ySizes ), xSizes, borderSize];
            middlePosition = [1 + borderSize, 1 + borderSize + ...
                ySizes(2), xSizes, borderSize];
            bottomPosition = [1 + borderSize, 1, xSizes, borderSize];
            leftPosition = [1, 1, borderSize, 3 * borderSize + ...
                sum( ySizes )];
            rightPosition = [1 + borderSize + xSizes, 1, ...
                borderSize, 3 * borderSize + sum( ySizes )];
            
            % Set decorations positions
            obj.Titlebar.Position = titlePosition;
            obj.TopBorder.Position = topPosition;
            obj.MiddleBorder.Position = middlePosition;
            obj.BottomBorder.Position = bottomPosition;
            obj.LeftBorder.Position = leftPosition;
            obj.RightBorder.Position = rightPosition;
            
            % Redraw borders
            obj.redrawBorders()
            
            % Redraw buttons
            obj.redrawButtons()
            
            % Set positions and visibility
            children = obj.Contents_;
            selection = numel( children );
            for ii = 1:numel( children )
                child = children(ii);
                if ii == selection
                    child.Visible = 'on';
                    child.Units = 'pixels';
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        child.( child.ActivePositionProperty ) = contentsPosition;
                        child.ContentsVisible = 'on';
                    else
                        child.Position = contentsPosition;
                    end
                else
                    child.Visible = 'off';
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        child.ContentsVisible = 'off';
                    end
                end
            end
            
        end % redraw
        
        function reparent( obj, oldAncestors, newAncestors )
            %reparent  Reparent container
            %
            %  c.reparent(a,b) reparents the container c from the ancestors
            %  a to the ancestors b.
            
            % Refresh location observer
            locationObserver = uix.LocationObserver( [newAncestors; obj] );
            obj.LocationObserver = locationObserver;
            
            % Call superclass method
            reparent@uix.Container( obj, oldAncestors, newAncestors )
            
        end % reparent
        
    end % template methods
    
    methods
        
        function redrawButtons( obj )
            %redrawButtons  Redraw buttons
            %
            %  p.redrawButtons() redraws the titlebar buttons.
            
            % Get button positions
            titlebarPosition = obj.Titlebar.Position; % position
            h = 9; % height
            w = 10; % width
            s = 4; % spacing
            x = titlebarPosition(1) + titlebarPosition(3) - w - s; % x
            y = titlebarPosition(2) + titlebarPosition(4)/2 - h/2; % y
            closeButtonEnabled = ~isempty( obj.CloseRequestFcn );
            if closeButtonEnabled
                closePosition = [x y w h];
                x = x - w - s;
            end
            dockButtonEnabled = ~isempty( obj.DockFcn );
            if dockButtonEnabled
                dockPosition = [x y w h];
                x = x - w - s;
            end
            minimizeButtonEnabled = ~isempty( obj.MinimizeFcn );
            if minimizeButtonEnabled
                minimizePosition = [x y w h];
                x = x - w - s;
            end
            helpButtonEnabled = ~isempty( obj.HelpFcn );
            if helpButtonEnabled
                helpPosition = [x y w h];
            end
            
            % Paint buttons
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
            
        end % redrawButtons
        
        function redrawBorders( obj )
            %redrawBorders  Redraw borders
            %
            %  p.redrawBorders() redraws the panel borders.
            
            % Get borders
            topBorder = obj.TopBorder;
            middleBorder = obj.MiddleBorder;
            bottomBorder = obj.BottomBorder;
            leftBorder = obj.LeftBorder;
            rightBorder = obj.RightBorder;
            
            % Get border positions
            topPosition = topBorder.Position;
            middlePosition = middleBorder.Position;
            bottomPosition = bottomBorder.Position;
            leftPosition = leftBorder.Position;
            rightPosition = rightBorder.Position;
            
            % Compute border masks
            switch obj.BorderType_
                case {'none','line'}
                    topMask = true( topPosition([4 3]) );
                    middleMask = true( middlePosition([4 3]) );
                    bottomMask = true( bottomPosition([4 3]) );
                    leftMask = true( leftPosition([4 3]) );
                    rightMask = true( rightPosition([4 3]) );
                case 'beveledin'
                    topMask = false( topPosition([4 3]) );
                    middleMask = false( middlePosition([4 3]) );
                    bottomMask = true( bottomPosition([4 3]) );
                    leftMask = false( leftPosition([4 3]) );
                    leftMask(end-leftPosition(3)+1:end,:) = ...
                        fliplr( tril( ones( leftPosition(3) ) ) == 1 );
                    rightMask = true( rightPosition([4 3]) );
                    rightMask(1:leftPosition(3),:) = ...
                        fliplr( tril( ones( leftPosition(3) ) ) == 1 );
                case 'beveledout'
                    topMask = true( topPosition([4 3]) );
                    middleMask = true( middlePosition([4 3]) );
                    bottomMask = false( bottomPosition([4 3]) );
                    leftMask = true( leftPosition([4 3]) );
                    leftMask(end-leftPosition(3)+1:end,:) = ...
                        fliplr( tril( ones( leftPosition(3) ) ) == 0 );
                    rightMask = false( rightPosition([4 3]) );
                    rightMask(1:leftPosition(3),:) = ...
                        fliplr( tril( ones( leftPosition(3) ) ) == 0 );
                case 'etchedin'
                    topMask = [false( [topPosition(4)/2, topPosition(3)] ); ...
                        true( [topPosition(4)/2, topPosition(3)] )];
                    middleMask = [false( [middlePosition(4)/2, middlePosition(3)] ); ...
                        true( [middlePosition(4)/2, middlePosition(3)] )];
                    bottomMask = [false( [bottomPosition(4)/2, bottomPosition(3)] ); ...
                        true( [bottomPosition(4)/2, bottomPosition(3)] )];
                    leftMask = [false( [leftPosition(4), leftPosition(3)/2] ), ...
                        true( [leftPosition(4), leftPosition(3)/2] )];
                    leftMask(1:leftPosition(3)/2,:) = false;
                    leftMask(end-leftPosition(3)/2+1:end,1:leftPosition(3)/2) = ...
                        fliplr( tril( ones( leftPosition(3)/2 ) ) == 1 );
                    leftMask(end-leftPosition(3)+1:end-leftPosition(3)/2,leftPosition(3)/2+1:end) = ...
                        fliplr( tril( ones( leftPosition(3)/2 ) ) == 0 );
                    rightMask = [false( [rightPosition(4), rightPosition(3)/2] ), ...
                        true( [rightPosition(4), rightPosition(3)/2] )];
                    rightMask(end-rightPosition(3)/2+1:end,:) = true;
                    rightMask(rightPosition(3)/2+1:rightPosition(3),1:rightPosition(3)/2) = ...
                        fliplr( tril( ones( rightPosition(3)/2 ) ) == 0 );
                    rightMask(1:rightPosition(3)/2,rightPosition(3)/2+1:end) = ...
                        fliplr( tril( ones( rightPosition(3)/2 ) ) == 1 );
                case 'etchedout'
                    topMask = [true( [topPosition(4)/2, topPosition(3)] ); ...
                        false( [topPosition(4)/2, topPosition(3)] )];
                    middleMask = [true( [middlePosition(4)/2, middlePosition(3)] ); ...
                        false( [middlePosition(4)/2, middlePosition(3)] )];
                    bottomMask = [true( [bottomPosition(4)/2, bottomPosition(3)] ); ...
                        false( [bottomPosition(4)/2, bottomPosition(3)] )];
                    leftMask = [true( [leftPosition(4), leftPosition(3)/2] ), ...
                        false( [leftPosition(4), leftPosition(3)/2] )];
                    leftMask(1:leftPosition(3)/2,:) = true;
                    leftMask(end-leftPosition(3)/2+1:end,1:leftPosition(3)/2) = ...
                        fliplr( tril( ones( leftPosition(3)/2 ) ) == 0 );
                    leftMask(end-leftPosition(3)+1:end-leftPosition(3)/2,leftPosition(3)/2+1:end) = ...
                        fliplr( tril( ones( leftPosition(3)/2 ) ) == 1 );
                    rightMask = [true( [rightPosition(4), rightPosition(3)/2] ), ...
                        false( [rightPosition(4), rightPosition(3)/2] )];
                    rightMask(end-rightPosition(3)/2+1:end,:) = false;
                    rightMask(rightPosition(3)/2+1:rightPosition(3),1:rightPosition(3)/2) = ...
                        fliplr( tril( ones( rightPosition(3)/2 ) ) == 1 );
                    rightMask(1:rightPosition(3)/2,rightPosition(3)/2+1:end) = ...
                        fliplr( tril( ones( rightPosition(3)/2 ) ) == 0 );
            end
            
            % Convert masks to color data
            highlightColor = uix.Image.rgb2int( obj.HighlightColor_ );
            shadowColor = uix.Image.rgb2int( obj.ShadowColor_ );
            topJData = mask2jdata( topMask, highlightColor, shadowColor );
            middleJData = mask2jdata( middleMask, highlightColor, shadowColor );
            bottomJData = mask2jdata( bottomMask, highlightColor, shadowColor );
            leftJData = mask2jdata( leftMask, highlightColor, shadowColor );
            rightJData = mask2jdata( rightMask, highlightColor, shadowColor );
            
            % Paint borders
            topBorder.JData = topJData;
            middleBorder.JData = middleJData;
            bottomBorder.JData = bottomJData;
            leftBorder.JData = leftJData;
            rightBorder.JData = rightJData;
            
            function c = mask2jdata( m, h, s )
                
                c = repmat( s, size( m ) );
                c(m) = h;
                
            end % mask2jdata
            
        end % redrawBorders
        
    end % helper methods
    
    methods( Access = private, Static )
        
        function cData = getButtonCData()
            %getButtonCData  Get button image data
            %
            %  c = uix.BoxPanel.getButtonCData() returns the image data for
            %  box panel titlebar buttons.
            
            cData.Close = uix.loadIcon( 'panelClose.png' );
            cData.Dock = uix.loadIcon( 'panelDock.png' );
            cData.Undock = uix.loadIcon( 'panelUndock.png' );
            cData.Help = uix.loadIcon( 'panelHelp.png' );
            cData.Minimize = uix.loadIcon( 'panelMinimize.png' );
            cData.Maximize = uix.loadIcon( 'panelMaximize.png' );
            
        end % getButtonCData
        
    end % static helper methods
    
end % classdef