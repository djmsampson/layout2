classdef TabPanel < uix.Container
    
    properties( Access = public, Dependent, AbortSet )
        FontName % font name
        FontSize % font size
        Selection % selected contents
        TabEnable % tab enable states
        TabLocation % tab location [top|bottom]
        TabNames % tab names
        TabWidth % tab width
    end
    
    properties( Access = private )
        FontName_ = get( 0, 'DefaultUicontrolFontName' ) % backing for FontName
        FontSize_ = get( 0, 'DefaultUicontrolFontSize' ) % backing for FontSize
        LocationObserver % location observer
        Selection_ = 0 % backing for Selection
        Tabs = gobjects( [0 1] ) % tabs
        TabListeners = event.listener.empty( [0 1] ) % tab listeners
        TabLocation_ = 'top' % backing for TabPosition
        TabHeight_ = 0 % cache of tab height
        TabWidth_ = 50 % backing for TabWidth
    end
    
    properties( Access = private, Constant )
        FontNames = listfonts() % all available font names
    end
    
    methods
        
        function obj = TabPanel( varargin )
            
            % Call superclass constructor
            obj@uix.Container()
            
            % Create location observer
            locationObserver = uix.LocationObserver( obj );
            
            % Store properties
            obj.LocationObserver = locationObserver;
            
            % Set properties
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.FontName( obj )
            
            value = obj.FontName_;
            
        end % get.FontName
        
        function set.FontName( obj, value )
            
            % Check
            assert( ischar( value ) && any( strcmp( value, obj.FontNames ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''FontName'' must be a valid font name.' )
            
            % Set
            obj.FontName_ = value;
            
            % Update existing tabs
            tabs = obj.Tabs;
            n = numel( tabs );
            for ii = 1:n
                tab = tabs(ii);
                tab.FontName = value;
            end
            
            % Update tab height
            if n ~= 0
                cTabExtents = get( tabs, {'Extent'} );
                tabExtents = vertcat( cTabExtents{:} );
                obj.TabHeight_ = max( tabExtents(:,4) );
            end
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.FontName
        
        function value = get.FontSize( obj )
            
            value = obj.FontSize_;
            
        end % get.FontSize
        
        function set.FontSize( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value > 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''FontSize'' must be a positive scalar.' )
            
            % Set
            obj.FontSize_ = value;
            
            % Update existing tabs
            tabs = obj.Tabs;
            n = numel( tabs );
            for ii = 1:n
                tab = tabs(ii);
                tab.FontSize = value;
            end
            
            % Update tab height
            if n ~= 0
                cTabExtents = get( tabs, {'Extent'} );
                tabExtents = vertcat( cTabExtents{:} );
                obj.TabHeight_ = max( tabExtents(:,4) );
            end
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.FontSize
        
        function value = get.Selection( obj )
            
            value = obj.Selection_;
            
        end % get.Selection
        
        function set.Selection( obj, value ) % TODO
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Selection'' must be of type double.' )
            assert( isequal( size( value ), [1 1] ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Selection'' must be scalar.' )
            assert( isreal( value ) && rem( value, 1 ) == 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Selection'' must be an integer.' )
            n = numel( obj.Contents_ );
            if n == 0
                assert( value == 0, 'uix:InvalidPropertyValue', ...
                    'Property ''Selection'' must be 0 for a container with no children.' )
            else
                assert( value >= 1 && value <= n, 'uix:InvalidPropertyValue', ...
                    'Property ''Selection'' must be between 1 and the number of children.' )
                assert( strcmp( obj.Tabs(value).Enable, 'inactive' ), ...
                    'uix:InvalidPropertyValue', 'Cannot select a disabled tab.' )
            end
            
            % Set
            obj.Selection_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Selection
        
        function value = get.TabEnable( obj )
            
            value = get( obj.Tabs, {'Enable'} );
            value(strcmp( value, 'inactive' )) = {'on'};
            
        end % get.TabEnable
        
        function set.TabEnable( obj, value )
            
            % Retrieve tabs
            tabs = obj.Tabs;
            tabListeners = obj.TabListeners;
            
            % Check
            assert( iscellstr( value ) && ...
                isequal( size( value ), size( tabs ) ) && ...
                all( strcmp( value, 'on' ) | strcmp( value, 'off' ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabEnable'' should be a cell array of strings ''on'' or ''off'', one per tab.' )
            
            % Set
            tf = strcmp( value, 'on' );
            value(tf) = {'inactive'};
            for ii = 1:numel( tabs )
                tabs(ii).Enable = value{ii};
                tabListeners(ii).Enabled = tf(ii);
            end
            
            % Update selection
            oldSelection = obj.Selection_;
            if oldSelection == 0
                % When no tab was selected, select the last enabled tab
                newSelection = find( tf, 1, 'last' );
                if isempty( newSelection )
                    newSelection = 0;
                end
                obj.Selection_ = newSelection;
                obj.Dirty = true;
            elseif ~tf(oldSelection)
                % When the tab that was selected is disabled, select the
                % first enabled tab to the right, or failing that, the last
                % enabled tab to the left, or failing that, nothing
                preSelection = find( tf(1:oldSelection-1), 1, 'last' );
                postSelection = oldSelection + ...
                    find( tf(oldSelection+1:end), 1, 'first' );
                if ~isempty( postSelection )
                    newSelection = postSelection;
                elseif ~isempty( preSelection )
                    newSelection = preSelection;
                else
                    newSelection = 0;
                end
                obj.Selection_ = newSelection;
                obj.Dirty = true;
            else
                % When the tab that was selected is enabled, the previous
                % selection remains valid
            end
            
        end % set.TabEnable
        
        function value = get.TabLocation( obj )
            
            value = obj.TabLocation_;
            
        end % get.TabLocation
        
        function set.TabLocation( obj, value )
            
            % Check
            assert( ischar( value ) && ...
                any( strcmp( value, {'top','bottom'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabLocation'' should be ''top'' or ''bottom''.' )
            
            % Set
            obj.TabLocation_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.TabLocation
        
        function value = get.TabNames( obj )
            
            value = get( obj.Tabs, {'String'} );
            
        end % get.TabNames
        
        function set.TabNames( obj, value )
            
            % Retrieve tabs
            tabs = obj.Tabs;
            
            % Check
            assert( iscellstr( value ) && ...
                isequal( size( value ), size( tabs ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabNames'' should be a cell array of strings, one per tab.' )
            
            % Set
            n = numel( tabs );
            for ii = 1:n
                tabs(ii).String = value{ii};
            end
            
            % Update tab height
            if n ~= 0
                cTabExtents = get( tabs, {'Extent'} );
                tabExtents = vertcat( cTabExtents{:} );
                obj.TabHeight_ = max( tabExtents(:,4) );
            end
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.TabNames
        
        function value = get.TabWidth( obj )
            
            value = obj.TabWidth_;
            
        end % get.TabWidth
        
        function set.TabWidth( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value > 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabWidth'' must be a positive scalar.' )
            
            % Set
            obj.TabWidth_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.TabWidth
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            
            % Compute positions
            location = obj.LocationObserver.Location;
            w = ceil( location(1) + location(3) ) - floor( location(1) ); % width
            h = ceil( location(2) + location(4) ) - floor( location(2) ); % height
            p = obj.Padding_; % padding
            tabs = obj.Tabs;
            tH = obj.TabHeight_; % tab height
            cH = max( [h - 2 * p - tH, 1] ); % contents height
            switch obj.TabLocation_
                case 'top'
                    cY = 1 + p; % contents y
                    tY = cY + cH + 1; % tab y
                case 'bottom'
                    tY = 1 + p; % tab y
                    cY = tY + tH + 1; % contents y
            end
            cX = 1 + p; % contents x
            cW = max( [w - 2 * p, 1] ); % contents width
            tW = obj.TabWidth_; % tab width
            for ii = 1:numel( tabs )
                tab = tabs(ii);
                tabPosition = [1 + (ii-1) * tW, tY, tW, tH];
                tab.Position = tabPosition;
            end
            contentsPosition = [cX cY cW cH];
            
            % Redraw tabs
            obj.redrawTabs()
            
            % Redraw contents
            children = obj.Contents_;
            selection = obj.Selection_;
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
        
        function addChild( obj, child )
            
            % Create new tab
            tab = matlab.ui.control.StyleControl( 'Internal', true, ...
                'Parent', obj, 'Style', 'text', 'Enable', 'inactive', ...
                'Units', 'pixels', 'FontName', obj.FontName_, ...
                'FontSize', obj.FontSize_ );
            tabListener = event.listener( tab, 'ButtonDown', @obj.onTabClick );
            n = numel( obj.Tabs );
            obj.Tabs(n+1,:) = tab;
            obj.TabListeners(n+1,:) = tabListener;
            
            % If nothing was selected, select the new content
            if obj.Selection_ == 0
                obj.Selection_ = n+1;
            end
            
            % Update tab height
            cTabExtents = get( obj.Tabs, {'Extent'} );
            tabExtents = vertcat( cTabExtents{:} );
            obj.TabHeight_ = max( tabExtents(:,4) );
            
            % Call superclass method
            addChild@uix.Container( obj, child )
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Find index of removed child
            contents = obj.Contents_;
            index = find( contents == child );
            
            % Remove tab
            delete( obj.Tabs(index) )
            obj.Tabs(index,:) = [];
            obj.TabListeners(index,:) = [];
            
            % Adjust selection
            oldSelection = obj.Selection_;
            if oldSelection < index
                % When a tab to the right of the selected tab is removed,
                % the previous selection remains valid
            elseif oldSelection > index
                % When a tab to the left of the selected tab is removed,
                % decrement the selection by 1
                obj.Selection_ = oldSelection - 1;
            else
                % When the selected tab is removed, select the first
                % enabled tab to the right, or failing that, the last
                % enabled tab to the left, or failing that, nothing
                tf = strcmp( get( obj.Tabs, {'Enable'} ), 'inactive' );
                preSelection = find( tf(1:oldSelection-1), 1, 'last' );
                postSelection = oldSelection - 1 + ...
                    find( tf(oldSelection:end), 1, 'first' );
                if ~isempty( postSelection )
                    newSelection = postSelection;
                elseif ~isempty( preSelection )
                    newSelection = preSelection;
                else
                    newSelection = 0;
                end
                obj.Selection_ = newSelection;
            end
            
            % Call superclass method
            removeChild@uix.Container( obj, child )
            
        end % removeChild
        
        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).
            
            % Reorder
            obj.Tabs = obj.Tabs(indices,:);
            obj.TabListeners = obj.TabListeners(indices,:);
            selection = obj.Selection_;
            if selection ~= 0
                obj.Selection_ = find( indices == selection );
            end
            
            % Call superclass method
            reorder@uix.Container( obj, indices )
            
        end % reorder
        
        function reparent( obj, oldAncestors, newAncestors )
            %reparent  Reparent container
            %
            %  c.reparent(a,b) reparents the container c from the ancestors
            %  a to the ancestors b.
            
            % Refresh location observer
            locationObserver = uix.LocationObserver( [newAncestors; obj] );
            obj.LocationObserver = locationObserver;
            
            % Call superclass method
            reparent@uix.Container( obj, oldAncestors, newAncestors )
            
        end % reparent
        
    end % template methods
    
    methods( Access = private )
        
        function redrawTabs( ~ )
            %redrawTabs  Redraw tabs
            %
            %  p.redrawTabs() redraws the tabs.
            
            % TODO
            
        end % redrawTabs
        
    end % helper methods
    
    methods( Access = private )
        
        function onTabClick( obj, source, ~ )
            
            % Update selection
            index = find( source == obj.Tabs );
            obj.Selection_ = index;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onTabClick
        
    end % event handlers
    
end % classdef