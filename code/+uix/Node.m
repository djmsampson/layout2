classdef Node < uix.AbstractNode
    
    methods
        
        function obj = Node( object, nodeFactory )
            
            % Create peer
            eventSource = uix.EventSource( object );
            
            % Store properties
            obj.Object = object;
            obj.NodeFactory = nodeFactory;
            
            % Add existing children
            obj.Children = uix.Node.empty( [0 1] );
            children = hgGetTrueChildren( object );
            for ii = 1:numel( children )
                obj.Children(end+1,:) = nodeFactory.createNode( children(ii) );
            end
            
            % Add listeners
            obj.Listeners(end+1,:) = event.listener( eventSource, ...
                'ObjectChildAdded', @obj.onChildAdded );
            obj.Listeners(end+1,:) = event.listener( eventSource, ...
                'ObjectChildRemoved', @obj.onChildRemoved );
            obj.Listeners(end+1,:) = event.listener( eventSource, ...
                'ObjectDeleted', @obj.onDeleted );
            if ishghandle( object )
                obj.Listeners(end+1,:) = event.proplistener( object, ...
                    findprop( object, 'HandleVisibility' ), 'PostSet', ...
                    @obj.onVisibilityChanged );
            end
            
        end % constructor
        
    end % structors
    
end % classdef