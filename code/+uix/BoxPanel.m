classdef BoxPanel < uix.Container
    
    properties( Dependent )
        Title
        BorderWidth
        BorderType
    end
    
    properties( Access = private )
        Titlebar
        BorderWidth_ = 0
        BorderType_ = 'none'
    end
    
    methods
        
        function obj = BoxPanel( varargin )
            
            % Call superclass constructor
            obj@uix.Container()
            
            % Create title
            titlebar = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'text', 'Units', 'pixels' );
            titlebar.BackgroundColor = [0 0 1];
            
            % Store properties
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
        
        function value = get.Title( obj )
            
            value = obj.Titlebar.String;
            
        end % get.Title
        
        function set.Title( obj, value )
            
            obj.Titlebar.String = value;
            
            % Set as dirty
            obj.Dirty = true;
            
        end % set.Title
        
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
                case 'line'
                    borderSize = obj.BorderWidth_;
                otherwise
                    borderSize = obj.BorderWidth_ * 2;
            end
            padding = obj.Padding_;
            xSizes = uix.calcPixelSizes( bounds(3), -1, ...
                2 * padding + 1, borderSize, borderSize );
            ySizes = uix.calcPixelSizes( bounds(4), [extent(4); -1], ...
                [extent(4); 1 + 2 * padding], borderSize, borderSize );
            titlePosition = [borderSize, 2 * borderSize + ySizes(2), ...
                xSizes, ySizes(1)];
            contentsPosition = [borderSize + padding, ...
                borderSize + padding, xSizes - 2 * padding, ...
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