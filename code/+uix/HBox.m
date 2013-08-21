classdef HBox < uix.Container
    
    properties
        Padding = 0
    end
    
    properties( Access = public, Dependent )
        Sizes
    end
    
    properties( Access = private )
        Sizes_ = zeros( [0 1] )
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
        
        function value = get.Sizes( obj )
            
            value = obj.Sizes_;
            
        end % get.Sizes
        
        function set.Sizes( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Sizes'' must be a column vector.' )
            assert( isequal( size( obj.Contents_ ), size( value ) ), ...
                'uix:InvalidPropertyValue', 'Invalid operation.' )
            
            % Abort set
            if isequal( obj.Sizes_, value ), return, end
            
            % Set
            obj.Sizes_ = value;
            
            % Redraw
            obj.redraw()
            
        end % set.Sizes
        
    end % accessors
    
    methods( Access = protected )
        
        function onChildAdded( obj, source, eventData )
            
            % Add to sizes
            obj.Sizes_(end+1,:) = -1;
            
            % Call superclass method
            onChildAdded@uix.Container( obj, source, eventData )
            
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData )
            
            % Do nothing if container is being deleted
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            % Remove from sizes
            obj.Sizes_(find( obj.Contents_ == eventData.Child ),:) = []; %#ok<FNDSB>
            
            % Call superclass method
            onChildRemoved@uix.Container( obj, source, eventData )
            
        end % onChildRemoved
        
    end % event handlers
    
end % classdef