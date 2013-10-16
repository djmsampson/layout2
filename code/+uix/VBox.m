classdef VBox < uix.Box
    
    properties( Access = public, Dependent, AbortSet )
        Heights % heights of contents, in pixels and/or weights
        MinimumHeights % minimum heights of contents, in pixels
    end
    
    properties( Hidden, Access = public, Dependent )
        Sizes % deprecated
        MinimumSizes % deprecated
    end
    
    properties( Access = protected )
        Heights_ = zeros( [0 1] ) % backing for Heights
        MinimumHeights_ = zeros( [0 1] ) % backing for MinimumHeights
    end
    
    methods
        
        function obj = VBox( varargin )
            
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
        
        function value = get.Heights( obj )
            
            value = obj.Heights_;
            
        end % get.Heights
        
        function set.Heights( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Heights'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Heights'' must be real and finite.' )
            if isequal( size( value ), size( obj.Contents_ ) )
                % OK
            elseif isequal( size( value' ), size( obj.Contents_ ) )
                % Warn and transpose
                warning( 'uix:InvalidPropertyValue', ...
                    'Size of property ''Heights'' must match size of contents.' )
                value = value';
            else
                % Error
                error( 'uix:InvalidPropertyValue', ...
                    'Size of property ''Heights'' must match size of contents.' )
            end
            
            % Set
            obj.Heights_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Heights
        
        function value = get.MinimumHeights( obj )
            
            value = obj.MinimumHeights_;
            
        end % get.MinimumHeights
        
        function set.MinimumHeights( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''MinimumHeights'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                all( value >= 0 ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''MinimumHeights'' must be non-negative.' )
            if isequal( size( value ), size( obj.Heights_ ) )
                % OK
            elseif isequal( size( value' ), size( obj.Heights_ ) )
                % Warn and transpose
                warning( 'uix:InvalidPropertyValue', ...
                    'Size of property ''MinimumHeights'' must match size of contents.' )
                value = value';
            else
                % Error
                error( 'uix:InvalidPropertyValue', ...
                    'Size of property ''MinimumHeights'' must match size of contents.' )
            end
            
            % Set
            obj.MinimumHeights_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.MinimumHeights
        
        function value = get.Sizes( obj )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''Sizes'' is deprecated.  Use ''Heights'' instead.' )
            
            % Get
            value = obj.Heights;
            
        end % get.Sizes
        
        function set.Sizes( obj, value )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''Sizes'' is deprecated.  Use ''Heights'' instead.' )
            
            % Get
            obj.Heights = value;
            
        end % set.Sizes
        
        function value = get.MinimumSizes( obj )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''MinimumSizes'' is deprecated.  Use ''MinimumHeights'' instead.' )
            
            % Get
            value = obj.MinimumHeights;
            
        end % get.MinimumSizes
        
        function set.MinimumSizes( obj, value )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''MinimumSizes'' is deprecated.  Use ''MinimumHeights'' instead.' )
            
            % Get
            obj.MinimumHeights = value;
            
        end % set.MinimumSizes
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            heights = obj.Heights_;
            minimumHeights = obj.MinimumHeights_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            n = numel( heights );
            xPositions = [padding + 1, max( bounds(3) - 2 * padding, 1 )];
            xPositions = repmat( xPositions, [n 1] );
            ySizes = uix.calcPixelSizes( bounds(4), heights, ...
                minimumHeights, padding, spacing );
            yPositions = [bounds(4) - cumsum( ySizes ) - padding - ...
                spacing * transpose( 0:n-1 ) + 1, ySizes];
            positions = [xPositions(:,1), yPositions(:,1), ...
                xPositions(:,2), yPositions(:,2)];
            
            % Set positions
            obj.reposition( positions );
            
        end % redraw
        
        function addChild( obj, child )
            
            % Add to sizes
            obj.Heights_(end+1,:) = -1;
            obj.MinimumHeights_(end+1,:) = 1;
            
            % Call superclass method
            addChild@uix.Box( obj, child )
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Remove from sizes
            tf = obj.Contents_ == child;
            obj.Heights_(tf,:) = [];
            obj.MinimumHeights_(tf,:) = [];
            
            % Call superclass method
            removeChild@uix.Box( obj, child )
            
        end % onChildRemoved
        
        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).
            
            % Reorder
            obj.Heights_ = obj.Heights_(indices,:);
            obj.MinimumHeights_ = obj.MinimumHeights_(indices,:);
            
            % Call superclass method
            reorder@uix.Box( obj, indices )
            
        end % reorder
        
    end % template methods
    
end % classdef