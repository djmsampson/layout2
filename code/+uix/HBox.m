classdef HBox < uix.Container
    
    properties
        Padding = 0
        Spacing = 0
    end
    
    properties( Access = public, Dependent )
        Widths
        MinimumWidths
    end
    
    properties( Hidden, Access = public, Dependent )
        Sizes
        MinimumSizes
    end
    
    properties( Access = private )
        Widths_ = zeros( [0 1] )
        MinimumWidths_ = zeros( [0 1] )
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
        
        function set.Padding( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Padding'' must be a non-negative scalar.' )
            
            % Set
            obj.Padding = value;
            
            % Redraw
            obj.redraw()
            
        end % set.Padding
        
        function set.Spacing( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Spacing'' must be a non-negative scalar.' )
            
            % Set
            obj.Spacing = value;
            
            % Redraw
            obj.redraw()
            
        end % set.Spacing
        
        function value = get.Widths( obj )
            
            value = obj.Widths_;
            
        end % get.Widths
        
        function set.Widths( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Widths'' must be of type double.' )
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
                'Elements of property ''MinimumWidths'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''MinimumWidths'' must be real and finite.' )
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
        
        function redraw( obj )
            
            % Abort for parentless containers
            if isempty( obj.Parent ), return, end
            
            % Compute positions
            pTotal = hgconvertunits( ancestor( obj, 'figure' ), ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            mWidths = obj.Widths_;
            sz = size( mWidths );
            pMinimumWidths = obj.MinimumWidths_;
            pPadding = obj.Padding;
            pSpacing = obj.Spacing;
            pXPositions = uix.getPixelPositions( pTotal(3), mWidths, ...
                pMinimumWidths, pPadding, pSpacing );
            pYPositions = repmat( [pPadding, max( pTotal(4) - 2 * pPadding, 1 )], sz );
            pPositions = [pXPositions(:,1), pYPositions(:,1), ...
                pXPositions(:,2), pYPositions(:,2)];
            
            % Set positions
            for ii = 1:size( mWidths, 1 )
                child = obj.Contents(ii);
                child.Units = 'pixels';
                if isprop( child, 'ActivePositionProperty' )
                    child.( child.ActivePositionProperty ) = pPositions(ii,:);
                else
                    child.Position = pPositions(ii,:);
                end
            end
            
        end % redraw
        
    end % protected methods
    
    methods( Access = protected )
        
        function onChildAdded( obj, source, eventData )
            
            % Add to sizes
            obj.Widths_(end+1,:) = -1;
            obj.MinimumWidths_(end+1,:) = 1;
            
            % Call superclass method
            onChildAdded@uix.Container( obj, source, eventData )
            
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData )
            
            % Do nothing if container is being deleted
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            % Remove from sizes
            tf = obj.Contents_ == eventData.Child;
            obj.Widths_(tf,:) = [];
            
            % Call superclass method
            onChildRemoved@uix.Container( obj, source, eventData )
            
        end % onChildRemoved
        
    end % event handlers
    
end % classdef