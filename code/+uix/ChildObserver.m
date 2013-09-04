classdef ChildObserver < handle
    
    properties( SetAccess = private )
        Tree
    end
    
    events( NotifyAccess = private )
        ChildAdded
        ChildRemoved
    end
    
    methods
        
        function obj = ChildObserver( o )
            
            % Create tree
            tree = uix.Node( o, @(x)~isequal(x,o)&&ishghandle(x) );
            
            % Add listeners
            obj.addChildListeners( tree )
            
            % Store properties
            obj.Tree = tree;
            
        end % constructor
        
    end % structors
    
    methods( Access = protected )
        
        function onChildAdded( obj, ~, eventData )
            
            % Add listeners
            obj.addChildListeners( eventData.Child )
            
            % Notify
            obj.notifyChildEvent( eventData.Child, 'ChildAdded' )
            
        end % onChildAdded
        
        function onChildRemoved( obj, ~, eventData )
            
            % Raise event on children
            obj.notifyChildEvent( eventData.Child, 'ChildRemoved' )
            
        end % onChildRemoved
        
        function onVisibilityChanged( obj, source, ~ )
            
            object = source.Object;
            switch object.HandleVisibility
                case 'on'
                    notify( obj, 'ChildAdded', uix.ChildEvent( object ) )
                case {'off','callback'}
                    notify( obj, 'ChildRemoved', uix.ChildEvent( object ) )
            end
            
        end % onVisibilityChanged
        
    end % event handlers
    
    methods( Access = private )
        
        function addChildListeners( obj, node )
            
            % Add listeners to node
            addlistener( node, 'ChildAdded', @obj.onChildEvent );
            addlistener( node, 'ChildRemoved', @obj.onChildEvent );
            addlistener( node, 'VisibilityChanged', @obj.onVisibilityChanged );
            
            % Add listeners to children
            children = node.Children;
            for ii = 1:numel( children )
                obj.addChildListeners( children(ii) )
            end
            
        end % addChildListeners
        
        function notifyChildEvent( obj, node, eventName )
            
            % Raise event on node
            object = node.Object;
            if ishghandle( object ) && strcmp( object.HandleVisibility, 'on' )
                notify( obj, eventName, uix.ChildEvent( object ) )
            end
            
            % Raise event on children
            children = node.Children;
            for ii = 1:numel( children )
                obj.notifyChildEvent( children(ii), eventName )
            end
            
        end % notifyChildEvent
        
    end % helpers
    
end % classdef