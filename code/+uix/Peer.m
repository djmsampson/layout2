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
    end
    
    methods
        
        function obj = Peer( node )
            
            if isappdata( node, 'uixPeer' ) % exists, retrieve
                
                obj = getappdata( node, 'uixPeer' );
                % uix.Peer.message( 'Retrieved %s for %s\n', class( obj ), class( node ) )
                
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
                
                % uix.Peer.message( 'Created %s for %s\n', class( obj ), class( node ) )
                
            end
            
        end % constructor
        
        function delete( obj )
            
            node = obj.Node;
            if ishandle( node ) && strcmp( node.BeingDeleted, 'off' )
                delete( node )
            end
            uix.Peer.message( 'Deleted %s for %s\n', class( obj ), class( obj.Node ) )
            
        end % destructor
        
    end % structors
    
    methods( Access = private )
        
        function onObjectChildAdded( obj, ~, eventData )
            
            % Raise event
            childNode = eventData.Child;
            childPeer = uix.Peer( childNode );
            uix.Peer.message( 'Added %s to %s\n', class( childNode ), class( obj.Node ) )
            notify( obj, 'ObjectChildAdded', uix.ChildEvent( childPeer ) )
            
        end % onChildAdded
        
        function onObjectChildRemoved( obj, source, eventData )
            
            childNode = eventData.Child;
            childPeer = uix.Peer( childNode );
            parentNode = hgGetTrueParent( childNode );
            if isequal( parentNode, source ) % event correct
                % Raise event
                uix.Peer.message( 'Removed %s from %s\n', class( childNode ), class( obj.Node ) )
                notify( obj, 'ObjectChildRemoved', uix.ChildEvent( childPeer ) )
            else % event incorrect
                % Warn
                warning( 'uix:InvalidState', ...
                    'Incorrect source for event ''ObjectChildRemoved''.' )
                % Raise event
                parentPeer = uix.Peer( parentNode );
                uix.Peer.message( 'Removed %s from %s\n', class( childNode ), class( parentNode ) )
                notify( parentPeer, 'ObjectChildRemoved', uix.ChildEvent( childPeer ) )
            end
            
        end % onObjectChildRemoved
        
        function onObjectBeingDestroyed( obj, ~, ~ )
            
            % Call destructor, which raises ObjectBeingDestroyed event
            obj.delete()
            
        end % onObjectBeingDestroyed
        
    end % event handlers
    
    methods( Static )
        
        function message( varargin )
            
            fprintf( 1, varargin{:} );
            
        end % message
        
    end % static methods
    
end % classdef