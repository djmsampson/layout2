classdef( Hidden, Sealed ) VisibilityObserver < handle
    
    properties( SetAccess = private )
        Subject
        Visible
    end
    
    properties( Access = private )
        VisibleListeners = event.listener.empty( [0 1] )
        ParentListeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        VisibilityChanged
    end
    
    methods
        
        function obj = VisibilityObserver( subject )
            
            % Check
            assert( ishghandle( subject ) && ...
                isequal( size( subject ), [1 1] ) && ...
                ~isa( subject, 'matlab.ui.Root' ) && ...
                ~isequal( subject, groot() ), 'uix.InvalidArgument', ...
                'Subject must be a graphics object.' )
            
            % Store properties
            obj.Subject = subject;
            
            % Force update
            obj.update()
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function update( obj )
            
            % Identify ancestors
            subject = obj.Subject;
            parents = subject; % initialize
            visibles = {subject.Visible}; % initialize
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
            for ii = 1:numel( parents )
                parent = parents(ii);
                parentListeners(ii,:) = event.proplistener( parent, ...
                    findprop( parent, 'Parent' ), 'PostSet', ...
                    @obj.onPropertyChanged ); %#ok<AGROW>
                visibleListeners(ii,:) = event.proplistener( parent, ...
                    findprop( parent, 'Visible' ), 'PostSet', ...
                    @obj.onPropertyChanged ); %#ok<AGROW>
            end
            
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
                notify( obj, 'VisibilityChanged' )
            end
            
        end % onPropertyChanged
        
    end % event handlers
    
end % classdef