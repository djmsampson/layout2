classdef( Hidden, Sealed ) FigureObserver < handle
    
    properties( Access = private )
        Object
        Figure
        ParentListeners = event.proplistener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        FigureChanged % figure changed
    end
    
    methods
        
        function obj = FigureObserver( object )
            %uix.FigureObserver  Figure observer
            %
            %  fo = uix.FigureObserver(o) creates a figure observer for the
            %  graphics object o.  A figure observer raises an event
            %  FigureChanged when ancestor(o,'figure') changes.  o
            
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
            %update  Update figure observer
            
            % Identify ancestors
            parents = obj.Object; % initialize
            while true
                parent = parents(end,:).Parent;
                if isempty( parent ) || isa( parent, 'matlab.ui.Figure' )
                    figure = parent;
                    break
                else
                    parents(end+1,:) = parent; %#ok<AGROW>
                end
            end
            
            % Create listeners
            parentListeners = event.proplistener( parents, ...
                findprop( parents(1), 'Parent' ), 'PostSet', ...
                @obj.onParentChanged );
            
            % Store properties
            obj.Figure = figure;
            obj.ParentListeners = parentListeners;
            
        end % update
        
    end % operations
    
    methods( Access = private )
        
        function onParentChanged( obj, ~, ~ )
            
            % Capture old figure
            oldFigure = obj.Figure;
            
            % Update
            obj.update()
            
            % Raise event
            newFigure = obj.Figure;
            if ~isequal( oldFigure, newFigure )
                notify( obj, 'FigureChanged', uix.FigureEvent( newFigure ) )
            end
            
        end % onParentChanged
        
    end % event handlers
    
end % classdef