classdef( Hidden, Sealed ) EventSource < handle
    %uix.EventSource  Event source
    %
    %  s = uix.EventSource.getInstance(o) gets the event source
    %  corresponding to the handle o.
    %
    %  In R2013b, events ObjectChildAdded and ObjectChildRemoved should be
    %  observed on the event source rather than on the object itself due to
    %  a bug whereby, when reparenting, the event ObjectChildRemoved is
    %  raised on the wrong object.
    
    %  Copyright 2009-2013 The MathWorks, Inc.
    %  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $
    
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
            
        end % constructor
        
    end % structors
    
    methods( Static )
        
        function obj = getInstance( object )
            %getInstance  Get event source from object
            %
            %  s = uix.EventSource.getInstance(o) gets the event source for
            %  the object o.
            
            if isprop( object, 'EventSource' ) % exists, retrieve
                obj = object.EventSource;
            else % does not exist, create and store
                obj = uix.EventSource( object );
                p = addprop( object, 'EventSource' );
                p.Hidden = true;
                object.EventSource = obj;
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