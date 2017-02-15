classdef MouseObserver < handle
    %uix.MouseObserver  Mouse observer
    %
    %  A mouse observer raises events when the mouse interacts with a
    %  subject.
    
    %  Copyright 2017 The MathWorks, Inc.
    %  $Revision: 1435 $ $Date: 2016-11-17 17:50:34 +0000 (Thu, 17 Nov 2016) $
    
    properties ( SetAccess = immutable )
        Subject
    end
    
    properties ( Access = private )
        FigureObserver
        FigureListener
        MotionListener
        PressListener
        ReleaseListener
        WasOver = false
        ButtonDown = false
        ButtonDownTime = -Inf
        ClickTime = -Inf
    end
    
    properties ( Constant, Access = private )
        Toolkit = java.awt.Toolkit.getDefaultToolkit()
    end
    
    events ( NotifyAccess = private )
        MouseDoubleClicked
        MouseClicked
%         MouseDragged
        MouseEntered
        MouseExited
%         MouseMoved
        MousePressed
        MouseReleased
    end
    
    methods
        
        function obj = MouseObserver( subject )
            
            obj.Subject = subject;
            obj.FigureObserver = uix.FigureObserver( subject );
            obj.FigureListener = event.listener( obj.FigureObserver, ...
                'FigureChanged', @obj.onFigureChanged );
            obj.createMouseListeners();
            
        end % constructor
        
    end
    
    methods ( Access = private )
        
        function onFigureChanged( obj, ~, ~ )
            
            obj.createMouseListeners()
            obj.WasOver = false;
            
        end % onFigureChanged
        
        function createMouseListeners( obj )
            
            fo = obj.FigureObserver;
            if isempty( fo.Figure )
                obj.MotionListener = [];
                obj.PressListener = [];
                obj.ReleaseListener = [];
            else
                obj.MotionListener = event.listener( fo.Figure, ...
                    'WindowMouseMotion', @obj.onMouseMotion );
                obj.PressListener = event.listener( fo.Figure, ...
                    'WindowMousePress', @obj.onMousePress );
                obj.ReleaseListener = event.listener( fo.Figure, ...
                    'WindowMouseRelease', @obj.onMouseRelease );
            end
            
        end % createMouseListeners
        
        function onMouseMotion( obj, ~, eventData )
            
            if isancestorof( obj.Subject, eventData.HitObject )
                if obj.WasOver == false
                    notify( obj, 'MouseEntered' )
                end
                obj.WasOver = true;
            else
                if obj.WasOver
                    notify( obj, 'MouseExited' )
                end
                obj.WasOver = false;
            end
            
        end % onMouseMotion
        
        function onMousePress( obj, ~, eventData )
            
            if obj.Subject == eventData.HitObject
                obj.ButtonDown = true;
                obj.ButtonDownTime = now();
                notify( obj, 'MousePressed' )
            end
            
        end
        
        function onMouseRelease( obj, ~, eventData )
            
            if obj.ButtonDown
                n = now();
                obj.ButtonDown = false;
                notify( obj, 'MouseReleased' )
                if obj.Subject == eventData.HitObject
                    notify( obj, 'MouseClicked' )
                    dct = obj.Toolkit.getDesktopProperty( 'awt.multiClickInterval' )/86400000;
                    if n - obj.ClickTime < dct
                        notify( obj, 'MouseDoubleClicked' )
                    end
                    obj.ClickTime = n;
                end
            end
            
        end
        
    end % methods
    
end % classdef

function tf = isancestorof( a, b )

tf = ancestor( b, a.Type ) == a;

end