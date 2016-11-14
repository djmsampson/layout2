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
        VerticalOffsets % vertical offsets of contents, in pixels
        VerticalSteps % vertical slider steps, in pixels
        Widths % widths of contents, in pixels and/or weights
        HorizontalOffsets % horizontal offsets of contents, in pixels
        HorizontalSteps % horizontal slider steps, in pixels
    end
    
    properties( Access = protected )
        Heights_ = zeros( [0 1] ) % backing for Heights
        Widths_ = zeros( [0 1] ) % backing for Widths
        HorizontalSliders = matlab.ui.control.UIControl.empty( [0 1] ) % sliders
        VerticalSliders = matlab.ui.control.UIControl.empty( [0 1] ) % sliders
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
        
        function value = get.VerticalOffsets( obj )
            
            sliders = obj.VerticalSliders;
            if isempty( sliders )
                value = zeros( size( sliders ) );
            else
                value = vertcat( sliders.Value );
            end
            
        end % get.VerticalOffsets
        
        function set.VerticalOffsets( obj, value )
            
            % Check
            % TODO
            
            % Set
            % TODO
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.VerticalOffsets
        
        function value = get.VerticalSteps( obj )
            
            sliders = obj.VerticalSliders;
            if isempty( sliders )
                value = zeros( size( sliders ) );
            else
                value = vertcat( sliders.SliderStep(2) );
            end
            
        end % get.VerticalSteps
        
        function set.VerticalSteps( obj, value )
            
            % Check
            % TODO
            
            % Set
            % TODO
            
        end % set.VerticalSteps
        
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
        
        function value = get.HorizontalOffsets( obj )
            
            sliders = obj.HorizontalSliders;
            if isempty( sliders )
                value = zeros( size( sliders ) );
            else
                value = vertcat( sliders.Value );
            end
            
        end % get.HorizontalOffsets
        
        function set.HorizontalOffsets( obj, value )
            
            % Check
            % TODO
            
            % Set
            % TODO
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.HorizontalOffsets
        
        function value = get.HorizontalSteps( obj )
            
            sliders = obj.HorizontalSliders;
            if isempty( sliders )
                value = zeros( size( sliders ) );
            else
                value = vertcat( sliders.SliderStep(2) );
            end
            
        end % get.HorizontalSteps
        
        function set.HorizontalSteps( obj, value )
            
            % Check
            % TODO
            
            % Set
            obj.HorizontalSlider.SliderStep(2) = value;
            
        end % set.HorizontalSteps
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw
            
            % Return if no contents
            selection = obj.Selection_;
            if selection == 0, return, end
            
            % Retrieve width and height of selected contents
            contentsWidth = obj.Widths_(selection);
            contentsHeight = obj.Heights_(selection);
            
            % Retrieve selected contents and corresponding decorations
            child = obj.Contents_(selection);
            vSlider = obj.VerticalSliders(selection);
            hSlider = obj.HorizontalSliders(selection);
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            width = bounds(3);
            height = bounds(4);
            padding = obj.Padding_;
            sliderSize = obj.SliderSize; % slider size
            vSliderWidth = sliderSize * (contentsHeight > height); % first pass
            hSliderHeight = sliderSize * (contentsWidth > width - vSliderWidth);
            vSliderWidth = sliderSize * (contentsHeight > height - hSliderHeight); % second pass
            vSliderHeight = height - 2 * padding - hSliderHeight;
            hSliderWidth = width - 2 * padding - vSliderWidth;
            widths = uix.calcPixelSizes( width, [contentsWidth; vSliderWidth], [1; 1], padding, 0 );
            heights = uix.calcPixelSizes( height, [contentsHeight; hSliderHeight], [1; 1], padding, 0 );
            contentsWidth = widths(1);
            contentsHeight = heights(1);
            contentsPosition = [padding+1 height-padding-contentsHeight+1 contentsWidth contentsHeight];
            vSliderPosition = [width-padding-vSliderWidth+1 height-padding-vSliderHeight+1 vSliderWidth vSliderHeight];
            hSliderPosition = [padding+1 padding+1 hSliderWidth hSliderHeight];
            
            % Compute slider properties
            if vSliderWidth == 0
                vSliderMin = -1;
                vSliderMax = 0;
                vSliderValue = -1;
                vSliderStep = [1 1];
            else
                viewportHeight = height - 2 * padding - hSliderHeight;
                vSliderMin = 1;
                vSliderMax = contentsHeight - viewportHeight + 1;
                vSliderRange = vSliderMax - vSliderMin;
                oldVSliderValue = vSlider.Value;
                if oldVSliderValue < 0
                    vSliderValue = contentsHeight - viewportHeight + 1;
                else
                    vSliderValue = contentsHeight - viewportHeight - ...
                        vSlider.Max + oldVSliderValue + 1;
                    if vSliderValue > vSliderMax
                        vSliderValue = vSliderMax;
                    elseif vSliderValue < vSliderMin
                        vSliderValue = vSliderMin;
                    end
                end
                vSliderStep(1) = min( 10 / vSliderRange, 1 );
                vSliderStep(2) = viewportHeight / vSliderRange;
            end
            if hSliderHeight == 0
                hSliderMin = -1;
                hSliderMax = 0;
                hSliderValue = -1;
                hSliderStep = [1 1];
            else
                viewportWidth = width - 2 * padding - vSliderWidth;
                hSliderMin = 1;
                hSliderMax = contentsWidth - viewportWidth + 1;
                hSliderRange = hSliderMax - hSliderMin;
                oldHSliderValue = hSlider.Value;
                if oldHSliderValue < 0
                    hSliderValue = hSliderMin;
                elseif oldHSliderValue > hSliderMax
                    hSliderValue = hSliderMax;
                else
                    hSliderValue = oldHSliderValue;
                end
                hSliderStep(1) = min( 10 / hSliderRange, 1 );
                hSliderStep(2) = viewportWidth / hSliderRange;
            end
            
            % Set positions and slider properties
            uix.setPosition( child, contentsPosition, 'pixels' )
            set( vSlider, 'Position', vSliderPosition, ...
                'Min', vSliderMin, 'Max', vSliderMax, ...
                'Value', vSliderValue, 'SliderStep', vSliderStep )
            set( hSlider, 'Position', hSliderPosition, ...
                'Min', hSliderMin, 'Max', hSliderMax, ...
                'Value', hSliderValue, 'SliderStep', hSliderStep )
            
        end % redraw
        
        function addChild( obj, child )
            %addChild  Add child
            %
            %  c.addChild(d) adds the child d to the container c.
            
            % Add to sizes
            obj.Widths_(end+1,:) = -1;
            obj.Heights_(end+1,:) = -1;
            obj.VerticalSliders(end+1,:) = uicontrol( ...
                'Internal', true, 'Parent', obj, ...
                'Style', 'slider', 'Callback', @obj.onSliderClicked );
            obj.HorizontalSliders(end+1,:) = uicontrol( ...
                'Internal', true, 'Parent', obj, ...
                'Style', 'slider', 'Callback', @obj.onSliderClicked );
            
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
            obj.VerticalSliders(tf,:) = [];
            obj.HorizontalSliders(tf,:) = [];
            
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
            obj.VerticalSliders = obj.VerticalSliders(indices,:);
            obj.HorizontalSliders = obj.HorizontalSliders(indices,:);
            
            % Call superclass method
            reorder@uix.mixin.Panel( obj, indices )
            
        end % reorder
        
        function showSelection( obj )
            %showSelection  Show selected child, hide the others
            %
            %  c.showSelection() shows the selected child of the container
            %  c, and hides the others.
            
            % Call superclass method
            showSelection@uix.mixin.Panel( obj )
            
            % Show and hide sliders based on selection
            selection = obj.Selection_;
            for ii = 1:numel( obj.Contents_ )
                if ii == selection
                    obj.VerticalSliders(ii).Visible = 'on';
                    obj.HorizontalSliders(ii).Visible = 'on';
                else
                    obj.VerticalSliders(ii).Visible = 'off';
                    obj.HorizontalSliders(ii).Visible = 'off';
                end
            end
            
        end % showSelection
        
    end % template methods
    
    methods( Access = private )
        
        function onSliderClicked( obj, ~, ~ )
            %onSliderClicked  Event handler
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onSliderClicked
        
    end % event handlers
    
end % classdef