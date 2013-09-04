classdef Node < handle
    
    properties( SetAccess = protected )
        Object
        Children = uix.Node.empty( [0 1] )
    end
    
    properties( Access = protected )
        Listeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = protected )
        ChildAdded
        ChildRemoved
        Deleted
    end
    
    methods
        
        function obj = Node( object )
            
            % Create peer
            eventSource = uix.EventSource( object );
            
            % Store properties
            obj.Object = object;
            
            % Add existing children
            children = hgGetTrueChildren( object );
            for ii = 1:numel( children )
                obj.Children(end+1,:) = uix.Node( children(ii) );
            end
            
            % Add listeners
            obj.Listeners(end+1,:) = event.listener( eventSource, ...
                'ObjectChildAdded', @obj.onChildAdded );
            obj.Listeners(end+1,:) = event.listener( eventSource, ...
                'ObjectChildRemoved', @obj.onChildRemoved );
            obj.Listeners(end+1,:) = event.listener( eventSource, ...
                'ObjectDeleted', @obj.onDeleted );
            
        end % constructor
        
    end % structors
    
    methods
        
        function onChildAdded( obj, ~, eventData )
            
            child = eventData.Child;
            node = uix.Node( child );
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
        
    end % event handlers
    
end % classdef