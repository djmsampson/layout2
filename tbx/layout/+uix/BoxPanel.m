classdef BoxPanel < uix.Container & uix.mixin.Panel
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
    
    %  Copyright 2009-2015 The MathWorks, Inc.
    %  $Revision$ $Date$
    
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
        Minimized % minimized [true|false]
        MinimizeFcn % minimize callback
        Docked % docked [true|false]
        DockFcn % dock callback
        HelpFcn % help callback
        CloseRequestFcn % close request callback
    end
    
    properties( Access = private )
        DecorationBox % box
        TitlePanel % panel
        TitleBox % box
        TitleText % text
        TitleEmpty % flag
        MainPanel % panel
        TitleHeight = -1 % cache of title height (-1 denotes stale cache)
        MinimizeButton % title button
        DockButton % title button
        HelpButton % title button
        CloseButton % title button
        Docked_ = true % backing for Docked
        Minimized_ = false % backing for Minimized
    end
    
    properties( Access = private, Constant )
        IconMask = uix.BoxPanel.getIconMask() % icon image data
    end
    
    methods
        
        function obj = BoxPanel( varargin )
            %uix.BoxPanel  Box panel constructor
            %
            %  p = uix.BoxPanel() constructs a box panel.
            %
            %  p = uix.BoxPanel(p1,v1,p2,v2,...) sets parameter p1 to value
            %  v1, etc.
            
            % Set default colors
            foregroundColor = [1 1 1];
            backgroundColor = [0.05 0.25 0.5];
            
            % Create panels and decorations
            decorationBox = uix.VBox( ...
                'Internal', true, 'Parent', obj );
            titlePanel = uipanel( 'Parent', decorationBox );
            titleBox = uix.HBox( 'Parent', titlePanel, ...
                'BackgroundColor', backgroundColor );
            titleText = uix.Text( 'Parent', titleBox, ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'String', ' ', 'HorizontalAlignment', 'left' );
            mainPanel = uipanel( 'Parent', decorationBox );
            
            % Create buttons
            minimizeButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'Enable', 'on' );
            dockButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'Enable', 'on' );
            helpButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'String', '?', ...
                'TooltipString', 'Get help on this panel', 'Enable', 'on' );
            closeButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'String', char( 215 ), ...
                'TooltipString', 'Close this panel', 'Enable', 'on' );
            
            % Store properties
            obj.DecorationBox = decorationBox;
            obj.TitlePanel = titlePanel;
            obj.TitleBox = titleBox;
            obj.TitleText = titleText;
            obj.TitleEmpty = true;
            obj.MainPanel = mainPanel;
            obj.MinimizeButton = minimizeButton;
            obj.DockButton = dockButton;
            obj.HelpButton = helpButton;
            obj.CloseButton = closeButton;
            
            % Draw buttons
            obj.redrawButtons()
            
            % Set properties
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.BorderWidth( obj )
            
            value = obj.TitlePanel.BorderWidth;
            
        end % get.BorderWidth
        
        function set.BorderWidth( obj, value )
            
            % Check
            assert( isnumeric( value ) && isequal( size( value ), [1 1] ) && ...
                value > 0, 'uix:InvalidPropertyValue', ...
                'Property ''BorderWidth'' must be numeric and positive.' )
            
            % Set
            obj.TitlePanel.BorderWidth = value;
            obj.MainPanel.BorderWidth = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.BorderWidth
        
        function value = get.BorderType( obj )
            
            value = obj.TitlePanel.BorderType;
            
        end % get.BorderType
        
        function set.BorderType( obj, value )
            
            % Check
            assert( ischar( value ) && ...
                any( strcmp( value, {'none','line','beveledin','beveledout','etchedin','etchedout'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''BorderType'' must be ''none'', ''line'', ''beveledin'', ''beveledout'', ''etchedin'' or ''etchedout''.' )
            
            % Set
            obj.TitlePanel.BorderType = value;
            obj.MainPanel.BorderType = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.BorderType
        
        function value = get.FontAngle( obj )
            
            value = obj.TitleText.FontAngle;
            
        end % get.FontAngle
        
        function set.FontAngle( obj, value )
            
            obj.TitleText.FontAngle = value;
            
        end % set.FontAngle
        
        function value = get.FontName( obj )
            
            value = obj.TitleText.FontName;
            
        end % get.FontName
        
        function set.FontName( obj, value )
            
            % Set
            obj.TitleText.FontName = value;
            
            % Mark as dirty
            obj.TitleHeight = -1;
            obj.Dirty = true;
            
        end % set.FontName
        
        function value = get.FontSize( obj )
            
            value = obj.TitleText.FontSize;
            
        end % get.FontSize
        
        function set.FontSize( obj, value )
            
            % Set
            obj.TitleText.FontSize = value;
            obj.HelpButton.FontSize = value;
            obj.CloseButton.FontSize = value;
            obj.DockButton.FontSize = value;
            obj.MinimizeButton.FontSize = value;
            
            % Mark as dirty
            obj.TitleHeight = -1;
            obj.Dirty = true;
            
        end % set.FontSize
        
        function value = get.FontUnits( obj )
            
            value = obj.TitleText.FontUnits;
            
        end % get.FontUnits
        
        function set.FontUnits( obj, value )
            
            obj.TitleText.FontUnits = value;
            obj.HelpButton.FontUnits = value;
            obj.CloseButton.FontUnits = value;
            obj.DockButton.FontUnits = value;
            obj.MinimizeButton.FontUnits = value;
            
        end % set.FontUnits
        
        function value = get.FontWeight( obj )
            
            value = obj.TitleText.FontWeight;
            
        end % get.FontWeight
        
        function set.FontWeight( obj, value )
            
            obj.TitleText.FontWeight = value;
            
        end % set.FontWeight
        
        function value = get.ForegroundColor( obj )
            
            value = obj.TitleText.ForegroundColor;
            
        end % get.ForegroundColor
        
        function set.ForegroundColor( obj, value )
            
            % Set
            obj.TitleText.ForegroundColor = value;
            obj.MinimizeButton.ForegroundColor = value;
            obj.DockButton.ForegroundColor = value;
            obj.HelpButton.ForegroundColor = value;
            obj.CloseButton.ForegroundColor = value;
            
            % Mark as dirty
            obj.redrawButtons()
            
        end % set.ForegroundColor
        
        function value = get.HighlightColor( obj )
            
            value = obj.TitlePanel.HighlightColor;
            
        end % get.HighlightColor
        
        function set.HighlightColor( obj, value )
            
            % Check
            assert( isnumeric( value ) && isequal( size( value ), [1 3] ) && ...
                all( isreal( value ) ) && all( value >= 0 ) && all( value <= 1 ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''HighlightColor'' must be an RGB triple.' )
            
            % Set
            obj.TitlePanel.HighlightColor = value;
            obj.MainPanel.HighlightColor = value;
            
        end % set.HighlightColor
        
        function value = get.ShadowColor( obj )
            
            value = obj.TitlePanel.ShadowColor;
            
        end % get.ShadowColor
        
        function set.ShadowColor( obj, value )
            
            % Check
            assert( isnumeric( value ) && isequal( size( value ), [1 3] ) && ...
                all( isreal( value ) ) && all( value >= 0 ) && all( value <= 1 ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''ShadowColor'' must be an RGB triple.' )
            
            % Set
            obj.TitlePanel.ShadowColor = value;
            obj.MainPanel.ShadowColor = value;
            
        end % set.ShadowColor
        
        function value = get.Title( obj )
            
            if obj.TitleEmpty
                value = '';
            else
                value = obj.TitleText.String;
            end
            
        end % get.Title
        
        function set.Title( obj, value )
            
            % Set
            if isempty( value )
                obj.TitleText.String = ' '; % need non-empty string
                obj.TitleEmpty = true; % flag
            else
                obj.TitleText.String = value;
                obj.TitleEmpty = false;
            end
            
            % Mark as dirty
            obj.TitleHeight = -1;
            obj.Dirty = true;
            
        end % set.Title
        
        function value = get.TitleColor( obj )
            
            value = obj.TitleBox.BackgroundColor;
            
        end % get.TitleColor
        
        function set.TitleColor( obj, value )
            
            % Set
            obj.TitleBox.BackgroundColor = value;
            obj.TitleText.BackgroundColor = value;
            obj.MinimizeButton.BackgroundColor = value;
            obj.DockButton.BackgroundColor = value;
            obj.HelpButton.BackgroundColor = value;
            obj.CloseButton.BackgroundColor = value;
            
            % Mark as dirty
            obj.redrawButtons()
            
        end % set.TitleColor
        
        function value = get.CloseRequestFcn( obj )
            
            value = obj.CloseButton.Callback;
            
        end % get.CloseRequestFcn
        
        function set.CloseRequestFcn( obj, value )
            
            % Set
            obj.CloseButton.Callback = value;
            
            % Mark as dirty
            obj.redrawButtons()
            
        end % set.CloseRequestFcn
        
        function value = get.DockFcn( obj )
            
            value = obj.DockButton.Callback;
            
        end % get.DockFcn
        
        function set.DockFcn( obj, value )
            
            % Set
            obj.DockButton.Callback = value;
            
            % Mark as dirty
            obj.redrawButtons()
            
        end % set.DockFcn
        
        function value = get.HelpFcn( obj )
            
            value = obj.HelpButton.Callback;
            
        end % get.HelpFcn
        
        function set.HelpFcn( obj, value )
            
            % Set
            obj.HelpButton.Callback = value;
            
            % Mark as dirty
            obj.redrawButtons()
            
        end % set.HelpFcn
        
        function value = get.MinimizeFcn( obj )
            
            value = obj.MinimizeButton.Callback;
            
        end % get.MinimizeFcn
        
        function set.MinimizeFcn( obj, value )
            
            % Set
            obj.MinimizeButton.Callback = value;
            
            % Mark as dirty
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
            
            % Mark as dirty
            obj.redrawButtons()
            
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
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Minimized
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw
            %
            %  p.redraw() redraws the panel.
            %
            %  See also: redrawButtons
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            w = ceil( bounds(1) + bounds(3) ) - floor( bounds(1) ); % width
            h = ceil( bounds(2) + bounds(4) ) - floor( bounds(2) ); % height
            p = obj.Padding_;
            tH = obj.TitleHeight; % title height
            if tH == -1 % cache stale, refresh
                tH = ceil( obj.TitleText.Extent(4) );
                obj.TitleHeight = tH; % store
            end
            switch obj.TitlePanel.BorderType
                case 'none'
                    b = 0;
                case {'line','beveledin','beveledout'}
                    b = obj.TitlePanel.BorderWidth;
                case {'etchedin','etchedout'}
                    b = obj.TitlePanel.BorderWidth * 2;
            end
            tpH = tH + 2 * b; % title panel height
            cX = 1 + b + p; % contents x
            cY = 1 + b + p; % contents y
            cW = max( w - 2 * b - 2 * p, 1 ); % contents width
            cH = max( h - tH - 4 * b - 2 * p, 1 ); % contents height
            contentsPosition = [cX cY cW cH];
            
            % Redraw decorations
            obj.DecorationBox.Heights(1) = tpH;
            obj.redrawButtons()
            if obj.Minimized_
                obj.MainPanel.Visible = 'off';
            else
                obj.MainPanel.Visible = 'on';
            end
            
            % Redraw contents
            obj.redrawContents( contentsPosition )
            
        end % redraw
        
        function redrawContents( obj, position )
            %redrawContents  Redraw contents
            
            % Call superclass method
            redrawContents@uix.mixin.Panel( obj, position )
            
            % If minimized, hide selected contents too
            if obj.Minimized_ && obj.Selection_ ~= 0
                child = obj.Contents_(obj.Selection_);
                child.Visible = 'off';
                if isa( child, 'matlab.graphics.axis.Axes' )
                    child.ContentsVisible = 'off';
                end
                % As a remedy for g1100294, move off-screen too
                if isa( child, 'matlab.graphics.axis.Axes' ) ...
                        && strcmp(child.ActivePositionProperty, 'outerposition' )
                    child.OuterPosition(1) = -child.OuterPosition(3)-20;
                else
                    child.Position(1) = -child.Position(3)-20;
                end
            end
            
        end % redrawContents
        
    end % template methods
    
    methods( Access = private )
        
        function redrawButtons( obj )
            %redrawButtons  Redraw buttons
            %
            %  p.redrawButtons() redraws the titlebar buttons.
            %
            %  Buttons use unicode arrow symbols:
            %  https://en.wikipedia.org/wiki/Arrow_%28symbol%29#Arrows_in_Unicode
            
            % Retrieve button box and buttons
            box = obj.TitleBox;
            minimizeButton = obj.MinimizeButton;
            dockButton = obj.DockButton;
            helpButton = obj.HelpButton;
            closeButton = obj.CloseButton;
            
            % Detach all buttons
            minimizeButton.Parent = [];
            dockButton.Parent = [];
            helpButton.Parent = [];
            closeButton.Parent = [];
            
            % Attach active buttons
            minimize = ~isempty( obj.MinimizeFcn );
            if minimize
                minimizeButton.Parent = box;
                box.Widths(end) = minimizeButton.Extent(3);
            end
            dock = ~isempty( obj.DockFcn );
            if dock
                dockButton.Parent = box;
                box.Widths(end) = dockButton.Extent(3);
            end
            help = ~isempty( obj.HelpFcn );
            if help
                helpButton.Parent = box;
                box.Widths(end) = helpButton.Extent(3);
            end
            close = ~isempty( obj.CloseRequestFcn );
            if close
                closeButton.Parent = box;
                box.Widths(end) = closeButton.Extent(3);
            end
            
            % Update icons
            if obj.Minimized_
                minimizeButton.String = char( 9662 );
                minimizeButton.TooltipString = 'Expand this panel';
            else
                minimizeButton.String = char( 9652 );
                minimizeButton.TooltipString = 'Collapse this panel';
            end
            if obj.Docked_
                dockButton.String = char( 8599 );
                dockButton.TooltipString = 'Undock this panel';
            else
                dockButton.String = char( 8600 );
                dockButton.TooltipString = 'Dock this panel';
            end
            
        end % redrawButtons
        
    end % helper methods
    
    methods( Access = private, Static )
        
        function mask = getIconMask()
            %getIconMask  Get icon image data
            %
            %  m = uix.BoxPanel.getDividerMask() returns the image masks
            %  for box panel icons.  Mask entries are 0 (background), 1
            %  (foreground).
            
            mask.Close = ~isnan( sum( uix.loadIcon( 'panelClose.png' ), 3 ) );
            mask.Dock = ~isnan( sum( uix.loadIcon( 'panelDock.png' ), 3 ) );
            mask.Undock = ~isnan( sum( uix.loadIcon( 'panelUndock.png' ), 3 ) );
            mask.Help = ~isnan( sum( uix.loadIcon( 'panelHelp.png' ), 3 ) );
            mask.Minimize = ~isnan( sum( uix.loadIcon( 'panelMinimize.png' ), 3 ) );
            mask.Maximize = ~isnan( sum( uix.loadIcon( 'panelMaximize.png' ), 3 ) );
            mask = structfun( @double, mask, 'UniformOutput', false );
            
        end % getIconMask
        
    end % static helper methods
    
end % classdef