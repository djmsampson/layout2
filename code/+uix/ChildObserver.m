classdef ChildObserver < handle
    
    properties( SetAccess = private )
        Tree
    end
    
    properties( Access = private )
        Listeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        ChildAdded
        ChildRemoved
        BeingDestroyed
    end
    
    methods
        
        function obj = ChildObserver( object )
            %uix.ChildObserver
            
            % Create tree
            tree = uix.Node( object, @(x)~isequal(x,object)&&ishghandle(x) );
            
            % Add node listeners
            obj.addChildListeners( tree )
            
            % Store properties
            obj.Tree = tree;
            
            % Add object listener
            obj.Listeners(end+1,:) = event.listener( object, ...
                'ObjectBeingDestroyed', @obj.onBeingDestroyed );
            
        end % constructor
        
    end % structors
    
    methods( Access = protected )
        
        function onChildAdded( obj, ~, eventData )
            %onChildAdded  Event handler for event 'ChildAdded'
            
            % Add listeners
            obj.addChildListeners( eventData.Child )
            
            % Notify
            obj.notifyChildEvent( eventData.Child, 'ChildAdded' )
            
        end % onChildAdded
        
        function onChildRemoved( obj, ~, eventData )
            %onChildRemoved  Event handler for event 'ChildRemoved'
            
            % Raise event on children
            obj.notifyChildEvent( eventData.Child, 'ChildRemoved' )
            
        end % onChildRemoved
        
        function onHandleVisibilityChanged( obj, source, ~ )
            %onHandleVisibilityChanged  Event handler for event 'HandleVisibilityChanged'
            
            object = source.Object;
            switch object.HandleVisibility
                case 'on' % to visible
                    notify( obj, 'ChildAdded', uix.ChildEvent( object ) )
                case {'off','callback'} % to invisible
                    notify( obj, 'ChildRemoved', uix.ChildEvent( object ) )
            end
            
        end % onHandleVisibilityChanged
        
        function onBeingDestroyed( obj, ~, ~ )
            %onBeingDestroyed  Event handler for event 'ObjectBeingDestroyed'
            
            % Raise event
            notify( obj, 'BeingDestroyed' )
            
        end % onBeingDestroyed
        
    end % event handlers
    
    methods( Access = private )
        
        function addChildListeners( obj, node )
            %addChildListeners  Add listeners to node and its descendents
            
            % Add listeners to node
            addlistener( node, 'ChildAdded', @obj.onChildAdded );
            addlistener( node, 'ChildRemoved', @obj.onChildRemoved );
            addlistener( node, 'HandleVisibilityChanged', ...
                @obj.onHandleVisibilityChanged );
            
            % Add listeners to children
            children = node.Children;
            for ii = 1:numel( children )
                obj.addChildListeners( children(ii) )
            end
            
        end % addChildListeners
        
        function notifyChildEvent( obj, node, eventName )
            %notifyChildEvent  Raise child event(s)
            
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