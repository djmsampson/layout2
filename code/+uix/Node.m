classdef Node < handle
    
    properties( SetAccess = private )
        Object
        Children = uix.Node.empty( [0 1] )
    end
    
    properties( Access = private )
        ChildTerminator
        Listeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        ChildAdded
        ChildRemoved
        VisibilityChanged
        Deleted
    end
    
    methods
        
        function obj = Node( object, childTerminator )
            
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
                    @obj.onVisibilityChanged );
            end
            obj.Listeners(end+1,:) = event.listener( object, ...
                'ObjectBeingDestroyed', @obj.onDeleted );
            
            if ~childTerminator( object )
                
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
            
            child = eventData.Child;
            node = uix.Node( child, obj.ChildTerminator );
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