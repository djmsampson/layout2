classdef Image < hgsetget
    
    properties
        Label
        Container
    end
    
    properties( Dependent )
        Parent
        Units
        Position
        HorizontalAlignment
        VerticalAlignment
        CData
    end
    
    properties( Dependent, Hidden )
        JData
    end
    
    methods
        
        function obj = Image( varargin )
            
            label = javax.swing.JLabel();
            container = hgjavacomponent( 'Parent', [], 'JavaPeer', label, 'DeleteFcn', @obj.onDelete );
            
            obj.Label = label;
            obj.Container = container;
            
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Parent( obj )
            
            value = obj.Container.Parent;
            
        end
        
        function set.Parent( obj, value )
            
            obj.Container.Parent = value;
            
        end
        
        function value = get.Units( obj )
            
            value = obj.Container.Units;
            
        end
        
        function set.Units( obj, value )
            
            obj.Container.Units = value;
            
        end
        
        function value = get.Position( obj )
            
            value = obj.Container.Position;
            
        end
        
        function set.Position( obj, value )
            
            obj.Container.Position = value;
            
        end
        
        function value = get.HorizontalAlignment( obj )
            
            switch obj.Label.getHorizontalAlignment()
                case javax.swing.SwingConstants.LEADING % JLabel default
                    value = 'left';
                case javax.swing.SwingConstants.LEFT
                    value = 'left';
                case javax.swing.SwingConstants.CENTER
                    value = 'center';
                case javax.swing.SwingConstants.RIGHT
                    value = 'right';
            end
            
        end
        
        function set.HorizontalAlignment( obj, value )
            
            % Check
            assert( ischar( value ) && any( strcmp( value, {'left','center','right'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''HorizontalAlignment'' must be ''left'', ''center'' or ''right''.' )
            
            % Set
            switch value
                case 'left'
                    alignment = javax.swing.SwingConstants.LEFT;
                case 'center'
                    alignment = javax.swing.SwingConstants.CENTER;
                case 'right'
                    alignment = javax.swing.SwingConstants.RIGHT;
            end
            obj.Label.setHorizontalAlignment( alignment )
            
        end
        
        function value = get.VerticalAlignment( obj )
            
            switch obj.Label.getVerticalAlignment()
                case javax.swing.SwingConstants.TOP
                    value = 'top';
                case javax.swing.SwingConstants.CENTER
                    value = 'middle';
                case javax.swing.SwingConstants.BOTTOM
                    value = 'bottom';
            end
            
        end
        
        function set.VerticalAlignment( obj, value )
            
            % Check
            assert( ischar( value ) && any( strcmp( value, {'left','center','right'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''VerticalAlignment'' must be ''top'', ''middle'' or ''bottom''.' )
            
            % Set
            switch value
                case 'top'
                    alignment = javax.swing.SwingConstants.TOP;
                case 'middle'
                    alignment = javax.swing.SwingConstants.CENTER;
                case 'bottom'
                    alignment = javax.swing.SwingConstants.BOTTOM;
            end
            obj.Label.setVerticalAlignment( alignment )
            
        end
        
        function value = get.CData( obj )
            
            mI = obj.JData;
            sz = size( mI );
            vI = reshape( mI, [sz(1)*sz(2) 1] );
            vC = uix.Image.int2rgb( vI );
            value = reshape( vC, [size( mI ) 3] );
            
        end
        
        function set.CData( obj, value )
            
            % Check
            
            
            % Set
            if isempty( value )
                obj.Label.setIcon( [] )
            else
                sz = size( value );
                vC = transpose( reshape( permute( value, [3 2 1] ), ...
                    [sz(3) sz(1)*sz(2)] ) );
                vI = uix.Image.rgb2int( vC );
                bufferedImage = java.awt.image.BufferedImage( sz(2), ...
                    sz(1), java.awt.image.BufferedImage.TYPE_INT_ARGB );
                bufferedImage.setRGB( 0, 0, sz(2), sz(1), vI, 0, sz(2) )
                imageIcon = javax.swing.ImageIcon( bufferedImage );
                obj.Label.setIcon( imageIcon )
            end
        end
        
        function value = get.JData( obj )
            
            imageIcon = obj.Label.getIcon();
            if isequal( imageIcon, [] )
                value = zeros( [0 0], 'int32' );
            else
                bufferedImage = imageIcon.getImage();
                width = bufferedImage.getWidth();
                height = bufferedImage.getHeight();
                vI = bufferedImage.getRGB( 0, 0, width, height, ...
                    zeros( [width*height 1], 'int32' ), 0, width );
                value = transpose( reshape( vI, [width height] ) );
            end
            
        end
        
        function set.JData( obj, value )
            
            if isempty( value )
                obj.Label.setIcon( [] )
            else
                sz = size( value );
                vI = reshape( transpose( value ), [sz(1)*sz(2) 1] );
                bufferedImage = java.awt.image.BufferedImage( sz(2), ...
                    sz(1), java.awt.image.BufferedImage.TYPE_INT_ARGB );
                bufferedImage.setRGB( 0, 0, sz(2), sz(1), vI, 0, sz(2) )
                imageIcon = javax.swing.ImageIcon( bufferedImage );
                obj.Label.setIcon( imageIcon )
            end
            
        end
        
    end % accessors
    
    methods
        
        function onDelete( obj, ~, ~ )
            
            obj.delete()
            
        end % onDelete
        
    end % event handlers
    
    methods( Static )
        
        function int = rgb2int( rgb )
            
            int = bitshift( int32( 255 ), 24 ) + ...
                bitshift( int32( 255*rgb(:,1) ), 16 ) + ...
                bitshift( int32( 255*rgb(:,2) ), 8 ) + ...
                bitshift( int32( 255*rgb(:,3) ), 0 );
            
        end
        
        function rgb = int2rgb( int )
            
            int = int - bitshift( int32( 255 ), 24 );
            r = bitshift( int, -16 );
            g = bitshift( int - bitshift( r, 16 ), -8 );
            b = int - bitshift( r, 16 ) - bitshift( g, 8 );
            rgb = double( [r g b] ) / 255;
            
        end
        
    end % static methods
    
end % classdef