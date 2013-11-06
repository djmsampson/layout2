classdef BoxPanel < uix.Container
    
    properties( Dependent )
        Title
        BorderWidth
        BorderType
        FontAngle
        FontName
        FontSize
        FontWeight
        FontUnits
        ForegroundColor
        HighlightColor
        ShadowColor
    end
    
    properties % ( Access = private )
        JTitlebar
        Titlebar
        BorderWidth_ = 0
        BorderType_ = 'none'
        HilightColor_ = [1 1 1]
        ShadowColor_ = [0.7 0.7 0.7]
    end
    
    methods
        
        function obj = BoxPanel( varargin )
            
            % Call superclass constructor
            obj@uix.Container()
            
            % Create title
            jTitlebar = javax.swing.JLabel();
            titlebar = hgjavacomponent( 'Internal', true, ...
                'Parent', obj, 'JavaPeer', jTitlebar );
            titlebar.Units = 'pixels';
            
            % Store properties
            obj.JTitlebar = jTitlebar;
            obj.Titlebar = titlebar;
            
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
        
        function value = get.FontAngle( obj ) % TODO
            
            value = obj.Titlebar.FontAngle;
            
        end % get.FontAngle
        
        function set.FontAngle( obj, value ) % TODO
            
            obj.Titlebar.FontAngle = value;
            
            % Set as dirty
            obj.Dirty = true;
            
        end % set.FontAngle
        
        function value = get.FontName( obj )
            
            value = obj.JTitlebar.getFont().getFontName();
            
        end % get.FontName
        
        function set.FontName( obj, value ) % TODO
            
            obj.Titlebar.FontName = value;
            
            % Set as dirty
            obj.Dirty = true;
            
        end % set.FontName
        
        function value = get.FontSize( obj ) % TODO
            
            value = obj.JTitlebar.getFont().getSize2D();
            
        end % get.FontSize
        
        function set.FontSize( obj, value ) % TODO
            
            obj.Titlebar.FontSize = value;
            
            % Set as dirty
            obj.Dirty = true;
            
        end % set.FontSize
        
        function value = get.FontUnits( obj ) % TODO
            
            value = obj.Titlebar.FontUnits;
            
        end % get.FontUnits
        
        function set.FontUnits( obj, value ) % TODO
            
            obj.Titlebar.FontUnits = value;
            
            % Set as dirty
            obj.Dirty = true;
            
        end % set.FontUnits
        
        function value = get.FontWeight( obj ) % TODO
            
            value = obj.Titlebar.FontWeight;
            
        end % get.FontWeight
        
        function set.FontWeight( obj, value ) % TODO
            
            obj.Titlebar.FontWeight = value;
            
            % Set as dirty
            obj.Dirty = true;
            
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
            
            obj.HighlightColor_ = value;
            
        end % set.HighlightColor
        
        function value = get.ShadowColor( obj )
            
            value = obj.ShadowColor_;
            
        end % get.ShadowColor
        
        function set.ShadowColor( obj, value )
            
            obj.ShadowColor_ = value;
            
        end % set.ShadowColor
        
        function value = get.Title( obj )
            
            value = char( obj.JTitlebar.getText() );
            
        end % get.Title
        
        function set.Title( obj, value )
            
            obj.JTitlebar.setText( value )
            
            % Set as dirty
            obj.Dirty = true;
            
        end % set.Title
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            
            % Compute positions
            figure = ancestor( obj, 'figure' );
            bounds = hgconvertunits( figure, [0 0 1 1], 'normalized', ...
                'pixels', obj );
            fontHeight = 20;
            switch obj.BorderType_
                case 'none'
                    borderSize = 0;
                case 'line'
                    borderSize = obj.BorderWidth_;
                otherwise
                    borderSize = obj.BorderWidth_ * 2;
            end
            padding = obj.Padding_;
            xSizes = uix.calcPixelSizes( bounds(3), -1, ...
                2 * padding + 1, borderSize, borderSize );
            ySizes = uix.calcPixelSizes( bounds(4), [fontHeight; -1], ...
                [fontHeight; 1 + 2 * padding], borderSize, borderSize );
            titlePosition = [1 + borderSize, 1 + 2 * borderSize + ySizes(2), ...
                xSizes, ySizes(1)];
            contentsPosition = [1 + borderSize + padding, ...
                1 + borderSize + padding, xSizes - 2 * padding, ...
                ySizes(2) - 2 * padding];
            
            % Set decorations positions
            obj.Titlebar.Position = titlePosition;
            
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
    
end % classdef