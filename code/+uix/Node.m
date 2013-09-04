classdef Node < handle
    
    properties( SetAccess = private )
        Object % the object
        Children = uix.Node.empty( [0 1] ) % nodes for children
    end
    
    properties( Access = private )
        ChildTerminator % termination test function
        Listeners = event.listener.empty( [0 1] ) % listeners
    end
    
    events( NotifyAccess = private )
        ChildAdded
        ChildRemoved
        HandleVisibilityChanged
        BeingDestroyed
    end
    
    methods
        
        function obj = Node( object, childTerminator )
            %uix.Node  Node
            
            % Handle inputs
            if nargin < 2, childTerminator = @(~)false; end
            
            % Create event source
            eventSource = uix.EventSource( object );
            
            % Store properties
            obj.Object = object;
            obj.ChildTerminator = childTerminator;
            
            % Add standard listeners
            if ishghandle( object )
                obj.Listeners(end+1,:) = event.proplistener( object, ...
                    findprop( object, 'HandleVisibility' ), 'PostSet', ...
                    @obj.onHandleVisibilityChanged );
            end
            obj.Listeners(end+1,:) = event.listener( object, ...
                'ObjectBeingDestroyed', @obj.onBeingDestroyed );
            
            if ~childTerminator( object ) % non-terminal node
                
                % Add existing children
                children = hgGetTrueChildren( object );
                for ii = 1:numel( children )
                    obj.Children(end+1,:) = uix.Node( children(ii), childTerminator );
                end
                
                % Add child listeners
                obj.Listeners(end+1,:) = event.listener( eventSource, ...
                    'ObjectChildAdded', @obj.onChildAdded );
                obj.Listeners(end+1,:) = event.listener( eventSource, ...
                    'ObjectChildRemoved', @obj.onChildRemoved );
                
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function onChildAdded( obj, ~, eventData )
            %onChildAdded  Event handler for event 'ObjectChildAdded'
            
            child = eventData.Child;
            node = uix.Node( child, obj.ChildTerminator );
            obj.Children(end+1,:) = node;
            notify( obj, 'ChildAdded', uix.ChildEvent( node ) )
            
        end % onChildAdded
        
        function onChildRemoved( obj, ~, eventData )
            %onChildRemoved  Event handler for event 'ObjectChildRemoved'
            
            child = eventData.Child;
            tf = vertcat( obj.Children.Object ) == child;
            node = obj.Children(tf,:);
            assert( isscalar( node ), 'uix:UnhandledError', 'Node not found.' )
            obj.Children(tf,:) = [];
            notify( obj, 'ChildRemoved', uix.ChildEvent( node ) )
            
        end % onChildRemoved
        
        function onBeingDestroyed( obj, ~, ~ )
            %onBeingDestroyed  Event handler for event 'ObjectBeingDestroyed'
            
            notify( obj, 'BeingDestroyed' )
            
        end % onBeingDestroyed
        
        function onHandleVisibilityChanged( obj, ~, ~ )
            %onHandleVisibilityChanged  Event handler for property 'HandleVisibility'
            
            notify( obj, 'HandleVisibilityChanged' )
            
        end % onHandleVisibilityChanged
        
    end % event handlers
    
end % classdef