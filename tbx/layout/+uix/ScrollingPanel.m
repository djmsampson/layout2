classdef ScrollingPanel < uix.Container & uix.mixin.Container
    %uix.ScrollingPanel  Scrolling panel
    %
    %  p = uix.ScrollingPanel(p1,v1,p2,v2,...) constructs a scrolling panel
    %  and sets parameter p1 to value v1, etc.
    %
    %  A scrolling panel is a standard container (uicontainer) that shows
    %  one its contents and hides the others.
    %
    %  See also: uix.Panel, uix.BoxPanel, uix.TabPanel, uicontainer
    
    %  Copyright 2009-2024 The MathWorks, Inc.
    
    properties( Dependent )
        Height % height of contents, in pixels and/or weights
        MinimumHeight % minimum height of contents, in pixels
        VerticalOffset % vertical offset of contents, in pixels
        VerticalStep % vertical slider step, in pixels
        Width % width of contents, in pixels and/or weights
        MinimumWidth % minimum width of contents, in pixels
        HorizontalOffset % horizontal offset of contents, in pixels
        HorizontalStep % horizontal slider step, in pixels
        MouseWheelEnabled % mouse wheel scrolling enabled [on|off]
    end
    
    properties( Access =  )
        Height_ = -1 % backing for Height
        MinimumHeight_ = 1 % backing for MinimumHeight
        Width_ = -1 % backing for Width
        MinimumWidth_ = 1 % backing for MinimumWidth
        HorizontalSlider % slider
        VerticalSlider % slider
        BlankingPlate % blanking plate
        HorizontalStep_ = obj.SliderStep % step
        VerticalStep_ = obj.SliderStep % step
    end
    
    properties( Access = private )
        MouseWheelListener % mouse listener
        MouseWheelEnabled_ = 'on' % backing for MouseWheelEnabled
        ScrollingListener % slider listener
        ScrolledListener % slider listener
        BackgroundColorListener % property listener
    end
    
    properties( Constant, Access = private )
        SliderSize = 20 % slider size, in pixels
        SliderStep = 10 % slider step, in pixels
    end
    
    events( NotifyAccess = private )
        Scrolling
        Scrolled
    end
    
    methods
        
        function obj = ScrollingPanel( varargin )
            %uix.ScrollingPanel  Scrolling panel constructor
            %
            %  p = uix.ScrollingPanel() constructs a scrolling panel.
            %
            %  p = uix.ScrollingPanel(p1,v1,p2,v2,...) sets parameter p1 to
            %  value v1, etc.
            
            % Create listeners
            backgroundColorListener = event.proplistener( obj, ...
                findprop( obj, 'BackgroundColor' ), 'PostSet', ...
                @obj.onBackgroundColorChanged );
            
            % Store properties
            obj.BackgroundColorListener = backgroundColorListener;
            
            % Set properties
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Height( obj )
            
            value = obj.Height_;
            
        end % get.Height
        
        function set.Height( obj, value )

            % Reshape
            value = value(:);
            
            % Check
            assert( isnumeric( value ) && isscalar( value ) && ...
                isreal( value ) && ~isnan( value ) && ~isinf( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Height'' must be numeric, scalar, real and finite.' )
            
            % Set
            obj.Height_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Height
        
        function value = get.MinimumHeight( obj )
            
            value = obj.MinimumHeight_;
            
        end % get.MinimumHeight
        
        function set.MinimumHeight( obj, value )

            % Reshape
            value = value(:);
            
            % Check
            assert( isnumeric( value ) && isscalar( value ) && value > 0 && ...
                isreal( value ) && ~isnan( value ) && ~isinf( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''MinimumHeight'' must be numeric, scalar, real, positive, and finite.' )
            
            % Set
            obj.MinimumHeight_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.MinimumHeight
        
        function value = get.Width( obj )
            
            value = obj.Width_;
            
        end % get.Width
        
        function set.Width( obj, value )
            
            % Reshape
            value = value(:);
            
            % Check
            assert( isnumeric( value ) && isscalar( value ) && ...
                isreal( value ) && ~isnan( value ) && ~isinf( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Width'' must be numeric, scalar, real and finite.' )
            
            % Set
            obj.Width_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Width
        
        function value = get.MinimumWidth( obj )
            
            value = obj.MinimumWidth_;
            
        end % get.MinimumWidth
        
        function set.MinimumWidth( obj, value )
            
            % Reshape
            value = value(:);
            
            % Check
            assert( isnumeric( value ) && isscalar( value ) && value > 0 && ...
                isreal( value ) && ~isnan( value ) && ~isinf( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''MinimumWidth'' must be numeric, scalar, real, positive, and finite.' )
            
            % Set
            obj.MinimumWidth_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.MinimumWidth
        
        function value = get.VerticalOffset( obj )
            
            slider = obj.VerticalSlider;
            if isempty( slider )
                value = zeros( size( slider ) );
            else
                value = -vertcat( slider.Value ) - 1;
                value(value<0) = 0;
            end
            
        end % get.VerticalOffset
        
        function set.VerticalOffset( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''VerticalOffset'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''VerticalOffset'' must be real and finite.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''VerticalOffset'' must match size of contents.' )
            
            % Set
            slider = obj.VerticalSlider;
            for ii = 1:numel( slider )
                slider(ii).Value = -value(ii) - 1;
            end
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.VerticalOffset
        
        function value = get.VerticalStep( obj )
            
            value = obj.VerticalStep_;
            
        end % get.VerticalStep
        
        function set.VerticalStep( obj, value )
            
            % For those who can't tell a column from a row...
            if isrow( value )
                value = transpose( value );
            end
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''VerticalStep'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ) && all( value > 0 ), ...
                'uix:InvalidPropertyValue', ...
                'Elements of property ''VerticalStep'' must be real, finite and positive.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''VerticalStep'' must match size of contents.' )
            
            % Set
            obj.VerticalStep_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.VerticalStep
        
        function value = get.HorizontalOffset( obj )
            
            slider = obj.HorizontalSlider;
            if isempty( slider )
                value = zeros( size( slider ) );
            else
                value = vertcat( slider.Value );
                value(value<0) = 0;
            end
            
        end % get.HorizontalOffset
        
        function set.HorizontalOffset( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''HorizontalOffset'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''HorizontalOffset'' must be real and finite.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''HorizontalOffset'' must match size of contents.' )
            
            % Set
            slider = obj.HorizontalSlider;
            for ii = 1:numel( slider )
                slider(ii).Value = value(ii);
            end
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.HorizontalOffset
        
        function value = get.HorizontalStep( obj )
            
            value = obj.HorizontalStep_;
            
        end % get.HorizontalStep
        
        function set.HorizontalStep( obj, value )
            
            % For those who can't tell a column from a row...
            if isrow( value )
                value = transpose( value );
            end
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''HorizontalStep'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ) && all( value > 0 ), ...
                'uix:InvalidPropertyValue', ...
                'Elements of property ''HorizontalStep'' must be real, finite and positive.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''HorizontalStep'' must match size of contents.' )
            
            % Set
            obj.HorizontalStep_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.HorizontalStep
        
        function value = get.MouseWheelEnabled( obj )
            
            value = obj.MouseWheelEnabled_;
            
        end % get.MouseWheelEnabled
        
        function set.MouseWheelEnabled( obj, value )
            
            value = uix.validateScalarStringOrCharacterArray( value, ...
                'MouseWheelEnabled' );
            assert( any( strcmp( value, {'on','off'} ) ), ...
                'uix:InvalidArgument', ...
                'Property ''MouseWheelEnabled'' must ''on'' or ''off''.' )
            listener = obj.MouseWheelListener;
            if ~isempty( listener )
                listener.Enabled = strcmp( value, 'on' );
            end
            obj.MouseWheelEnabled_ = value;
            
        end % set.MouseWheelEnabled
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw
            
            % Return if no contents
            selection = obj.Selection_;
            if selection == 0, return, end
            
            % Retrieve width and height of selected contents
            contentsWidth = obj.Width_(selection);
            minimumWidth = obj.MinimumWidth_(selection);
            contentsHeight = obj.Height_(selection);
            minimumHeight = obj.MinimumHeight_(selection);
            
            % Retrieve selected contents and corresponding decorations
            child = obj.Contents_(selection);
            vSlider = obj.VerticalSlider(selection);
            hSlider = obj.HorizontalSlider(selection);
            plate = obj.BlankingPlate(selection);
            
            % Compute dimensions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            width = bounds(3);
            height = bounds(4);
            sliderSize = obj.SliderSize; % slider size
            vSliderWidth = sliderSize * ...
                (contentsHeight > height | ...
                minimumHeight > height); % first pass
            hSliderHeight = sliderSize * ...
                (contentsWidth > width - vSliderWidth | ...
                minimumWidth > width - vSliderWidth);
            vSliderWidth = sliderSize * ...
                (contentsHeight > height - hSliderHeight | ...
                minimumHeight > height - hSliderHeight); % second pass
            vSliderWidth = min( vSliderWidth, width ); % limit
            hSliderHeight = min( hSliderHeight, height ); % limit
            vSliderHeight = height - hSliderHeight;
            hSliderWidth = width - vSliderWidth;
            width = uix.calcPixelSizes( width, ...
                [contentsWidth;vSliderWidth], ...
                [minimumWidth;vSliderWidth], 0, 0 );
            contentsWidth = width(1); % to be offset
            height = uix.calcPixelSizes( height, ...
                [contentsHeight;hSliderHeight], ...
                [minimumHeight;hSliderHeight], 0, 0 );
            contentsHeight = height(1); % to be offset
            
            % Compute positions
            contentsPosition = [1 1+hSliderHeight+vSliderHeight-contentsHeight contentsWidth contentsHeight];
            vSliderPosition = [1+hSliderWidth 1+hSliderHeight vSliderWidth vSliderHeight];
            hSliderPosition = [1 1 hSliderWidth hSliderHeight];
            platePosition = [1+hSliderWidth 1 vSliderWidth hSliderHeight];
            
            % Compute and set vertical slider properties
            if vSliderWidth == 0 || vSliderHeight == 0 || vSliderHeight <= vSliderWidth
                % Slider is invisible or incorrectly oriented
                set( vSlider, 'Style', 'text', 'Enable', 'inactive', ...
                    'Position', vSliderPosition, ...
                    'Min', 0, 'Max', 1, 'Value', 1 )
            else
                % Compute properties
                vSliderMin = 0;
                vSliderMax = contentsHeight - vSliderHeight;
                vSliderValue = -vSlider.Value; % negative sign convention
                vSliderValue = max( vSliderValue, vSliderMin ); % limit
                vSliderValue = min( vSliderValue, vSliderMax ); % limit
                vStep = obj.VerticalStep_(selection);
                vSliderStep(1) = min( vStep / vSliderMax, 1 );
                vSliderStep(2) = max( vSliderHeight / vSliderMax, vSliderStep(1) );
                contentsPosition(2) = contentsPosition(2) + vSliderValue;
                % Set properties
                set( vSlider, 'Style', 'slider', 'Enable', 'on', ...
                    'Position', vSliderPosition, ...
                    'Min', -vSliderMax, 'Max', -vSliderMin, ...
                    'Value', -vSliderValue, 'SliderStep', vSliderStep )
            end
            
            % Compute and set horizontal slider properties
            if hSliderHeight == 0 || hSliderWidth == 0 || hSliderWidth <= hSliderHeight
                % Slider is invisible or incorrectly oriented
                set( hSlider, 'Style', 'text', 'Enable', 'inactive', ...
                    'Position', hSliderPosition, ...
                    'Min', -1, 'Max', 0, 'Value', -1 )
            else
                % Compute properties
                hSliderMin = 0;
                hSliderMax = contentsWidth - hSliderWidth;
                hSliderValue = hSlider.Value; % positive sign convention
                hSliderValue = max( hSliderValue, hSliderMin ); % limit
                hSliderValue = min( hSliderValue, hSliderMax ); % limit
                hStep = obj.HorizontalStep_(selection);
                hSliderStep(1) = min( hStep / hSliderMax, 1 );
                hSliderStep(2) = max( hSliderWidth / hSliderMax, hSliderStep(1) );
                contentsPosition(1) = contentsPosition(1) - hSliderValue;
                % Set properties
                set( hSlider, 'Style', 'slider', 'Enable', 'on', ...
                    'Position', hSliderPosition, ...
                    'Min', hSliderMin, 'Max', hSliderMax, ...
                    'Value', hSliderValue, 'SliderStep', hSliderStep )
            end
            
            % Set contents and blanking plate positions
            uix.setPosition( child, contentsPosition, 'pixels' )
            set( plate, 'Position', platePosition )
            
        end % redraw
        
        function addChild( obj, child )
            %addChild  Add child
            %
            %  c.addChild(d) adds the child d to the container c.
            
            % Create decorations
            verticalSlider = matlab.ui.control.UIControl( ...
                'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'Style', 'slider', ...
                'BackgroundColor', obj.BackgroundColor );
            horizontalSlider = matlab.ui.control.UIControl( ...
                'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'Style', 'slider', ...
                'BackgroundColor', obj.BackgroundColor );
            blankingPlate = matlab.ui.control.UIControl( ...
                'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'Style', 'text', 'Enable', 'inactive', ...
                'BackgroundColor', obj.BackgroundColor );
            
            % Add to sizes
            obj.VerticalSlider(end+1,:) = verticalSlider;
            obj.HorizontalSlider(end+1,:) = horizontalSlider;
            obj.BlankingPlate(end+1,:) = blankingPlate;
            obj.VerticalStep_(end+1,:) = obj.SliderStep;
            obj.HorizontalStep_(end+1,:) = obj.SliderStep;
            obj.updateSliderListeners()
            
            % Call superclass method
            addChild@uix.mixin.Container( obj, child )
            
        end % addChild
        
        function removeChild( obj, child )
            %removeChild  Remove child
            %
            %  c.removeChild(d) removes the child d from the container c.
            
            % Identify child
            tf = obj.Contents_ == child;
            
            % Destroy decorations
            delete( obj.VerticalSlider(tf,:) )
            delete( obj.HorizontalSlider(tf,:) )
            delete( obj.BlankingPlate(tf,:) )
            
            % Remove from sizes
            obj.VerticalSlider(tf,:) = [];
            obj.HorizontalSlider(tf,:) = [];
            obj.BlankingPlate(tf,:) = [];
            obj.VerticalStep_(tf,:) = [];
            obj.HorizontalStep_(tf,:) = [];
            obj.updateSliderListeners()
            
            % Call superclass method
            removeChild@uix.mixin.Container( obj, child )
            
        end % removeChild
        
        function reparent( obj, ~, newFigure )
            %reparent  Reparent container
            %
            %  c.reparent(a,b) reparents the container c from the figure a
            %  to the figure b.
            
            if isempty( newFigure )
                obj.MouseWheelListener = [];
            else
                listener = event.listener( newFigure, ...
                    'WindowScrollWheel', @obj.onMouseScrolled );
                listener.Enabled = strcmp( obj.MouseWheelEnabled_, 'on' );
                obj.MouseWheelListener = listener;
            end
            
        end % reparent
        
        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).
            
            % Reorder
            obj.VerticalSlider = obj.VerticalSlider(indices,:);
            obj.HorizontalSlider = obj.HorizontalSlider(indices,:);
            obj.BlankingPlate = obj.BlankingPlate(indices,:);
            obj.VerticalStep_ = obj.VerticalStep_(indices,:);
            obj.HorizontalStep_ = obj.HorizontalStep_(indices,:);
            
            % Call superclass method
            reorder@uix.mixin.Container( obj, indices )
            
        end % reorder
        
        function showSelection( obj )
            %showSelection  Show selected child, hide the others
            %
            %  c.showSelection() shows the selected child of the container
            %  c, and hides the others.
            
            % Call superclass method
            showSelection@uix.mixin.Container( obj )
            
            % Show and hide slider based on selection
            selection = obj.Selection_;
            for ii = 1:numel( obj.Contents_ )
                if ii == selection
                    obj.VerticalSlider(ii).Visible = 'on';
                    obj.HorizontalSlider(ii).Visible = 'on';
                    obj.BlankingPlate(ii).Visible = 'on';
                else
                    obj.VerticalSlider(ii).Visible = 'off';
                    obj.HorizontalSlider(ii).Visible = 'off';
                    obj.BlankingPlate(ii).Visible = 'off';
                end
            end
            
        end % showSelection
        
    end % template methods
    
    methods( Access = ?matlab.unittest.TestCase )
        
        function onSliderScrolling( obj, ~, ~ )
            %onSliderScrolling  Event handler
            
            % Mark as dirty
            obj.Dirty = true;
            
            % Raise event
            notify( obj, 'Scrolling' )
            
        end % onSliderScrolling
        
        function onSliderScrolled( obj, ~, ~ )
            %onSliderScrolled  Event handler
            
            % Mark as dirty
            obj.Dirty = true;
            
            % Raise event
            notify( obj, 'Scrolled' )
            
        end % onSliderScrolled
        
        function onMouseScrolled( obj, ~, eventData )
            %onMouseScrolled  Event handler
            
            sel = obj.Selection_;
            if sel == 0
                return
            else
                % Get pointer position and panel bounds
                pp = getpixelposition( obj, true );
                f = ancestor( obj, 'figure' );
                cpu = f.CurrentPoint; % figure Units
                cpwhu = [cpu 0 0]; % [x y] to [x y w h] for hgconvertunits
                cpwh = hgconvertunits( f, cpwhu, f.Units, 'pixels', obj ); % pixels
                cp = cpwh(1:2); % [x y w h] to [x y]
                
                % Check that pointer is over panel
                if cp(1) < pp(1) || cp(1) > pp(1) + pp(3) || ...
                        cp(2) < pp(2) || cp(2) > pp(2) + pp(4), return, end
                % Scroll
                if strcmp( obj.VerticalSlider(sel).Enable, 'on' ) % scroll vertically
                    delta = eventData.VerticalScrollCount * ...
                        eventData.VerticalScrollAmount * obj.VerticalStep(sel);
                    obj.VerticalOffset(sel) = obj.VerticalOffset(sel) + delta;
                elseif strcmp( obj.HorizontalSlider(sel).Enable, 'on' ) % scroll horizontally
                    delta = eventData.VerticalScrollCount * ...
                        eventData.VerticalScrollAmount * obj.HorizontalStep(sel);
                    obj.HorizontalOffset(sel) = obj.HorizontalOffset(sel) + delta;
                end
                % Raise event
                notify( obj, 'Scrolled' )
            end
            
        end % onMouseScrolled
        
        function onBackgroundColorChanged( obj, ~, ~ )
            %onBackgroundColorChanged  Handler for BackgroundColor changes
            
            set( obj.HorizontalSlider, 'BackgroundColor', obj.BackgroundColor )
            set( obj.VerticalSlider, 'BackgroundColor', obj.BackgroundColor )
            set( obj.BlankingPlate, 'BackgroundColor', obj.BackgroundColor )
            
        end % onBackgroundColorChanged
        
    end % event handlers
    
    methods( Access = private )
        
        function updateSliderListeners( obj )
            %updateSliderListeners  Update listeners to slider events
            
            if isempty( obj.VerticalSlider )
                obj.ScrollingListener = [];
                obj.ScrolledListener = [];
            else
                obj.ScrollingListener = event.listener( ...
                    [obj.VerticalSlider; obj.HorizontalSlider], ...
                    'ContinuousValueChange', @obj.onSliderScrolling );
                obj.ScrolledListener = event.listener( ...
                    [obj.VerticalSlider; obj.HorizontalSlider], ...
                    'Action', @obj.onSliderScrolled );
            end
            
        end % updateSliderListeners
        
    end % helpers
    
end % classdef