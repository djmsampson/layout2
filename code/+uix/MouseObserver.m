classdef MouseObserver < handle
    
    properties
        Object
        FigureObserver
        Over
        Listeners = event.listener.empty( [0 1] )
    end
    
    events
        MousePress
        MouseRelease
        MouseMotion
        MouseEnter
        MouseLeave
    end
    
    methods
        
        function obj = MouseObserver( object )
            
            % Create figure observer
            figureObserver = uix.FigureObserver( object );
            
            % Store properties
            obj.Object = object;
            obj.FigureObserver = figureObserver;
            
            % Create listeners
            obj.createListeners()
            
        end
        
        function createListeners( obj )
            
            object = obj.Object;
            figure = ancestor( object, 'figure' );
            listeners(1,:) = event.listener( figure, ...
                'WindowMousePress', @obj.onMousePress );
            listeners(2,:) = event.listener( figure, ...
                'WindowMouseRelease', @obj.onMouseRelease );
            listeners(3,:) = event.listener( figure, ...
                'WindowMouseMotion', @obj.onMouseMotion );
            obj.Listeners = listeners;
            
        end
        
        function onMousePress( obj, ~, ~ )
            
            if obj.isOver()
                notify( obj, 'MousePress' )
            end
            
        end % onMousePress
        
        function onMouseRelease( obj, ~, ~ )
            
            if obj.isOver()
                notify( obj, 'MouseRelease' )
            end
            
        end % onMouseRelease
        
        function onMouseMotion( obj, ~, ~ )
            
            % Identify whether pointer was and is over the object
            isOver = obj.isOver();
            wasOver = obj.Over;
            if isequal( wasOver, [] )
                wasOver = isOver;
            end
            
            % Raise entered and left events
            if ~wasOver && isOver
                notify( obj, 'MouseEnter' )
            elseif wasOver && ~isOver
                notify( obj, 'MouseLeave' )
            end
            
            % Raise motion event
            if isOver
                notify( obj, 'MouseMotion' )
            end
            
            % Store state
            obj.Over = isOver;
            
        end % onMouseMotion
        
        function onFigureChanged( obj, ~, ~ )
            
            obj.createListeners()
            
        end % onFigureChanged
        
        function tf = isOver( obj )
            
            % Get container
            object = obj.Object;
            
            % Get current point
            root = groot();
            pointerLocation = root.PointerLocation;
            figure = ancestor( object, 'figure' );
            figurePosition = figure.Position;
            currentPoint = pointerLocation - figurePosition(1:2) + [1 1];
            
            % Get object position
            position = getpixelposition( object );
            
            % Is over?
            tf = currentPoint(1) >= position(1) && ...
                currentPoint(1) <= position(1) + position(3) && ...
                currentPoint(2) >= position(2) && ...
                currentPoint(2) <= position(2) + position(4);
            
        end % isOver
        
    end
    
end % classdef