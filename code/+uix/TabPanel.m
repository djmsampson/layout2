classdef TabPanel < uix.Container
    
    properties( Access = public, Dependent, AbortSet )
        Selection % selected contents
        TabEnable % tab enable states
        TabLocation % tab location [top|bottom]
        TabNames % tab names
    end
    
    properties( Access = protected )
        Selection_ = 0 % backing for Selection
        Tabs = gobjects( [0 1] ) % tabs
        TabListeners = event.listener.empty( [0 1] ) % tab listeners
        TabLocation_ = 'top' % backing for TabPosition
        TabHeight_ = 0 % cache of tab height
        TabWidth_ = 50 % backing for TabWidth
    end
    
    methods
        
        function obj = TabPanel( varargin )
            
            % Call superclass constructor
            obj@uix.Container()
            
            % Set properties
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
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
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj ); % TODO
            location = bounds;
            w = ceil( location(1) + location(3) ) - floor( location(1) );
            h = ceil( location(2) + location(4) ) - floor( location(2) );
            p = obj.Padding_;
            tabs = obj.Tabs;
            tH = obj.TabHeight_;
            cH = max( [h - 2 * p - tH, 1] );
            switch obj.TabLocation_
                case 'top'
                    cY = 1 + p;
                    tY = cY + cH + 1;
                case 'bottom'
                    tY = 1 + p;
                    cY = tY + tH + 1;
            end
            cX = 1 + p;
            cW = max( [w - 2 * p, 1] );
            tW = obj.TabWidth_;
            for ii = 1:numel( tabs )
                tab = tabs(ii);
                tabPosition = [1 + (ii-1) * tW, tY, tW, tH];
                tab.Position = tabPosition;
            end
            contentsPosition = [cX cY cW cH];
            
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
                'Units', 'pixels' );
            tabListener = event.listener( tab, 'ButtonDown', @obj.onTabClick );
            n = numel( obj.Tabs );
            obj.Tabs(n+1,:) = tab;
            obj.TabListeners(n+1,:) = tabListener;
            
            % Select new content
            if obj.Selection_ == 0
                obj.Selection_ = n + 1;
            end
            
            % Update tab height
            if n > 0
                cTabExtents = get( obj.Tabs, {'Extent'} );
                tabExtents = vertcat( cTabExtents{:} );
                obj.TabHeight_ = max( tabExtents(:,4) );
            end
            
            % Call superclass method
            addChild@uix.Container( obj, child )
            
        end % addChild
        
        function removeChild( obj, child ) % TODO
            
            % Find index of removed child
            contents = obj.Contents_;
            index = find( contents == child );
            
            % Remove tab
            delete( obj.Tabs(index) )
            obj.Tabs(index,:) = [];
            obj.TabListeners(index,:) = [];
            
            % Adjust selection if required
            selection = obj.Selection_;
            n = numel( contents );
            if index == 1 && selection == 1 && n > 1
                % retain selection
            elseif index <= selection
                obj.Selection_ = selection - 1;
            else
                % retain selection
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
        
    end % template methods
    
    methods
        
        function onTabClick( obj, source, ~ )
            
            % Update selection
            index = find( source == obj.Tabs );
            obj.Selection_ = index;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onTabClick
        
    end % event handlers
    
end % classdef