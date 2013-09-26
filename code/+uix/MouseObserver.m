classdef MouseObserver < handle
    
    properties( SetAccess = private )
        Subject % subject
    end
    
    properties % ( Access = private )
        FigureObserver % figure observer
        FigureListener % figure listener
        Figure % cache of figure
        FigurePanelContainer % cache of figure panel container
        VisibilityObserver % visibility observer
        VisibilityListener % visibility listener
        MouseMotionListener % mouse motion listener
    end
    
    properties( Access = private, AbortSet = true )
        MouseOver = false % cache of mouse over
    end
    
    events( NotifyAccess = private )
        MouseMotion
        MouseEnter
        MouseLeave
    end
    
    methods
        
        function obj = MouseObserver( subject )
            
            % Create figure observer and listener
            figureObserver = uix.FigureObserver( subject );
            figureListener = event.listener( figureObserver, ...
                'FigureChanged', @obj.onFigureChanged );
            
            % Create visibility observer and listener
            visibilityObserver = uix.VisibilityObserver( subject );
            visibilityListener = event.listener( visibilityObserver, ...
                'VisibilityChanged', @obj.onVisibilityChanged );
            
            % Store properties
            obj.Subject = subject;
            obj.FigureObserver = figureObserver;
            obj.FigureListener = figureListener;
            obj.VisibilityObserver = visibilityObserver;
            obj.VisibilityListener = visibilityListener;
            
            % Simulate property changes
            obj.onFigureChanged()
            obj.onVisibilityChanged()
            
        end % constructor
        
    end % structors
    
    methods
        
        function set.MouseOver( obj, value )
            
            % Set
            obj.MouseOver = value;
            
            % Raise event
            if value
                notify( obj, 'MouseEnter' )
            else
                notify( obj, 'MouseLeave' )
            end
            
        end % set.MouseOver
        
    end % accessors
    
    methods
        
        function onFigureChanged( obj, ~, ~ )
            
            % Create figure listeners
            figure = obj.FigureObserver.Figure;
            if isempty( figure )
                jFigurePanelContainer = ...
                    matlab.graphics.GraphicsPlaceholder.empty( [0 0] );
                mouseMotionListener = event.listener.empty( [0 0] );
            else
                jFrame = figure.JavaFrame;
                jFigurePanelContainer = jFrame.getFigurePanelContainer();
                mouseMotionListener = event.listener( figure, ...
                    'WindowMouseMotion', @obj.onMouseMotion );
            end
            
            % Store properties
            obj.Figure = figure;
            obj.FigurePanelContainer = jFigurePanelContainer;
            obj.MouseMotionListener = mouseMotionListener;
            obj.MouseOver = false;
            
        end % onFigureChanged
        
        function onVisibilityChanged( obj, ~, ~ )
            
            visible = obj.VisibilityObserver.Visible;
            obj.MouseMotionListener.Enabled = visible;
            if visible == false
                obj.MouseOver = false;
            end
            
        end % onVisibilityChanged
        
        function onMouseMotion( obj, ~, ~ )
            
            % Update MouseOver
            mouseOver = obj.isMouseOver();
            obj.MouseOver = mouseOver;
            
            % Raise motion event
            if mouseOver
                notify( obj, 'MouseMotion' )
            end
            
        end % onMouseMotion
        
    end % event handlers
    
    methods
        
        function tf = isMouseOver( obj )
            
            % Initialize method
            persistent ROOT
            if isequal( ROOT, [] )
                % Disable JavaFrame warning
                warning( 'off', ...
                    'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame' )
                % Cache root
                ROOT = groot();
            end
            
            % Get container
            subject = obj.Subject;
            
            % Get current point
            pointerLocation = ROOT.PointerLocation;
            figure = obj.Figure;
            if strcmp( figure.WindowStyle, 'docked' )
                screenSize = ROOT.ScreenSize;
                figureSize = figure.Position(3:4);
                jFigurePanelContainer = obj.FigurePanelContainer;
                jFigureLocation = jFigurePanelContainer.getLocationOnScreen();
                figureOrigin = [jFigureLocation.getX(), screenSize(4) - ...
                    jFigureLocation.getY() - figureSize(2)];
            else
                figureOrigin = figure.Position(1:2) - [1 1];
            end
            currentPoint = pointerLocation - figureOrigin;
            
            % Get subject position
            position = uix.getPixelPosition( subject, figure, true );
            
            % Is over?
            tf = currentPoint(1) >= position(1) && ...
                currentPoint(1) < position(1) + position(3) && ...
                currentPoint(2) >= position(2) && ...
                currentPoint(2) < position(2) + position(4);
            
        end % isMouseOver
        
    end % helpers
    
end % classdef