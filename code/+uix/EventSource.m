classdef EventSource < handle
    
    properties( Access = private )
        Listeners = event.listener.empty( [0 1] ) % listeners
    end
    
    events( NotifyAccess = private )
        ObjectChildAdded % child added
        ObjectChildRemoved % child removed
    end
    
    methods( Access = private )
        
        function obj = EventSource( object )
            %uix.EventSource  Event source
            %
            %  See also: uix.EventSource/getInstance
            
            % Check input
            assert( isa( object, 'handle' ) && ...
                isequal( size( object ), [1 1] ) && isvalid( object ), ...
                'uix:InvalidArgument', 'Invalid object.' )
            
            % Create listeners
            obj.Listeners(end+1,:) = event.listener( object, ...
                'ObjectChildAdded', @obj.onObjectChildAdded );
            obj.Listeners(end+1,:) = event.listener( object, ...
                'ObjectChildRemoved', @obj.onObjectChildRemoved );
            
            % Store in object
            setappdata( object, 'uixEventSource', obj )
            
        end % constructor
        
    end % structors
    
    methods( Static )
        
        function obj = getInstance( object )
            %getInstance  Get event source from object
            %
            %  s = uix.EventSource.getInstance(o) gets the event source for
            %  the object o.
            
            if isappdata( object, 'uixEventSource' ) % exists, retrieve
                obj = getappdata( object, 'uixEventSource' );
            else % does not exist, create
                obj = uix.EventSource( object );
            end
            
        end % getInstance
        
    end % static methods
    
    methods( Access = private )
        
        function onObjectChildAdded( obj, ~, eventData )
            %onObjectChildAdded  Event handler for 'ObjectChildAdded'
            
            % Raise event
            child = eventData.Child;
            notify( obj, 'ObjectChildAdded', uix.ChildEvent( child ) )
            
        end % onObjectChildAdded
        
        function onObjectChildRemoved( obj, source, eventData )
            %onObjectChildRemoved  Event handler for 'ObjectChildRemoved'
            
            child = eventData.Child;
            if ismember( child, hgGetTrueChildren( source ) ) % event correct
                % Raise event
                notify( obj, 'ObjectChildRemoved', uix.ChildEvent( child ) )
            else % event incorrect
                % Warn
                warning( 'uix:InvalidState', ...
                    'Incorrect source for event ''ObjectChildRemoved''.' )
                % Raise event
                parent = hgGetTrueParent( child );
                parentEventSource = uix.EventSource.getInstance( parent );
                notify( parentEventSource, 'ObjectChildRemoved', uix.ChildEvent( child ) )
            end
            
        end % onObjectChildRemoved
        
    end % event handlers
    
end % classdef