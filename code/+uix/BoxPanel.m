classdef BoxPanel < uix.Container
    
    properties( Dependent )
        Title
        BorderWidth
        BorderType
        FontAngle
        FontName
        FontSize
        FontUnits
        FontWeight
        ForegroundColor
        HighlightColor
        ShadowColor
        TitleColor
    end
    
    properties( Access = private )
        Titlebar
        TopBorder
        MiddleBorder
        BottomBorder
        LeftBorder
        RightBorder
        BorderWidth_ = 0
        BorderType_ = 'none'
        HighlightColor_ = [1 1 1]
        ShadowColor_ = [0.7 0.7 0.7]
    end
    
    methods
        
        function obj = BoxPanel( varargin )
            
            % Call superclass constructor
            obj@uix.Container()
            
            % Create title
            titlebar = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'text', 'Units', 'pixels', ...
                'HorizontalAlignment', 'left' );
            
            % Create borders
            topBorder = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'checkbox', 'Units', 'pixels' );
            middleBorder = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'checkbox', 'Units', 'pixels' );
            bottomBorder = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'checkbox', 'Units', 'pixels' );
            leftBorder = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'checkbox', 'Units', 'pixels' );
            rightBorder = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'checkbox', 'Units', 'pixels' );
            
            % Store properties
            obj.Titlebar = titlebar;
            obj.TopBorder = topBorder;
            obj.MiddleBorder = middleBorder;
            obj.BottomBorder = bottomBorder;
            obj.LeftBorder = leftBorder;
            obj.RightBorder = rightBorder;
            
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
            
            % Set as dirty
            obj.Dirty = true;
            
        end % set.BorderWidth
        
        function value = get.BorderType( obj )
            
            value = obj.BorderType_;
            
        end % get.BorderType
        
        function set.BorderType( obj, value )
            
            obj.BorderType_ = value;
            
            % Set as dirty
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
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.HighlightColor
        
        function value = get.ShadowColor( obj )
            
            value = obj.ShadowColor_;
            
        end % get.ShadowColor
        
        function set.ShadowColor( obj, value )
            
            % Set
            obj.ShadowColor_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.ShadowColor
        
        function value = get.Title( obj )
            
            value = obj.Titlebar.String;
            
        end % get.Title
        
        function set.Title( obj, value )
            
            obj.Titlebar.String = value;
            
            % Set as dirty
            obj.Dirty = true;
            
        end % set.Title
        
        function value = get.TitleColor( obj )
            
            value = obj.Titlebar.BackgroundColor;
            
        end % get.TitleColor
        
        function set.TitleColor( obj, value )
            
            obj.Titlebar.BackgroundColor = value;
            
        end % set.TitleColor
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            extent = obj.Titlebar.Extent;
            switch obj.BorderType_
                case 'none'
                    borderSize = 0;
                case {'line','beveledin','beveledout'}
                    borderSize = obj.BorderWidth_;
                case {'etchedin','etchedout'}
                    borderSize = obj.BorderWidth_ * 2;
            end
            padding = obj.Padding_;
            xSizes = uix.calcPixelSizes( bounds(3), -1, ...
                2 * padding + 1, borderSize, borderSize );
            ySizes = uix.calcPixelSizes( bounds(4), [extent(4); -1], ...
                [extent(4); 1 + 2 * padding], borderSize, borderSize );
            titlePosition = [1 + borderSize, 1 + 2 * borderSize + ySizes(2), ...
                xSizes, ySizes(1)];
            contentsPosition = [1 + borderSize + padding, ...
                1 + borderSize + padding, xSizes - 2 * padding, ...
                ySizes(2) - 2 * padding];
            topBorderPosition = [1 + borderSize, 1 + 2 * borderSize + ...
                sum( ySizes ), xSizes, borderSize];
            middleBorderPosition = [1 + borderSize, 1 + borderSize + ...
                ySizes(2), xSizes, borderSize];
            bottomBorderPosition = [1 + borderSize, 1, xSizes, borderSize];
            leftBorderPosition = [1, 1, borderSize, 3 * borderSize + ...
                sum( ySizes )];
            rightBorderPosition = [1 + borderSize + xSizes, 1, ...
                borderSize, 3 * borderSize + sum( ySizes )];
            
            % Set decorations positions
            obj.Titlebar.Position = titlePosition;
            obj.TopBorder.Position = topBorderPosition;
            obj.MiddleBorder.Position = middleBorderPosition;
            obj.BottomBorder.Position = bottomBorderPosition;
            obj.LeftBorder.Position = leftBorderPosition;
            obj.RightBorder.Position = rightBorderPosition;
            obj.redrawBorders()
            
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
        
    end % template methods
    
    methods
        
        function redrawBorders( obj )
            
            % Get colors
            highlightColor = obj.HighlightColor_;
            shadowColor = obj.ShadowColor_;
            
            % Get borders
            topBorder = obj.TopBorder;
            middleBorder = obj.MiddleBorder;
            bottomBorder = obj.BottomBorder;
            leftBorder = obj.LeftBorder;
            rightBorder = obj.RightBorder;
            
            % Compute color data
            switch obj.BorderType_
                case 'none'
                    topBorderCData = zeros( [[topBorder.Position(4), ceil( topBorder.Position(3) )] 3] );
                    middleBorderCData = zeros( [[middleBorder.Position(4), ceil( middleBorder.Position(3) )] 3] );
                    bottomBorderCData = zeros( [[bottomBorder.Position(4), ceil( bottomBorder.Position(3) )] 3] );
                    leftBorderCData = zeros( [[ceil( leftBorder.Position(4) ), leftBorder.Position(3)] 3] );
                    rightBorderCData = zeros( [[ceil( rightBorder.Position(4) ), rightBorder.Position(3)] 3] );
                case 'line'
                    topBorderCData = repmat( permute( highlightColor, [3 1 2] ), [topBorder.Position(4), ceil( topBorder.Position(3) )] );
                    middleBorderCData = repmat( permute( highlightColor, [3 1 2] ), [middleBorder.Position(4), ceil( middleBorder.Position(3) )] );
                    bottomBorderCData = repmat( permute( highlightColor, [3 1 2] ), [bottomBorder.Position(4), ceil( bottomBorder.Position(3) )] );
                    leftBorderCData = repmat( permute( highlightColor, [3 1 2] ), [ceil( leftBorder.Position(4) ), leftBorder.Position(3)] );
                    rightBorderCData = repmat( permute( highlightColor, [3 1 2] ), [ceil( rightBorder.Position(4) ), rightBorder.Position(3)] );
                case 'beveledin'
                    topBorderCData = repmat( permute( shadowColor, [3 1 2] ), [topBorder.Position(4), ceil( topBorder.Position(3) )] );
                    middleBorderCData = repmat( permute( shadowColor, [3 1 2] ), [middleBorder.Position(4), ceil( middleBorder.Position(3) )] );
                    bottomBorderCData = repmat( permute( highlightColor, [3 1 2] ), [bottomBorder.Position(4), ceil( bottomBorder.Position(3) )] );
                    leftBorderCData = repmat( permute( shadowColor, [3 1 2] ), [ceil( leftBorder.Position(4) ), leftBorder.Position(3)] );
                    rightBorderCData = repmat( permute( highlightColor, [3 1 2] ), [ceil( rightBorder.Position(4) ), rightBorder.Position(3)] );
                case 'beveledout'
                    topBorderCData = repmat( permute( highlightColor, [3 1 2] ), [topBorder.Position(4), ceil( topBorder.Position(3) )] );
                    middleBorderCData = repmat( permute( highlightColor, [3 1 2] ), [middleBorder.Position(4), ceil( middleBorder.Position(3) )] );
                    bottomBorderCData = repmat( permute( shadowColor, [3 1 2] ), [bottomBorder.Position(4), ceil( bottomBorder.Position(3) )] );
                    leftBorderCData = repmat( permute( highlightColor, [3 1 2] ), [ceil( leftBorder.Position(4) ), leftBorder.Position(3)] );
                    rightBorderCData = repmat( permute( shadowColor, [3 1 2] ), [ceil( rightBorder.Position(4) ), rightBorder.Position(3)] );
                case 'etchedin'
                    topBorderCData = [ ...
                        repmat( permute( shadowColor, [3 1 2] ), [topBorder.Position(4)/2, ceil( topBorder.Position(3) )] ); ...
                        repmat( permute( highlightColor, [3 1 2] ), [topBorder.Position(4)/2, ceil( topBorder.Position(3) )] )];
                    middleBorderCData = [ ...
                        repmat( permute( shadowColor, [3 1 2] ), [middleBorder.Position(4)/2, ceil( middleBorder.Position(3) )] ); ...
                        repmat( permute( highlightColor, [3 1 2] ), [middleBorder.Position(4)/2, ceil( middleBorder.Position(3) )] )];
                    bottomBorderCData = [ ...
                        repmat( permute( shadowColor, [3 1 2] ), [bottomBorder.Position(4)/2, ceil( bottomBorder.Position(3) )] ); ...
                        repmat( permute( highlightColor, [3 1 2] ), [bottomBorder.Position(4)/2, ceil( bottomBorder.Position(3) )] )];
                    leftBorderCData = [ ...
                        repmat( permute( shadowColor, [3 1 2] ), [ceil( leftBorder.Position(4) ), leftBorder.Position(3)/2] ), ...
                        repmat( permute( highlightColor, [3 1 2] ), [ceil( leftBorder.Position(4) ), leftBorder.Position(3)/2] )];
                    rightBorderCData = [ ...
                        repmat( permute( shadowColor, [3 1 2] ), [ceil( rightBorder.Position(4) ), rightBorder.Position(3)/2] ), ...
                        repmat( permute( highlightColor, [3 1 2] ), [ceil( rightBorder.Position(4) ), rightBorder.Position(3)/2] )];
                case 'etchedout'
                    topBorderCData = [ ...
                        repmat( permute( highlightColor, [3 1 2] ), [topBorder.Position(4)/2, ceil( topBorder.Position(3) )] ); ...
                        repmat( permute( shadowColor, [3 1 2] ), [topBorder.Position(4)/2, ceil( topBorder.Position(3) )] )];
                    middleBorderCData = [ ...
                        repmat( permute( highlightColor, [3 1 2] ), [middleBorder.Position(4)/2, ceil( middleBorder.Position(3) )] ); ...
                        repmat( permute( shadowColor, [3 1 2] ), [middleBorder.Position(4)/2, ceil( middleBorder.Position(3) )] )];
                    bottomBorderCData = [ ...
                        repmat( permute( highlightColor, [3 1 2] ), [bottomBorder.Position(4)/2, ceil( bottomBorder.Position(3) )] ); ...
                        repmat( permute( shadowColor, [3 1 2] ), [bottomBorder.Position(4)/2, ceil( bottomBorder.Position(3) )] )];
                    leftBorderCData = [ ...
                        repmat( permute( highlightColor, [3 1 2] ), [ceil( leftBorder.Position(4) ), leftBorder.Position(3)/2] ), ...
                        repmat( permute( shadowColor, [3 1 2] ), [ceil( leftBorder.Position(4) ), leftBorder.Position(3)/2] )];
                    rightBorderCData = [ ...
                        repmat( permute( highlightColor, [3 1 2] ), [ceil( rightBorder.Position(4) ), rightBorder.Position(3)/2] ), ...
                        repmat( permute( shadowColor, [3 1 2] ), [ceil( rightBorder.Position(4) ), rightBorder.Position(3)/2] )];
            end
            
            % Paint borders
            topBorder.CData = topBorderCData;
            middleBorder.CData = middleBorderCData;
            bottomBorder.CData = bottomBorderCData;
            leftBorder.CData = leftBorderCData;
            rightBorder.CData = rightBorderCData;
            
        end % redrawBorders
        
    end % helper methods
    
end % classdef