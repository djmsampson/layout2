classdef BoxPanel < uix.Box
    
    properties( Access = public, Dependent, AbortSet )
        Title
    end
    
    properties( Access = private )
        TitleText
        TitlePanel
        ContentsPanel
        HelpButton
        CloseButton
        DockButton
        MinimizeButton
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
            helpButton = uicontrol( 'Parent', obj, ...
                'Style', 'checkbox', ...
                'CData', uiextras.loadLayoutIcon( 'panelHelp.png' ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Internal', true, ...
                'TooltipString', 'Get help on this panel' );
            closeButton = uicontrol('parent', obj, ...
                'Style', 'checkbox', ...
                'CData', uiextras.loadLayoutIcon( 'panelClose.png' ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Internal', true, ...
                'TooltipString', 'Close this panel' );
            dockButton = uicontrol( 'Parent', obj, ...
                'Style', 'checkbox', ...
                'CData', uiextras.loadLayoutIcon( 'panelUndock.png' ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Internal', true, ...
                'TooltipString', 'Undock this panel' );
            minimizeButton = uicontrol( 'Parent', obj, ...
                'Style', 'checkbox', ...
                'CData', uiextras.loadLayoutIcon( 'panelMinimize.png' ), ...
                'BackgroundColor', titleColor, ...
                'Visible', 'off', ...
                'Internal', true, ...
                'TooltipString', 'Minimize this panel' );
            
            % Store properties
            obj.TitlePanel = titlePanel;
            obj.TitleText = titleText;
            obj.ContentsPanel = contentsPanel;
            obj.HelpButton = helpButton;
            obj.CloseButton = closeButton;
            obj.DockButton = dockButton;
            obj.MinimizeButton = minimizeButton;
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Title( obj )
            
            value = obj.TitleText.String;
            
        end % get.Title
        
        function set.Title( obj, value )
            
            obj.TitleText.String = value;
            
        end % set.Title
        
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
            
            % Set positions of decorations
            obj.TitleText.Position = textPosition;
            obj.TitlePanel.Position = panelPosition;
            
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