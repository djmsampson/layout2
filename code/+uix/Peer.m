classdef Peer < handle
    
    properties( SetAccess = private )
        Node
    end
    
    properties( Access = private )
        Listeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        ObjectChildAdded
        ObjectChildRemoved
        ObjectDeleted
    end
    
    methods
        
        function obj = Peer( node )
            
            if ~isa( node, 'handle' ) || ~isvalid( node ) || ~isscalar( node ) % invalid node
                
                error( 'uix:InvalidArgument', 'Invalid node.' )
                
            elseif isappdata( node, 'uixPeer' ) % exists, retrieve
                
                obj = getappdata( node, 'uixPeer' );
                
            else % does not exist, create
                
                % Store properties
                obj.Node = node;
                
                % Create listeners
                obj.Listeners(end+1,:) = event.listener( node, ...
                    'ObjectChildAdded', @obj.onObjectChildAdded );
                obj.Listeners(end+1,:) = event.listener( node, ...
                    'ObjectChildRemoved', @obj.onObjectChildRemoved );
                obj.Listeners(end+1,:) = event.listener( node, ...
                    'ObjectBeingDestroyed', @obj.onObjectBeingDestroyed );
                
                % Store in node
                setappdata( node, 'uixPeer', obj )
                
            end
            
        end % constructor
        
        function delete( obj )
            
            uix.Peer.message( 'Deleted %s for %s\n', class( obj ), class( obj.Node ) )
            
        end % destructor
        
    end % structors
    
    methods( Access = private )
        
        function onObjectChildAdded( obj, ~, eventData )
            
            % Raise event
            child = eventData.Child;
            uix.Peer.message( 'Added %s to %s\n', class( child ), class( obj.Node ) )
            notify( obj, 'ObjectChildAdded', uix.ChildEvent( child ) )
            
        end % onChildAdded
        
        function onObjectChildRemoved( obj, source, eventData )
            
            child = eventData.Child;
            parent = hgGetTrueParent( child );
            if isequal( parent, source ) % event correct
                % Raise event
                uix.Peer.message( 'Removed %s from %s\n', class( child ), class( obj.Node ) )
                notify( obj, 'ObjectChildRemoved', uix.ChildEvent( child ) )
            else % event incorrect
                % Warn
                warning( 'uix:InvalidState', ...
                    'Incorrect source for event ''ObjectChildRemoved''.' )
                % Raise event
                parentPeer = uix.Peer( parent );
                uix.Peer.message( 'Removed %s from %s\n', class( child ), class( parent ) )
                notify( parentPeer, 'ObjectChildRemoved', uix.ChildEvent( child ) )
            end
            
        end % onObjectChildRemoved
        
        function onObjectBeingDestroyed( obj, source, ~ )
            
            uix.Peer.message( 'Deleted %s\n', class( source ) )
            notify( obj, 'ObjectDeleted' )
            
        end % onObjectBeingDestroyed
        
    end % event handlers
    
    methods( Static )
        
        function message( varargin )
            
            % fprintf( 1, varargin{:} );
            
        end % message
        
    end % static methods
    
end % classdef