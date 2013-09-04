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
    end
    
    methods
        
        function obj = EventSource( object )
            
            % Check input
            assert( isa( object, 'handle' ) && isscalar( object ) && ...
                isvalid( object ), 'uix:InvalidArgument', 'Invalid object.' )
            
            if isappdata( object, 'uixEventSource' ) % exists, retrieve
                
                obj = getappdata( object, 'uixEventSource' );
                
            else % does not exist, create
                
                % Store properties
                obj.Object = object;
                
                % Create listeners
                obj.Listeners(end+1,:) = event.listener( object, ...
                    'ObjectChildAdded', @obj.onObjectChildAdded );
                obj.Listeners(end+1,:) = event.listener( object, ...
                    'ObjectChildRemoved', @obj.onObjectChildRemoved );
                
                % Store in object
                setappdata( object, 'uixEventSource', obj )
                
            end
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function onObjectChildAdded( obj, ~, eventData )
            
            % Raise event
            child = eventData.Child;
            notify( obj, 'ObjectChildAdded', uix.ChildEvent( child ) )
            
        end % onChildAdded
        
        function onObjectChildRemoved( obj, source, eventData )
            
            child = eventData.Child;
            parent = hgGetTrueParent( child );
            if isequal( parent, source ) % event correct
                % Raise event
                notify( obj, 'ObjectChildRemoved', uix.ChildEvent( child ) )
            else % event incorrect
                % Warn
                warning( 'uix:InvalidState', ...
                    'Incorrect source for event ''ObjectChildRemoved''.' )
                % Raise event
                parentEventSource = uix.EventSource( parent );
                notify( parentEventSource, 'ObjectChildRemoved', uix.ChildEvent( child ) )
            end
            
        end % onObjectChildRemoved
        
    end % event handlers
    
end % classdef