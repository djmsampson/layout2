classdef ChildObserver < handle
    
    properties
        Tree
    end
    
    events( NotifyAccess = private )
        ChildAdded
        ChildRemoved
    end
    
    methods
        
        function obj = ChildObserver( o )
            
            obj.Tree = obj.createNode( o );
            
        end
        
        function n = createNode( obj, o )
            
            if ~isequal( obj.Tree, [] ) && ishghandle( o )
                n = uix.TerminalNode( o, obj );
            else
                n = uix.Node( o, obj );
                addlistener( n, 'ChildAdded', @obj.onChildEvent );
                addlistener( n, 'ChildRemoved', @obj.onChildEvent );
            end
            addlistener( n, 'VisibilityChanged', @obj.onVisibilityChanged );
            
        end
        
        function onChildEvent( obj, ~, eventData )
            
            iOnChildEvent( eventData.Child )
            function iOnChildEvent( n )
                o = n.Object;
                if ishghandle( o ) && strcmp( o.HandleVisibility, 'on' )
                    notify( obj, eventData.EventName, uix.ChildEvent( o ) )
                end
                c = n.Children;
                for ii = 1:numel( c )
                    iOnChildEvent( c(ii) )
                end
            end
            
        end % onChildEvent
        
        function onVisibilityChanged( obj, source, ~ )
            
            o = source.Object;
            switch o.HandleVisibility
                case 'on'
                    notify( obj, 'ChildAdded', uix.ChildEvent( o ) )
                case {'off','callback'}
                    notify( obj, 'ChildRemoved', uix.ChildEvent( o ) )
            end
            
        end % onVisibilityChanged
        
    end % methods
    
end % classdef