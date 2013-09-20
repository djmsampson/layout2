classdef( Sealed ) MouseObserver < handle
    
    properties( SetAccess = private )
        Object
    end
    
    properties( Access = private )
        FigureObserver
        Over
        Listeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        MousePress
        MouseRelease
        MouseMotion
        MouseEnter
        MouseLeave
    end
    
    methods
        
        function obj = MouseObserver( object )
            
            % Check
            assert( ishghandle( object ) && ...
                isequal( size( object ), [1 1] ), 'uix.InvalidArgument', ...
                'Object must be a graphics object.' )
            
            % Create figure observer
            figureObserver = uix.FigureObserver( object );
            
            % Store properties
            obj.Object = object;
            obj.FigureObserver = figureObserver;
            
            % Create listeners
            obj.createListeners()
            
        end
        
    end % structors
    
    methods( Access = private )
        
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
        
    end % event handlers
    
    methods( Access = private )
        
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
        
        function tf = isOver( obj )
            
            % Get container
            object = obj.Object;
            
            % Get current point
            currentPoint = obj.getCurrentPoint();
            
            % Get object position
            position = getpixelposition( object );
            
            % Is over?
            tf = currentPoint(1) >= position(1) && ...
                currentPoint(1) < position(1) + position(3) && ...
                currentPoint(2) >= position(2) && ...
                currentPoint(2) < position(2) + position(4);
            
        end % isOver
        
        function p = getCurrentPoint( obj )
            
            persistent root screenSize
            if isequal( root, [] )
                root = groot();
                screenSize = root.ScreenSize;
                warning( 'off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame' )
            end
            
            pointerLocation = root.PointerLocation;
            object = obj.Object;
            figure = ancestor( object, 'figure' );
            if strcmp( figure.WindowStyle, 'docked' )
                figureSize = figure.Position(3:4);
                jFigureFrame = figure.JavaFrame;
                jFigureContainer = jFigureFrame.getFigurePanelContainer();
                jFigureLocation = jFigureContainer.getLocationOnScreen();
                figureOrigin = [jFigureLocation.getX(), screenSize(4) - ...
                    jFigureLocation.getY() - figureSize(2)];
            else
                figureOrigin = figure.Position(1:2) - [1 1];
            end
            p = pointerLocation - figureOrigin;
            
        end % getCurrentPoint
        
    end % helpers
    
end % classdef