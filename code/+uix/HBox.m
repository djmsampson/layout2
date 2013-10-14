classdef HBox < uix.Container
    
    properties( Access = public, Dependent )
        Padding = 0 % space around contents, in pixels
        Spacing = 0 % space between contents, in pixels
        Widths % widths of contents, in pixels and/or weights
        MinimumWidths % minimum widths of contents, in pixels
    end
    
    properties( Hidden, Access = public, Dependent )
        Sizes % deprecated
        MinimumSizes % deprecated
    end
    
    properties( Access = protected )
        Padding_ = 0 % backing for Padding
        Spacing_ = 0 % backing for Spacing
        Widths_ = zeros( [0 1] ) % backing for Widths
        MinimumWidths_ = zeros( [0 1] ) % backing for MinimumWidths
    end
    
    properties( Access = private )
        ActivePositionPropertyListeners = cell( [0 1] )
    end
    
    methods
        
        function obj = HBox( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.Container( notmypv{:} );
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Padding( obj )
            
            value = obj.Padding_;
            
        end % get.Padding
        
        function set.Padding( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Padding'' must be a non-negative scalar.' )
            
            % Set
            obj.Padding_ = value;
            
            % Redraw
            obj.redraw()
            
        end % set.Padding
        
        function value = get.Spacing( obj )
            
            value = obj.Spacing_;
            
        end % get.Spacing
        
        function set.Spacing( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Spacing'' must be a non-negative scalar.' )
            
            % Set
            obj.Spacing_ = value;
            
            % Redraw
            obj.redraw()
            
        end % set.Spacing
        
        function value = get.Widths( obj )
            
            value = obj.Widths_;
            
        end % get.Widths
        
        function set.Widths( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Widths'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Widths'' must be real and finite.' )
            assert( isequal( size( obj.Contents_ ), size( value ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''Widths'' must match size of contents.' )
            
            % Abort set
            if isequal( obj.Widths_, value ), return, end
            
            % Set
            obj.Widths_ = value;
            
            % Redraw
            obj.redraw()
            
        end % set.Widths
        
        function value = get.MinimumWidths( obj )
            
            value = obj.MinimumWidths_;
            
        end % get.MinimumWidths
        
        function set.MinimumWidths( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''MinimumWidths'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                all( value >= 0 ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''MinimumWidths'' must be non-negative.' )
            assert( isequal( size( obj.Contents_ ), size( value ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''MinimumWidths'' must match size of contents.' )
            
            % Abort set
            if isequal( obj.MinimumWidths_, value ), return, end
            
            % Set
            obj.MinimumWidths_ = value;
            
            % Redraw
            obj.redraw()
            
        end % set.MinimumWidths
        
        function value = get.Sizes( obj )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''Sizes'' is deprecated.  Use ''Widths'' instead.' )
            
            % Get
            value = obj.Widths;
            
        end % get.Sizes
        
        function set.Sizes( obj, value )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''Sizes'' is deprecated.  Use ''Widths'' instead.' )
            
            % Get
            obj.Widths = value;
            
        end % set.Sizes
        
        function value = get.MinimumSizes( obj )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''MinimumSizes'' is deprecated.  Use ''MinimumWidths'' instead.' )
            
            % Get
            value = obj.MinimumWidths;
            
        end % get.MinimumSizes
        
        function set.MinimumSizes( obj, value )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''MinimumSizes'' is deprecated.  Use ''MinimumWidths'' instead.' )
            
            % Get
            obj.MinimumWidths = value;
            
        end % set.MinimumSizes
        
    end % accessors
    
    methods( Access = protected )
        
        function onActivePositionPropertyChange( obj, ~, ~ )
            
            % Redraw
            obj.redraw()
            
        end % onActivePositionPropertyChange
        
    end % event handlers
    
    methods( Access = protected )
        
        function redraw( obj )
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            widths = obj.Widths_;
            minimumWidths = obj.MinimumWidths_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            xPositions = uix.calcPixelPositions( bounds(3), widths, ...
                minimumWidths, padding, spacing );
            yPositions = [padding + 1, max( bounds(4) - 2 * padding, 1 )];
            yPositions = repmat( yPositions, size( widths ) );
            positions = [xPositions(:,1), yPositions(:,1), ...
                xPositions(:,2), yPositions(:,2)];
            
            % Set positions
            obj.reposition( positions );
            
        end % redraw
        
        function addChild( obj, child )
            
            % Add to sizes
            obj.Widths_(end+1,:) = -1;
            obj.MinimumWidths_(end+1,:) = 1;
            
            % Call superclass method
            addChild@uix.Container( obj, child )
            
            % Add listeners
            if isa( child, 'matlab.graphics.axis.Axes' )
                obj.ActivePositionPropertyListeners{end+1,:} = ...
                    event.proplistener( child, ...
                    findprop( child, 'ActivePositionProperty' ), ...
                    'PostSet', @obj.onActivePositionPropertyChange );
            else
                obj.ActivePositionPropertyListeners{end+1,:} = [];
            end
            
        end % onChildAdded
        
        function removeChild( obj, child )
            
            % Remove from sizes
            tf = obj.Contents_ == child;
            obj.Widths_(tf,:) = [];
            obj.MinimumWidths_(tf,:) = [];
            
            % Call superclass method
            removeChild@uix.Container( obj, child )
            
            % Remove listeners
            obj.ActivePositionPropertyListeners(tf,:) = [];
            
        end % onChildRemoved
        
        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).
            
            % Reorder
            obj.Widths_ = obj.Widths_(indices,:);
            obj.MinimumWidths_ = obj.MinimumWidths_(indices,:);
            obj.ActivePositionPropertyListeners = ...
                obj.ActivePositionPropertyListeners(indices,:);
            
            % Call superclass method
            reorder@uix.Container( obj, indices )
            
        end % reorder
        
        function reposition( obj, positions )
            
            children = obj.Contents_;
            for ii = 1:numel( children )
                child = children(ii);
                child.Units = 'pixels';
                if isa( child, 'matlab.graphics.axis.Axes' )
                    child.( child.ActivePositionProperty ) = positions(ii,:);
                else
                    child.Position = positions(ii,:);
                end
            end
            
        end % reposition
        
    end % template methods
    
end % classdef