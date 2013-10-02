classdef Container < matlab.ui.container.internal.UIContainer
    
    properties( Dependent, Access = public )
        Contents
    end
    
    properties( Access = protected )
        Contents_ = matlab.graphics.GraphicsPlaceholder.empty( [0 1] )
        Listeners = event.listener.empty( [0 1] )
    end
    
    methods
        
        function obj = Container( varargin )
            
            % Call superclass constructor
            obj@matlab.ui.container.internal.UIContainer( varargin{:} );
            
            % Create child listeners
            childObserver = uix.ChildObserver( obj );
            childAddedListener = event.listener( ...
                childObserver, 'ChildAdded', @obj.onChildAdded );
            childRemovedListener = event.listener( ...
                childObserver, 'ChildRemoved', @obj.onChildRemoved );
            
            % Create resize listener
            sizeChangeListener = event.listener( ...
                obj, 'SizeChange', @obj.onSizeChanged );
            
            % Store listeners
            obj.Listeners = [childAddedListener; childRemovedListener; ...
                sizeChangeListener];
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Contents( obj )
            
            value = obj.Contents_;
            
        end % get.Contents
        
        function set.Contents( obj, value )
            
            % Check
            [tf, indices] = ismember( obj.Contents_, value );
            assert( isequal( size( obj.Contents_ ), size( value ) ) && ...
                numel( value ) == numel( unique( value ) ) && all( tf ), ...
                'uix:InvalidOperation', ...
                'Property ''Contents'' may only be set to a permutation of itself.' )
            
            % Call reorder
            obj.reorder( indices )
            
        end % set.Contents
        
    end % accessors
    
    methods( Abstract, Access = protected )
        
        redraw( obj )
        
    end % protected methods
    
    methods( Access = protected )
        
        function onChildAdded( obj, ~, eventData )
            
            % Add to contents
            obj.Contents_(end+1,1) = eventData.Child;
            
            % Call redraw
            obj.redraw()
            
        end % onChildAdded
        
        function onChildRemoved( obj, ~, eventData )
            
            % Do nothing if container is being deleted
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            % Remove from contents
            obj.Contents_(obj.Contents_==eventData.Child,:) = [];
            
            % Call redraw
            obj.redraw()
            
        end % onChildRemoved
        
        function onSizeChanged( obj, ~, ~ )
            
            % Call redraw
            obj.redraw()
            
        end % onSizeChanged
        
    end % event handlers
    
    methods( Access = protected )
        
        function reorder( obj, indices )
            
            % Reorder
            obj.Contents_ = obj.Contents_(indices,:);
            
            % Redraw
            obj.redraw()
            
        end % reorder
        
    end % operations
    
end % classdef