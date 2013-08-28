classdef Node < handle
    
    properties( SetAccess = protected )
        Peer
        Children = uix.Node.empty( [0 1] )
    end
    
    properties( Access = protected )
        Listeners
    end
    
    events( NotifyAccess = protected )
        ChildAdded
        ChildRemoved
    end
    
    methods
        
        function obj = Node( peer )
            
            % Check
            assert( isvalid( peer ), 'Invalid handle.' )
            
            % Add existing children
            children = hgGetTrueChildren( peer );
            for ii = 1:numel( children )
                child = children(ii);
                fprintf( 1, '+ Added existing child %s to %s\n', class( child ), class( peer ) );
                obj.Children(end+1,:) = uix.Node( child );
            end
            
            % Create child listeners
            listeners = { ...
                event.listener( peer, 'ObjectChildAdded', @obj.onChildAdded ); ...
                event.listener( peer, 'ObjectChildRemoved', @obj.onChildRemoved ); ...
                };
            
            % Store properties
            obj.Peer = peer;
            obj.Listeners = listeners;
            
        end % constructor
        
        function delete( obj )
            
            fprintf( 1, '! Deleted node %s\n', class( obj.Peer ) );
            
        end % destructor
        
    end % structors
    
    methods( Access = protected )
        
        function onChildAdded( obj, source, eventData )
            
            child = eventData.Child;
            fprintf( 1, '+ Added %s to %s\n', class( child ), class( source ) );
            obj.Children(end+1,:) = uix.Node( child );
            notify( obj, 'ChildAdded', uix.ChildEvent( child ) )
            
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData )
            
            child = eventData.Child;
            fprintf( 1, '- Removed %s from %s\n', class( child ), class( source ) );
            index = find( [obj.Children.Peer] == child );
            switch numel( index )
                case 0
                    error( 'uix:InvalidState', 'Node not found' )
                case 1
                    obj.Children(index,:) = [];
                otherwise
                    error( 'uix:InvalidState', 'Duplicate nodes' )
            end
            notify( obj, 'ChildRemoved', uix.ChildEvent( child ) )
            
        end % onChildRemoved
        
        function onDeleted( obj, ~, ~ )
            
            obj.delete()
            
        end % onDeleted
        
    end % event handlers
    
    methods
        
        function show( obj )
            
            nShow( obj, 0 )
            function nShow( obj, level )
                fprintf( 1, '%s', repmat( ' ', [1 2*level] ) );
                fprintf( 1, '%s', class( obj.Peer ) );
                fprintf( 1, '\n' );
                for ii = 1:numel( obj.Children )
                    nShow( obj.Children(ii), level + 1 )
                end
            end % nShow
            
        end % show
        
    end
    
end % classdef

function p = hgGetTrueParent( c )

p = nGetParent( c, ancestor( c, 'Root' ) );

    function p = nGetParent( o, r )
        ch = hgGetTrueChildren( r );
        for ii = 1:numel( ch )
            if 
        
        
        
        
    end

end % iGetParent