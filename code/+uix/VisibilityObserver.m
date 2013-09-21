classdef VisibilityObserver < handle
    
    properties( Access = private )
        Object
        Visible
        VisibleListeners = event.listener.empty( [0 1] )
        ParentListeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        VisibilityChanged
    end
    
    methods
        
        function obj = VisibilityObserver( object )
            
            % Check
            assert( ishghandle( object ) && ...
                isequal( size( object ), [1 1] ) && ...
                ~isa( object, 'matlab.ui.Figure' ) && ...
                ~isequal( object, groot() ), 'uix.InvalidArgument', ...
                'Object must be a graphics object.' )
            
            % Store properties
            obj.Object = object;
            
            % Force update
            obj.update()
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function update( obj )
            
            % Identify ancestors
            object = obj.Object;
            parents = object; % initialize
            visibles = {object.Visible}; % initialize
            while true
                parent = parents(end,:).Parent;
                if isempty( parent ) || isa( parent, 'matlab.ui.Root' )
                    break
                else
                    parents(end+1,:) = parent; %#ok<AGROW>
                    visibles{end+1,:} = parent.Visible; %#ok<AGROW>
                end
            end
            visible = ~isempty( parents(end).Parent ) && ...
                all( strcmp( visibles, 'on' ) );
            
            % Create listeners
            parentListeners = event.proplistener( parents, ...
                findprop( parents(1), 'Parent' ), 'PostSet', ...
                @obj.onPropertyChanged );
            visibleListeners = event.proplistener( parents, ...
                findprop( parents(1), 'Visible' ), 'PostSet', ...
                @obj.onPropertyChanged );
            
            % Store properties
            obj.Visible = visible;
            obj.ParentListeners = parentListeners;
            obj.VisibleListeners = visibleListeners;
            
        end % update
        
    end % operations
    
    methods( Access = private )
        
        function onPropertyChanged( obj, ~, ~ )
            
            % Capture old visibility
            oldVisible = obj.Visible;
            
            % Update
            obj.update()
            
            % Raise event
            newVisible = obj.Visible;
            if ~isequal( oldVisible, newVisible )
                notify( obj, 'VisibilityChanged', uix.VisibilityEvent( newVisible ) )
            end
            
        end % onPropertyChanged
        
    end % event handlers
    
end % classdef