classdef Viewport < uix.Container & uix.mixin.Panel
    %uix.Viewport  Scrolling panel
    %
    %  b = uix.Viewport(p1,v1,p2,v2,...) constructs a scrolling panel and
    %  sets parameter p1 to value v1, etc.
    %
    %  A scrolling panel is a standard container (uicontainer) that shows
    %  one its contents and hides the others.
    %
    %  See also: uix.Panel, uix.BoxPanel, uix.TabPanel, uicontainer
    
    %  Copyright 2009-2016 The MathWorks, Inc.
    %  $Revision: 1165 $ $Date: 2015-12-06 03:09:17 -0500 (Sun, 06 Dec 2015) $
    
    properties( Dependent )
        Heights % heights of contents, in pixels and/or weights
        VerticalOffset
        VerticalStep
        Widths % widths of contents, in pixels and/or weights
        HorizontalOffset
        HorizontalStep
    end
    
    properties( Access = protected )
        Heights_ = zeros( [0 1] ) % backing for Heights
        Widths_ = zeros( [0 1] ) % backing for Widths
        HorizontalSlider % slider
        VerticalSlider % slider
    end
    
    properties( Constant, Access = protected )
        SliderSize = 20 % slider size, in pixels
    end
    
    methods
        
        function obj = Viewport( varargin )
            %uix.Viewport  Scrolling panel constructor
            %
            %  p = uix.Viewport() constructs a scrolling panel.
            %
            %  p = uix.Viewport(p1,v1,p2,v2,...) sets parameter p1 to
            %  value v1, etc.
            
            % Create sliders
            horizontalSlider = uicontrol( 'Internal', true, 'Parent', obj, ...
                'Style', 'slider', 'Callback', @obj.onSliderClicked );
            verticalSlider = uicontrol( 'Internal', true, 'Parent', obj, ...
                'Style', 'slider', 'Callback', @obj.onSliderClicked );
            
            % Store properties
            obj.HorizontalSlider = horizontalSlider;
            obj.VerticalSlider = verticalSlider;
            
            % Set properties
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Heights( obj )
            
            value = obj.Heights_;
            
        end % get.Heights
        
        function set.Heights( obj, value )
            
            % For those who can't tell a column from a row...
            if isrow( value )
                value = transpose( value );
            end
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Heights'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Heights'' must be real and finite.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''Heights'' must match size of contents.' )
            
            % Set
            obj.Heights_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Heights
        
        function value = get.VerticalOffset( obj )
            
            value = obj.VerticalSlider.Value;
            
        end % get.VerticalOffset
        
        function set.VerticalOffset( obj, value )
            
            % Check
            % TODO
            
            % Set
            obj.VerticalSlider.Value = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.VerticalOffset
        
        function value = get.VerticalStep( obj )
            
            value = obj.VerticalSlider.SliderStep(2);
            
        end % get.VerticalStep
        
        function set.VerticalStep( obj, value )
            
            % Check
            % TODO
            
            % Set
            obj.VerticalSlider.SliderStep(2) = value;
            
        end % set.VerticalStep
        
        function value = get.Widths( obj )
            
            value = obj.Widths_;
            
        end % get.Widths
        
        function set.Widths( obj, value )
            
            % For those who can't tell a column from a row...
            if isrow( value )
                value = transpose( value );
            end
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Widths'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Widths'' must be real and finite.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''Widths'' must match size of contents.' )
            
            % Set
            obj.Widths_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Widths
        
        function value = get.HorizontalOffset( obj )
            
            value = obj.HorizontalSlider.Value;
            
        end % get.HorizontalOffset
        
        function set.HorizontalOffset( obj, value )
            
            % Check
            % TODO
            
            % Set
            obj.HorizontalSlider.Value = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.HorizontalOffset
        
        function value = get.HorizontalStep( obj )
            
            value = obj.HorizontalSlider.SliderStep(2);
            
        end % get.HorizontalStep
        
        function set.HorizontalStep( obj, value )
            
            % Check
            % TODO
            
            % Set
            obj.HorizontalSlider.SliderStep(2) = value;
            
        end % set.HorizontalStep
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            w = bounds(3);
            h = bounds(4);
            p = obj.Padding_;
            sS = obj.SliderSize; % slider size
            i = obj.Selection_;
            if i == 0, return, end
            cmW = obj.Widths_(i);
            cmH = obj.Heights_(i);
            vpW = sS * (cmH > h);
            hpH = sS * (cmW > w);
            vpH = h - 2*p - hpH;
            hpW = w - 2*p - vpW;
            pW = uix.calcPixelSizes( w, [cmW;vpW], [1;vpW], p, 0 );
            pH = uix.calcPixelSizes( h, [cmH;hpH], [1;hpH], p, 0 );
            cpW = pW(1);
            cpH = pH(1);
            contentsPosition = [p+1 h-p-cpH+1 cpW cpH];
            verticalSliderPosition = [w-p-vpW+1 h-p-vpH+1 vpW vpH];
            horizontalSliderPosition = [p+1 p+1 hpW hpH];
            
            % Redraw contents
            obj.redrawContents( contentsPosition )
            
            % Redraw sliders
            vs = obj.VerticalSlider;
            if vpW > 0
                vs.Visible = 'on';
                uistack( vs, 'top' )
                vs.Position = verticalSliderPosition;
            else
                vs.Visible = 'off';
            end
            hs = obj.HorizontalSlider;
            if hpH > 0
                hs.Visible = 'on';
                uistack( hs, 'top' )
                hs.Position = horizontalSliderPosition;
            else
                hs.Visible = 'off';
            end
            
        end % redraw
        
        function addChild( obj, child )
            %addChild  Add child
            %
            %  c.addChild(d) adds the child d to the container c.
            
            % Add to sizes
            obj.Widths_(end+1,:) = -1;
            obj.Heights_(end+1,:) = -1;
            
            % Call superclass method
            addChild@uix.mixin.Panel( obj, child )
            
        end % addChild
        
        function removeChild( obj, child )
            %removeChild  Remove child
            %
            %  c.removeChild(d) removes the child d from the container c.
            
            % Remove from sizes
            tf = obj.Contents_ == child;
            obj.Widths_(tf,:) = [];
            obj.Heights_(tf,:) = [];
            
            % Call superclass method
            removeChild@uix.mixin.Panel( obj, child )
            
        end % removeChild
        
        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).
            
            % Reorder
            obj.Widths_ = obj.Widths_(indices,:);
            obj.Heights_ = obj.Heights_(indices,:);
            
            % Call superclass method
            reorder@uix.mixin.Panel( obj, indices )
            
        end % reorder
        
    end % template methods
    
    methods( Access = private )
        
        function onSliderClicked( obj, ~, ~ )
            %onSliderClicked  Event handler
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onSliderClicked
        
    end % event handlers
    
end % classdef