classdef MouseObserver < handle
    
    properties
        Subject
        FigureObserver
        FigureListener
    end
    
    events
        MouseMotion
        MouseEnter
        MouseLeave
    end
    
    methods
        
        function obj = MouseObserver( subject )
            
            % Create figure observer
            figureObserver = uix.FigureObserver( subject );
            
            % Create figure listener
            figureListener = event.listener( figureObserver, ...
                'FigureChanged', @obj.onFigureChanged );
            
            % Store properties
            obj.Subject = subject;
            obj.FigureObserver = figureObserver;
            obj.FigureListener = figureListener;
            
        end % constructor
        
    end % structors
    
    methods
        
        function onFigureChanged( obj, source, ~ )
            
            % Create figure listeners
            figure = source.Figure;
            mouseMotionListener = event.listener( figure, ...
                'MouseMotion', @obj.onMouseMotion );
            
            % Store properties
            obj.MouseMotionListener = mouseMotionListener;
            
        end % onFigureChanged
        
        function onMouseMotion( obj, ~, ~ )
            
            if obj.isMouseOver()
                notify( obj, 'MouseMotion' )
            end
            
        end % onMouseMotion
        
    end % event handlers
    
    methods
        
        function tf = isMouseOver( obj )
            
            % Get container
            subject = obj.Subject;
            
            % Get current point
            pointerLocation = root.PointerLocation;
            figure = obj.FigureObserver.Figure;
            if strcmp( figure.WindowStyle, 'docked' )
                screenSize = root.ScreenSize;
                figureSize = figure.Position(3:4);
                jFigurePanelContainer = figure.FigurePanelContainer;
                jFigureLocation = jFigurePanelContainer.getLocationOnScreen();
                figureOrigin = [jFigureLocation.getX(), screenSize(4) - ...
                    jFigureLocation.getY() - figureSize(2)];
            else
                figureOrigin = figure.Position(1:2) - [1 1];
            end
            currentPoint = pointerLocation - figureOrigin;
            
            % Get subject position
            position = getpixelposition( subject );
            
            % Is over?
            tf = currentPoint(1) >= position(1) && ...
                currentPoint(1) < position(1) + position(3) && ...
                currentPoint(2) >= position(2) && ...
                currentPoint(2) < position(2) + position(4);
            
        end % isMouseOver
        
    end % helpers
    
end % classdef