classdef AbstractNode < handle & matlab.mixin.Heterogeneous
    
    properties( SetAccess = protected )
        Object
        Children
    end
    
    properties( Access = protected )
        NodeFactory
        Listeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = protected )
        ChildAdded
        ChildRemoved
        VisibilityChanged
        Deleted
    end
    
    methods
        
        function onChildAdded( obj, ~, eventData )
            
            child = eventData.Child;
            node = obj.NodeFactory.createNode( child );
            obj.Children(end+1,:) = node;
            notify( obj, 'ChildAdded', uix.ChildEvent( node ) )
            
        end % onChildAdded
        
        function onChildRemoved( obj, ~, eventData )
            
            child = eventData.Child;
            tf = vertcat( obj.Children.Object ) == child;
            node = obj.Children(tf,:);
            assert( numel( node ) == 1 )
            obj.Children(tf,:) = [];
            notify( obj, 'ChildRemoved', uix.ChildEvent( node ) )
            
        end % onChildRemoved
        
        function onDeleted( obj, ~, ~ )
            
            notify( obj, 'Deleted' )
            
        end % onDeleted
        
        function onVisibilityChanged( obj, ~, ~ )
            
            notify( obj, 'VisibilityChanged' )
            
        end % onVisibilityChanged
        
    end % event handlers
    
end % classdef