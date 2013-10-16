classdef Box < uix.Container
    
    properties( Access = public, Dependent, AbortSet )
        Padding = 0 % space around contents, in pixels
        Spacing = 0 % space between contents, in pixels
    end
    
    properties( Access = protected )
        Padding_ = 0 % backing for Padding
        Spacing_ = 0 % backing for Spacing
    end
    
    properties( Access = private )
        ActivePositionPropertyListeners = cell( [0 1] )
    end
    
    methods
        
        function obj = Box( varargin )
            
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
            
            % Mark as dirty
            obj.Dirty = true;
            
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
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Spacing
        
    end % accessors
    
    methods( Access = protected )
        
        function onActivePositionPropertyChange( obj, ~, ~ )
            
            % Mark as dirty
            obj.Dirty = true;
            
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