classdef( Hidden, Sealed ) FigureObserver < handle
    
    properties( SetAccess = private )
        Subject
        Figure
    end
    
    properties( Access = private )
        ParentListeners = event.proplistener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        FigureChanged % figure changed
    end
    
    methods
        
        function obj = FigureObserver( subject )
            %uix.FigureObserver  Figure observer
            %
            %  fo = uix.FigureObserver(o) creates a figure observer for the
            %  graphics subject o.  A figure observer raises an event
            %  FigureChanged when ancestor(o,'figure') changes.  o
            
            % Check
            assert( ishghandle( subject ) && ...
                isequal( size( subject ), [1 1] ) && ...
                ~isa( subject, 'matlab.ui.Figure' ) && ...
                ~isequal( subject, groot() ), 'uix.InvalidArgument', ...
                'Subject must be a graphics subject.' )
            
            % Store properties
            obj.Subject = subject;
            
            % Force update
            obj.update()
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function update( obj )
            %update  Update figure observer
            
            % Identify ancestors
            parents = obj.Subject; % initialize
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
            for ii = 1:numel( parents )
                parent = parents(ii);
                parentListeners(ii,:) = event.proplistener( parent, ...
                    findprop( parent, 'Parent' ), 'PostSet', ...
                    @obj.onParentChanged ); %#ok<AGROW>
            end
            
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
                notify( obj, 'FigureChanged' )
            end
            
        end % onParentChanged
        
    end % event handlers
    
end % classdef