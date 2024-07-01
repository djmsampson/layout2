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
        Width % width of contents, in pixels and/or weights
        MinimumWidth % minimum width of contents, in pixels
        VerticalStep % vertical slider step, in pixels
        VerticalOffset % vertical offset of contents, in pixels
        HorizontalStep % horizontal slider step, in pixels
        HorizontalOffset % horizontal offset of contents, in pixels
        MouseWheelEnabled % mouse wheel scrolling enabled [on|off]
    end

    properties( Access = private )
        Height_ = -1 % backing for Height
        MinimumHeight_ = 1 % backing for MinimumHeight
        Width_ = -1 % backing for Width
        MinimumWidth_ = 1 % backing for MinimumWidth
        VerticalSlider % slider
        VerticalStep_ = 10 % backing for VerticalStep
        HorizontalSlider % slider
        HorizontalStep_ = 10 % backing for HorizontalStep
        BlankingPlate % blanking plate
        MouseWheelListener % mouse listener
        MouseWheelEnabled_ = 'on' % backing for MouseWheelEnabled
        ScrollingListener % slider listener
        ScrolledListener % slider listener
        BackgroundColorListener % property listener
    end

    properties( Dependent, Hidden )
        Heights % height of contents, in pixels and/or weights
        MinimumHeights % minimum height of contents, in pixels
        Widths % width of contents, in pixels and/or weights
        MinimumWidths % minimum width of contents, in pixels
        VerticalSteps % vertical slider step, in pixels
        VerticalOffsets % vertical offset of contents, in pixels
        HorizontalSteps % horizontal slider step, in pixels
        HorizontalOffsets % horizontal offset of contents, in pixels
    end % deprecated properties

    properties( Constant, Access = private )
        SliderSize = 20 % slider size, in pixels
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

            % Create sliders
            vSlider = matlab.ui.control.UIControl( ...
                'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'Style', 'slider', ...
                'BackgroundColor', obj.BackgroundColor );
            hSlider = matlab.ui.control.UIControl( ...
                'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'Style', 'slider', ...
                'BackgroundColor', obj.BackgroundColor );
            plate = matlab.ui.control.UIControl( ...
                'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'Style', 'text', 'Enable', 'inactive', ...
                'BackgroundColor', obj.BackgroundColor );

            % Store properties
            obj.VerticalSlider = vSlider;
            obj.HorizontalSlider = hSlider;
            obj.BlankingPlate = plate;

            % Create listeners
            backgroundColorListener = event.proplistener( obj, ...
                findprop( obj, 'BackgroundColor' ), 'PostSet', ...
                @obj.onBackgroundColorChanged );
            scrollingListener = event.listener( [vSlider; hSlider], ...
                'ContinuousValueChange', @obj.onSliderScrolling );
            scrolledListener = event.listener( [vSlider; hSlider], ...
                'Action', @obj.onSliderScrolled );

            % Store listeners
            obj.BackgroundColorListener = backgroundColorListener;
            obj.ScrollingListener = scrollingListener;
            obj.ScrolledListener = scrolledListener;

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
            obj.Height_ = double( value );

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
            assert( isnumeric( value ) && isscalar( value ) && ...
                isreal( value ) && ~isnan( value ) && ~isinf( value ) && ...
                value > 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''MinimumHeight'' must be numeric, scalar, real, finite and positive.' )

            % Set
            obj.MinimumHeight_ = double( value );

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
            obj.Width_ = double( value );

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
            assert( isnumeric( value ) && isscalar( value ) && ...
                isreal( value ) && ~isnan( value ) && ~isinf( value ) && ...
                value > 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''MinimumWidth'' must be numeric, scalar, real, finite and positive.' )

            % Set
            obj.MinimumWidth_ = double( value );

            % Mark as dirty
            obj.Dirty = true;

        end % set.MinimumWidth

        function value = get.VerticalOffset( obj )

            value = max( -obj.VerticalSlider.Value - 1, 0 );

        end % get.VerticalOffset

        function set.VerticalOffset( obj, value )

            % Reshape
            value = value(:);

            % Check
            assert( isnumeric( value ) && isscalar( value ) && ...
                isreal( value ) && ~isnan( value ) && ~isinf( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''VerticalOffset'' must be numeric, scalar, real and finite.' )

            % Set
            obj.VerticalSlider.Value = double( -value - 1 );

            % Mark as dirty
            obj.Dirty = true;

        end % set.VerticalOffset

        function value = get.VerticalStep( obj )

            value = obj.VerticalStep_;

        end % get.VerticalStep

        function set.VerticalStep( obj, value )

            % Resize
            value = value(:);

            % Check
            assert( isnumeric( value ) && isscalar( value ) && ...
                isreal( value ) && ~isnan( value ) && ~isinf( value ) && ...
                value > 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''VerticalStep'' must be numeric, scalar, real, finite and positive.' )

            % Set
            obj.VerticalStep_ = double( value );

            % Mark as dirty
            obj.Dirty = true;

        end % set.VerticalStep

        function value = get.HorizontalOffset( obj )

            value = max( obj.HorizontalSlider.Value, 0 );

        end % get.HorizontalOffset

        function set.HorizontalOffset( obj, value )

            % Reshape
            value = value(:);

            % Check
            assert( isnumeric( value ) && isscalar( value ) && ...
                isreal( value ) && ~isnan( value ) && ~isinf( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''HorizontalOffset'' must be numeric, scalar, real and finite.' )

            % Set
            obj.HorizontalSlider.Value = double( value );

            % Mark as dirty
            obj.Dirty = true;

        end % set.HorizontalOffset

        function value = get.HorizontalStep( obj )

            value = obj.HorizontalStep_;

        end % get.HorizontalStep

        function set.HorizontalStep( obj, value )

            % Resize
            value = value(:);

            % Check
            assert( isnumeric( value ) && isscalar( value ) && ...
                isreal( value ) && ~isnan( value ) && ~isinf( value ) && ...
                value > 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''HorizontalStep'' must be numeric, scalar, real, finite and positive.' )

            % Set
            obj.VerticalStep_ = double( value );

            % Mark as dirty
            obj.Dirty = true;

        end % set.HorizontalStep

        function value = get.MouseWheelEnabled( obj )

            value = obj.MouseWheelEnabled_;

        end % get.MouseWheelEnabled

        function set.MouseWheelEnabled( obj, value )

            % Check
            try
                value = char( value );
                assert( ismember( value, {'on','off'} ) )
            catch
                error( 'uix:InvalidArgument', ...
                    'Property ''MouseWheelEnabled'' must ''on'' or ''off''.' )
            end

            % Set
            obj.MouseWheelEnabled_ = value;
            listener = obj.MouseWheelListener;
            if ~isempty( listener )
                listener.Enabled = strcmp( value, 'on' );
            end

        end % set.MouseWheelEnabled

    end % accessors

    methods

        function value = get.Heights( obj )

            value = repmat( obj.Height, size( obj.Contents_ ) );

        end % get.Heights

        function set.Heights( obj, value )

            % Reshape
            value = value(:);

            % Check
            assert( numel( value ) == numel( obj.Contents_ ), ...
                'uix:InvalidArgument', ...
                'Property ''Heights'' must be an array, one per child.' )

            % Set
            if ~isempty( value )
                obj.Height = value(1); % top
            end

        end % set.Heights

        function value = get.MinimumHeights( obj )

            value = repmat( obj.MinimumHeight, size( obj.Contents_ ) );

        end % get.MinimumHeights

        function set.MinimumHeights( obj, value )

            % Reshape
            value = value(:);

            % Check
            assert( numel( value ) == numel( obj.Contents_ ), ...
                'uix:InvalidArgument', ...
                'Property ''MinimumHeights'' must be an array, one per child.' )

            % Set
            if ~isempty( value )
                obj.MinimumHeight = value(1); % top
            end

        end % set.MinimumHeights

        function value = get.Widths( obj )

            value = repmat( obj.Width, size( obj.Contents_ ) );

        end % get.Widths

        function set.Widths( obj, value )

            % Reshape
            value = value(:);

            % Check
            assert( numel( value ) == numel( obj.Contents_ ), ...
                'uix:InvalidArgument', ...
                'Property ''Widths'' must be an array, one per child.' )

            % Set
            if ~isempty( value )
                obj.Width = value(1); % top
            end

        end % set.Widths

        function value = get.MinimumWidths( obj )

            value = repmat( obj.MinimumWidth, size( obj.Contents_ ) );

        end % get.MinimumWidths

        function set.MinimumWidths( obj, value )

            % Reshape
            value = value(:);

            % Check
            assert( numel( value ) == numel( obj.Contents_ ), ...
                'uix:InvalidArgument', ...
                'Property ''MinimumWidths'' must be an array, one per child.' )

            % Set
            if ~isempty( value )
                obj.MinimumWidth = value(1); % top
            end

        end % set.MinimumWidths

        function value = get.VerticalSteps( obj )

            value = repmat( obj.VerticalStep, size( obj.Contents_ ) );

        end % get.VerticalSteps

        function set.VerticalSteps( obj, value )

            % Reshape
            value = value(:);

            % Check
            assert( numel( value ) == numel( obj.Contents_ ), ...
                'uix:InvalidArgument', ...
                'Property ''VerticalSteps'' must be an array, one per child.' )

            % Set
            if ~isempty( value )
                obj.VerticalStep = value(1); % top
            end

        end % set.VerticalSteps

        function value = get.VerticalOffsets( obj )

            value = repmat( obj.VerticalOffset, size( obj.Contents_ ) );

        end % get.VerticalOffsets

        function set.VerticalOffsets( obj, value )

            % Reshape
            value = value(:);

            % Check
            assert( numel( value ) == numel( obj.Contents_ ), ...
                'uix:InvalidArgument', ...
                'Property ''VerticalOffsets'' must be an array, one per child.' )

            % Set
            if ~isempty( value )
                obj.VerticalOffset = value(1); % top
            end

        end % set.VerticalOffsets

        function value = get.HorizontalSteps( obj )

            value = repmat( obj.HorizontalStep, size( obj.Contents_ ) );

        end % get.HorizontalSteps

        function set.HorizontalSteps( obj, value )

            % Reshape
            value = value(:);

            % Check
            assert( numel( value ) == numel( obj.Contents_ ), ...
                'uix:InvalidArgument', ...
                'Property ''HorizontalSteps'' must be an array, one per child.' )

            % Set
            if ~isempty( value )
                obj.HorizontalStep = value(1); % top
            end

        end % set.HorizontalSteps

        function value = get.HorizontalOffsets( obj )

            value = repmat( obj.HorizontalOffset, size( obj.Contents_ ) );

        end % get.HorizontalOffsets

        function set.HorizontalOffsets( obj, value )

            % Reshape
            value = value(:);

            % Check
            assert( numel( value ) == numel( obj.Contents_ ), ...
                'uix:InvalidArgument', ...
                'Property ''HorizontalOffsets'' must be an array, one per child.' )

            % Set
            if ~isempty( value )
                obj.HorizontalOffset = value(1); % top
            end

        end % set.HorizontalOffsets

    end % deprecated accessors

    methods( Access = protected )

        function redraw( obj )
            %redraw  Redraw

            % Retrieve width and height
            contentsWidth = obj.Width_;
            minimumWidth = obj.MinimumWidth_;
            contentsHeight = obj.Height_;
            minimumHeight = obj.MinimumHeight_;

            % Retrieve decorations
            vSlider = obj.VerticalSlider;
            hSlider = obj.HorizontalSlider;
            plate = obj.BlankingPlate;

            % Compute dimensions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            width = bounds(3);
            height = bounds(4);
            sliderSize = uix.ScrollingPanel.SliderSize; % slider size
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
                vStep = obj.VerticalStep_;
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
                hStep = obj.HorizontalStep_;
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
            contents = obj.Contents_;
            for ii = 1:numel( contents )
                uix.setPosition( contents(ii), contentsPosition, 'pixels' )
            end
            plate.Position = platePosition;

        end % redraw

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
            if strcmp( obj.VerticalSlider.Enable, 'on' ) % scroll vertically
                delta = eventData.VerticalScrollCount * ...
                    eventData.VerticalScrollAmount * obj.VerticalStep;
                obj.VerticalOffset = obj.VerticalOffset + delta;
            elseif strcmp( obj.HorizontalSlider.Enable, 'on' ) % scroll horizontally
                delta = eventData.VerticalScrollCount * ...
                    eventData.VerticalScrollAmount * obj.HorizontalStep;
                obj.HorizontalOffset = obj.HorizontalOffset + delta;
            end

            % Raise event
            notify( obj, 'Scrolled' )

        end % onMouseScrolled

        function onBackgroundColorChanged( obj, ~, ~ )
            %onBackgroundColorChanged  Handler for BackgroundColor changes

            backgroundColor = obj.BackgroundColor;
            set( obj.HorizontalSlider, 'BackgroundColor', backgroundColor )
            set( obj.VerticalSlider, 'BackgroundColor', backgroundColor )
            set( obj.BlankingPlate, 'BackgroundColor', backgroundColor )

        end % onBackgroundColorChanged

    end % event handlers

end % classdef