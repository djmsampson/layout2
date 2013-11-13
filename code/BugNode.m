classdef BugNode < handle
    
    properties( SetAccess = private )
        Object % object
        Children = BugNode.empty( [0 1] ) % children
    end
    
    properties( Access = private )
        Listeners = event.listener.empty( [0 1] ) % external listeners
        ChildListeners = event.listener.empty( [0 1] ) % internal listeners
    end
    
    methods
        
        function obj = BugNode( object )
            
            obj.Object = object;
            
        end % constructor
        
        function addChild( obj, child )
            
            childListener = event.listener( child, ...
                'ObjectBeingDestroyed', @obj.onChildDeleted );
            obj.Children(end+1,:) = child;
            obj.ChildListeners(end+1,:) = childListener;
            
        end % add
        
        function addListener( obj, listener )
            
            obj.Listeners(end+1,:) = listener;
            
        end % addListener
        
    end % public methods
    
end % classdef