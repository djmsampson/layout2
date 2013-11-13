classdef Vanilla < matlab.ui.container.internal.UIContainer
    
    properties( Dependent, GetAccess = public, SetAccess = private )
        Contents
    end
    
    properties( Access = protected )
        Contents_ = gobjects( [0 1] ) % backing for Contents
    end
    
    properties( Access = private )
        ChildObserver
        ChildAddedListener
        ChildRemovedListener
    end
    
    methods
        
        function obj = Vanilla()
            
            % Call superclass constructor
            obj@matlab.ui.container.internal.UIContainer()
            
            % Create observers and listeners
            childObserver = uix.ChildObserver( obj );
            childAddedListener = event.listener( ...
                childObserver, 'ChildAdded', @obj.onChildAdded );
            childRemovedListener = event.listener( ...
                childObserver, 'ChildRemoved', @obj.onChildRemoved );
            
            % Store observers and listeners
            obj.ChildObserver = childObserver;
            obj.ChildAddedListener = childAddedListener;
            obj.ChildRemovedListener = childRemovedListener;
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Contents( obj )
            
            value = obj.Contents_;
            
        end % get.Contents
        
    end % accessors
    
    methods( Access = private, Sealed )
        
        function onChildAdded( obj, ~, eventData )
            
            % Call template method
            obj.addChild( eventData.Child )
            
        end % onChildAdded
        
        function onChildRemoved( obj, ~, eventData )
            
            % Do nothing if container is being deleted
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            % Call template method
            obj.removeChild( eventData.Child )
            
        end % onChildRemoved
        
    end % event handlers
    
    methods( Access = protected )
        
        function addChild( obj, child )
            
            % Add to contents
            obj.Contents_(end+1,1) = child;
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Remove from contents
            contents = obj.Contents_;
            tf = contents == child;
            obj.Contents_(tf,:) = [];
            
        end % removeChild
        
        function redraw( obj )
            
        end % redraw
        
    end % template methods
    
end % classdef