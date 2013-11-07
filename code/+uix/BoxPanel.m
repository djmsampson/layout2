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
            
            % Create borders and title right-to-left, bottom-to-top
            rightBorder = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'checkbox', 'Units', 'pixels' );
            bottomBorder = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'checkbox', 'Units', 'pixels' );
            middleBorder = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'checkbox', 'Units', 'pixels' );
            titlebar = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'text', 'Units', 'pixels', ...
                'HorizontalAlignment', 'left' );
            topBorder = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'checkbox', 'Units', 'pixels' );
            leftBorder = matlab.ui.control.StyleControl( 'Internal', true, ...
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
            xSizes = max( [round( bounds(3) ) - 2 * borderSize, ...
                1 + 2 * padding] );
            ySizes = [titleHeight; max( [round( bounds(4) ) - ...
                3 * borderSize - titleHeight, 1 + 2 * padding] )];
            titlePosition = [1 + borderSize, 1 + 2 * borderSize + ySizes(2), ...
                xSizes, ySizes(1)];
            contentsPosition = [1 + borderSize + padding, ...
                1 + borderSize + padding, xSizes - 2 * padding, ...
                ySizes(2) - 2 * padding];
            topBorderPosition = [1 + borderSize, 1 + 2 * borderSize + ...
                sum( ySizes ), xSizes, borderSize] + [-1 0 1 0];
            middleBorderPosition = [1 + borderSize, 1 + borderSize + ...
                ySizes(2), xSizes, borderSize] + [-1 0 1 0];
            bottomBorderPosition = [1 + borderSize, 1, xSizes, borderSize] + ...
                [-1 0 1 0];
            leftBorderPosition = [1, 1, borderSize, 3 * borderSize + ...
                sum( ySizes )] + [-1 0 1 0];
            rightBorderPosition = [1 + borderSize + xSizes, 1, ...
                borderSize, 3 * borderSize + sum( ySizes )] + [-1 0 1 0];
            
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
                case 'none'
                    topMask = true( [topPosition(4)+1, topPosition(3)-1] );
                    middleMask = true( [middlePosition(4)+1, middlePosition(3)-1] );
                    bottomMask = true( [bottomPosition(4)+1, bottomPosition(3)-1] );
                    leftMask = true( [round( leftPosition(4)+1 ), leftPosition(3)-1] );
                    rightMask = true( [round( rightPosition(4)+1 ), rightPosition(3)-1] );
                case 'line'
                    topMask = true( [topPosition(4)+1, topPosition(3)-1] );
                    middleMask = true( [middlePosition(4)+1, middlePosition(3)-1] );
                    bottomMask = true( [bottomPosition(4)+1, bottomPosition(3)-1] );
                    leftMask = true( [leftPosition(4)+1, leftPosition(3)-1] );
                    rightMask = true( [rightPosition(4)+1, rightPosition(3)-1] );
                case 'beveledin'
                    topMask = false( [topPosition(4)+1, topPosition(3)-1] );
                    middleMask = false( [middlePosition(4)+1, middlePosition(3)-1] );
                    bottomMask = true( [bottomPosition(4)+1, bottomPosition(3)-1] );
                    leftMask = false( [leftPosition(4)+1, leftPosition(3)-1] );
                    rightMask = true( [rightPosition(4)+1, rightPosition(3)-1] );
                    
%                     leftMask(end-(leftPosition(3)-1)+1:end,:) = ...
%                         fliplr( tril( ones( leftPosition(3)-1 ) ) == 0 );
                    
                case 'beveledout'
                    topMask = true( [topPosition(4)+1, topPosition(3)-1] );
                    middleMask = true( [middlePosition(4)+1, middlePosition(3)-1] );
                    bottomMask = false( [bottomPosition(4)+1, bottomPosition(3)-1] );
                    leftMask = true( [round( leftPosition(4)+1 ), leftPosition(3)-1] );
                    rightMask = false( [round( rightPosition(4)+1 ), rightPosition(3)-1] );
                case 'etchedin'
                    topMask = [false( [topPosition(4)/2, topPosition(3)-1] ); ...
                        true( [topPosition(4)/2+1, topPosition(3)-1] )];
                    middleMask = [false( [middlePosition(4)/2, middlePosition(3)-1] ); ...
                        true( [middlePosition(4)/2+1, middlePosition(3)-1] )];
                    bottomMask = [false( [bottomPosition(4)/2, bottomPosition(3)-1] ); ...
                        true( [bottomPosition(4)/2+1, bottomPosition(3)-1] )];
                    leftMask = [false( [leftPosition(4)+1, (leftPosition(3)-1)/2] ), ...
                        true( [leftPosition(4)+1, (leftPosition(3)-1)/2] )];
                    rightMask = [false( [rightPosition(4)+1, (rightPosition(3)-1)/2] ), ...
                        true( [rightPosition(4)+1, (rightPosition(3)-1)/2] )];
                    
%                     leftMask(1:(leftPosition(3)-1)/2,:,:) = ...
%                         false( [(leftPosition(3)-1)/2, leftPosition(3)-1] );
%                     rightMask(end-(rightPosition(3)-1)/2+1:end,:,:) = ...
%                         true( [(rightPosition(3)-1)/2, rightPosition(3)-1] );
                    
                case 'etchedout'
                    topMask = [true( [topPosition(4)/2, topPosition(3)-1] ); ...
                        false( [topPosition(4)/2+1, topPosition(3)-1] )];
                    middleMask = [true( [middlePosition(4)/2, middlePosition(3)-1] ); ...
                        false( [middlePosition(4)/2+1, middlePosition(3)-1] )];
                    bottomMask = [true( [bottomPosition(4)/2, bottomPosition(3)-1] ); ...
                        false( [bottomPosition(4)/2+1, bottomPosition(3)-1] )];
                    leftMask = [true( [leftPosition(4)+1, (leftPosition(3)-1)/2] ), ...
                        false( [leftPosition(4)+1, (leftPosition(3)-1)/2] )];
                    rightMask = [true( [rightPosition(4)+1, (rightPosition(3)-1)/2] ), ...
                        false( [rightPosition(4)+1, (rightPosition(3)-1)/2] )];
                    
%                     leftMask(1:(leftPosition(3)-1)/2,:,:) = ...
%                         true( [(leftPosition(3)-1)/2, leftPosition(3)-1] );
%                     rightMask(end-(rightPosition(3)-1)/2+1:end,:,:) = ...
%                         false( [(rightPosition(3)-1)/2, rightPosition(3)-1] );
                    
            end
            
            % Convert masks to color data
            highlightColor = obj.HighlightColor_;
            shadowColor = obj.ShadowColor_;
            topCData = mask2cdata( topMask, highlightColor, shadowColor );
            middleCData = mask2cdata( middleMask, highlightColor, shadowColor );
            bottomCData = mask2cdata( bottomMask, highlightColor, shadowColor );
            leftCData = mask2cdata( leftMask, highlightColor, shadowColor );
            rightCData = mask2cdata( rightMask, highlightColor, shadowColor );
            
            % Paint borders
            topBorder.CData = topCData;
            middleBorder.CData = middleCData;
            bottomBorder.CData = bottomCData;
            leftBorder.CData = leftCData;
            rightBorder.CData = rightCData;
            
            function c = mask2cdata( m, h, s )
                
                hh = repmat( permute( h, [3 1 2] ), size( m ) );
                ss = repmat( permute( s, [3 1 2] ), size( m ) );
                mm = repmat( m, [1 1 3] );
                c = ss;
                c(mm) = hh(mm);
                
            end % foobar
            
        end % redrawBorders
        
    end % helper methods
    
end % classdef