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
                child = children(ii);
                uix.Node.message( '  Created %s for existing child node %s\n', ...
                    class( obj ), class( child ) )
                obj.Children(end+1,:) = uix.Node( child );
            end
            
            % Add listeners
            obj.Listeners(end+1,:) = event.listener( eventSource, ...
                'ObjectChildAdded', @obj.onChildAdded );
            obj.Listeners(end+1,:) = event.listener( eventSource, ...
                'ObjectChildRemoved', @obj.onChildRemoved );
            obj.Listeners(end+1,:) = event.listener( eventSource, ...
                'ObjectDeleted', @obj.onDeleted );
            
        end % constructor
        
        function delete( obj )
            
            uix.Node.message( 'Deleted %s for %s\n', class( obj ), class( obj.Object ) )
            
        end % destructor
        
    end % structors
    
    methods
        
        function onChildAdded( obj, source, eventData )
            
            child = eventData.Child;
            uix.Node.message( 'Added %s to %s\n', class( child ), class( source.Object ) )
            node = uix.Node( child );
            obj.Children(end+1,:) = node;
            notify( obj, 'ChildAdded', uix.ChildEvent( node ) )
            
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData )
            
            child = eventData.Child;
            uix.Node.message( 'Removed %s from %s\n', class( child ), class( source.Object ) )
            tf = vertcat( obj.Children.Object ) == child;
            node = obj.Children(tf,:);
            assert( numel( node ) == 1 )
            obj.Children(tf,:) = [];
            notify( obj, 'ChildRemoved', uix.ChildEvent( node ) )
            
        end % onChildRemoved
        
        function onDeleted( obj, source, ~ )
            
            uix.Node.message( 'Deleted %s\n', class( source.Object ) )
            notify( obj, 'Deleted' )
            
        end % onDeleted
        
    end % event handlers
    
    methods( Static )
        
        function message( varargin )
            
            % fprintf( 1, varargin{:} );
            
        end % message
        
    end % static methods
    
end % classdef