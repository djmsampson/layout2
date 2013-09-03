classdef EventSource < handle
    
    properties( SetAccess = private )
        Object
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
        
        function obj = EventSource( object )
            
            if ~isa( object, 'handle' ) || ~isvalid( object ) || ~isscalar( object ) % invalid object
                
                error( 'uix:InvalidArgument', 'Invalid object.' )
                
            elseif isappdata( object, 'uixEventSource' ) % exists, retrieve
                
                obj = getappdata( object, 'uixEventSource' );
                
            else % does not exist, create
                
                % Store properties
                obj.Object = object;
                
                % Create listeners
                obj.Listeners(end+1,:) = event.listener( object, ...
                    'ObjectChildAdded', @obj.onObjectChildAdded );
                obj.Listeners(end+1,:) = event.listener( object, ...
                    'ObjectChildRemoved', @obj.onObjectChildRemoved );
                obj.Listeners(end+1,:) = event.listener( object, ...
                    'ObjectBeingDestroyed', @obj.onObjectBeingDestroyed );
                
                % Store in object
                setappdata( object, 'uixEventSource', obj )
                
            end
            
        end % constructor
        
        function delete( obj )
            
            uix.EventSource.message( 'Deleted %s for %s\n', class( obj ), class( obj.Object ) )
            
        end % destructor
        
    end % structors
    
    methods( Access = private )
        
        function onObjectChildAdded( obj, ~, eventData )
            
            % Raise event
            child = eventData.Child;
            uix.EventSource.message( 'Added %s to %s\n', class( child ), class( obj.Object ) )
            notify( obj, 'ObjectChildAdded', uix.ChildEvent( child ) )
            
        end % onChildAdded
        
        function onObjectChildRemoved( obj, source, eventData )
            
            child = eventData.Child;
            parent = hgGetTrueParent( child );
            if isequal( parent, source ) % event correct
                % Raise event
                uix.EventSource.message( 'Removed %s from %s\n', class( child ), class( obj.Object ) )
                notify( obj, 'ObjectChildRemoved', uix.ChildEvent( child ) )
            else % event incorrect
                % Warn
                warning( 'uix:InvalidState', ...
                    'Incorrect source for event ''ObjectChildRemoved''.' )
                % Raise event
                parentEventSource = uix.EventSource( parent );
                uix.EventSource.message( 'Removed %s from %s\n', class( child ), class( parent ) )
                notify( parentEventSource, 'ObjectChildRemoved', uix.ChildEvent( child ) )
            end
            
        end % onObjectChildRemoved
        
        function onObjectBeingDestroyed( obj, source, ~ )
            
            uix.EventSource.message( 'Deleted %s\n', class( source ) )
            notify( obj, 'ObjectDeleted' )
            
        end % onObjectBeingDestroyed
        
    end % event handlers
    
    methods( Static )
        
        function message( varargin )
            
            fprintf( 1, varargin{:} );
            
        end % message
        
    end % static methods
    
end % classdef