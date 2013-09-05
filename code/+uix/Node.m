classdef Node < handle
    
    properties( SetAccess = private )
        Object % the object
        Children = uix.Node.empty( [0 1] ) % nodes for children
    end
    
    properties( Access = private )
        OldHandleVisibility % previous value of HandleVisibility
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
        
        function obj = Node( object, isTerminalChild )
            %uix.Node  Node
            %
            %  n = uix.Node(o,f) creates a node from an object o and a
            %  termination test function f.
            
            % Handle inputs
            if nargin < 2, isTerminalChild = @(~)false; end
            
            % Create event source
            eventSource = uix.EventSource.getInstance( object ); % TODO
            
            % Store properties
            obj.Object = object;
            obj.ChildTerminator = isTerminalChild;
            
            % Add standard listeners
            if ishghandle( object )
                obj.Listeners(end+1,:) = event.proplistener( object, ...
                    findprop( object, 'HandleVisibility' ), 'PreSet', ...
                    @obj.onHandleVisibilityPreSet );
                obj.Listeners(end+1,:) = event.proplistener( object, ...
                    findprop( object, 'HandleVisibility' ), 'PostSet', ...
                    @obj.onHandleVisibilityPostSet );
            end
            obj.Listeners(end+1,:) = event.listener( object, ...
                'ObjectBeingDestroyed', @obj.onBeingDestroyed );
            
            if ~isTerminalChild( object ) % non-terminal node
                
                % Add existing children
                children = hgGetTrueChildren( object );
                for ii = 1:numel( children )
                    obj.Children(end+1,:) = uix.Node( children(ii), isTerminalChild );
                end
                
                % Add child listeners
                obj.Listeners(end+1,:) = event.listener( eventSource, ...
                    'ObjectChildAdded', @obj.onChildAdded ); % TODO
                obj.Listeners(end+1,:) = event.listener( eventSource, ...
                    'ObjectChildRemoved', @obj.onChildRemoved ); % TODO
                
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
        
        function onHandleVisibilityPreSet( obj, ~, eventData )
            %onHandleVisibilityPreSet  Event handler for property 'HandleVisibility'
            
            % Store previous value
            obj.OldHandleVisibility = eventData.AffectedObject.HandleVisibility;
            
        end % onHandleVisibilityPreSet
        
        function onHandleVisibilityPostSet( obj, ~, eventData )
            %onHandleVisibilityPostSet  Event handler for property 'HandleVisibility'
            
            % Raise event if HandleVisibility changed from 'on' to 'off' or
            % 'callback', or vice versa
            old = obj.OldHandleVisibility;
            new = eventData.AffectedObject.HandleVisibility;
            if xor( strcmp( old, 'on' ), strcmp( new, 'on' ) )
                notify( obj, 'HandleVisibilityChanged' )
            end
            obj.OldHandleVisibility = []; % reset
            
        end % onHandleVisibilityPostSet
        
    end % event handlers
    
end % classdef