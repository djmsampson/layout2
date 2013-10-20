classdef HBox < uix.Box
    
    properties( Access = public, Dependent, AbortSet )
        Widths % widths of contents, in pixels and/or weights
        MinimumWidths % minimum widths of contents, in pixels
    end
    
    properties( Hidden, Access = public, Dependent )
        Sizes % deprecated
        MinimumSizes % deprecated
    end
    
    properties( Access = protected )
        Widths_ = zeros( [0 1] ) % backing for Widths
        MinimumWidths_ = zeros( [0 1] ) % backing for MinimumWidths
    end
    
    methods
        
        function obj = HBox( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.Box( notmypv{:} );
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
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
            if isequal( size( value ), size( obj.Contents_ ) )
                % OK
            elseif isequal( size( value' ), size( obj.Contents_ ) )
                % Warn and transpose
                warning( 'uix:InvalidPropertyValue', ...
                    'Size of property ''Widths'' must match size of contents.' )
                value = value';
            else
                % Error
                error( 'uix:InvalidPropertyValue', ...
                    'Size of property ''Widths'' must match size of contents.' )
            end
            
            % Set
            obj.Widths_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
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
            if isequal( size( value ), size( obj.Widths_ ) )
                % OK
            elseif isequal( size( value' ), size( obj.Widths_ ) )
                % Warn and transpose
                warning( 'uix:InvalidPropertyValue', ...
                    'Size of property ''MinimumWidths'' must match size of contents.' )
                value = value';
            else
                % Error
                error( 'uix:InvalidPropertyValue', ...
                    'Size of property ''MinimumWidths'' must match size of contents.' )
            end
            
            % Set
            obj.MinimumWidths_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
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
        
        function redraw( obj )
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            widths = obj.Widths_;
            minimumWidths = obj.MinimumWidths_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            n = numel( widths );
            xSizes = uix.calcPixelSizes( bounds(3), widths, ...
                minimumWidths, padding, spacing );
            xPositions = [cumsum( [0; xSizes(1:end-1,:)] ) + padding + ...
                spacing * transpose( 0:n-1 ) + 1, xSizes];
            yPositions = [padding + 1, max( bounds(4) - 2 * padding, 1 )];
            yPositions = repmat( yPositions, [n 1] );
            positions = [xPositions(:,1), yPositions(:,1), ...
                xPositions(:,2), yPositions(:,2)];
            
            % Set positions
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
            
        end % redraw
        
        function addChild( obj, child )
            
            % Add to sizes
            obj.Widths_(end+1,:) = -1;
            obj.MinimumWidths_(end+1,:) = 1;
            
            % Call superclass method
            addChild@uix.Box( obj, child )
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Remove from sizes
            tf = obj.Contents_ == child;
            obj.Widths_(tf,:) = [];
            obj.MinimumWidths_(tf,:) = [];
            
            % Call superclass method
            removeChild@uix.Box( obj, child )
            
        end % onChildRemoved
        
        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).
            
            % Reorder
            obj.Widths_ = obj.Widths_(indices,:);
            obj.MinimumWidths_ = obj.MinimumWidths_(indices,:);
            
            % Call superclass method
            reorder@uix.Box( obj, indices )
            
        end % reorder
        
    end % template methods
    
end % classdef