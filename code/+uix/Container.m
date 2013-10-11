classdef Container < matlab.ui.container.internal.UIContainer
    
    properties( Dependent, Access = public )
        Contents
    end
    
    properties( Access = protected )
        Contents_ = matlab.graphics.GraphicsPlaceholder.empty( [0 1] )
        ChildAddedListener
        ChildRemovedListener
        SizeChangeListener
    end
    
    methods
        
        function obj = Container( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@matlab.ui.container.internal.UIContainer( notmypv{:} );
            
            % Create child listeners
            childObserver = uix.ChildObserver( obj );
            childAddedListener = event.listener( ...
                childObserver, 'ChildAdded', @obj.onChildAdded );
            childRemovedListener = event.listener( ...
                childObserver, 'ChildRemoved', @obj.onChildRemoved );
            
            % Create resize listener
            sizeChangeListener = event.listener( ...
                obj, 'SizeChange', @obj.onSizeChange );
            
            % Store listeners
            obj.ChildAddedListener = childAddedListener;
            obj.ChildRemovedListener = childRemovedListener;
            obj.SizeChangeListener = sizeChangeListener;
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
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
            
            % Redraw
            obj.redraw()
            
        end % set.Contents
        
    end % accessors
    
    methods( Access = private, Sealed )
        
        function onChildAdded( obj, ~, eventData )
            
            % Add child
            obj.addChild( eventData.Child )
            
            % Redraw
            obj.redraw()
            
        end % onChildAdded
        
        function onChildRemoved( obj, ~, eventData )
            
            % Do nothing if container is being deleted
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            % Remove child
            obj.removeChild( eventData.Child )
            
            % Redraw
            obj.redraw()
            
        end % onChildRemoved
        
        function onSizeChange( obj, ~, ~ )
            
            % Call redraw
            obj.redraw()
            
        end % onSizeChange
        
    end % event handlers
    
    methods( Access = protected, Sealed )
        
        function redraw( obj )
            %redraw  Request redraw
            
            % Redraw
            obj.redrawnow()
            
        end % redraw
        
    end % protected methods
    
    methods( Abstract, Access = protected )
        
        redrawnow( obj )
        
    end % abstract template methods
    
    methods( Access = protected )
        
        function addChild( obj, child )
            
            % Add to contents
            obj.Contents_(end+1,1) = child;
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Remove from contents
            obj.Contents_(obj.Contents_==child) = [];
            
        end % removeChild
        
        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).
            
            % Reorder
            obj.Contents_ = obj.Contents_(indices,:);
            
        end % reorder
        
    end % template methods
    
end % classdef