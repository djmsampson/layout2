classdef Flex < handle
    
    properties( GetAccess = public, SetAccess = private )
        Subject
    end
    
    properties( GetAccess = public, SetAccess = private )
        Location
    end
    
    properties( Access = private )
        LocationObserver
        MousePressListener = event.listener.empty( [0 0] )
        MouseReleaseListener = event.listener.empty( [0 0] )
        MouseMotionListener = event.listener.empty( [0 0] )
        BackgroundColorListener
    end
    
    methods
        
        function obj = Flex( subject )
            
            % Create observers and listeners
            locationObserver = uix.LocationObserver( subject );
            backgroundColorListener = event.proplistener( subject, ...
                findprop( subject, 'BackgroundColor' ), 'PostSet', ...
                @subject.onBackgroundColorChange );
            
            % Store properties
            obj.Subject = subject;
            obj.LocationObserver = locationObserver;
            obj.BackgroundColorListener = backgroundColorListener;
            
            % Force transplant
            ancestors = uix.ancestors( subject );
            obj.transplant( matlab.graphics.GraphicsPlaceholder.empty( [0 1] ), ancestors )
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Location( obj )
            
            value = obj.LocationObserver.Location;
            
        end % get.Location
        
    end % accessors
    
    methods( Access = protected )
        
        function onMousePress( obj, source, eventData )
            %onMousePress  Handler for WindowMousePress events
            
            % Call method on subject
            obj.Subject.onMousePress( source, eventData )
            
        end % onMousePress
        
        function onMouseRelease( obj, source, eventData )
            %onMousePress  Handler for WindowMouseRelease events
            
            % Call method on subject
            obj.Subject.onMouseRelease( source, eventData )
            
        end % onMouseRelease
        
        function onMouseMotion( obj, source, eventData )
            %onMouseMotion  Handler for WindowMouseMotion events
            
            % Call method on subject
            obj.Subject.onMouseMotion( source, eventData )
            
        end % onMouseMotion
        
        function onBackgroundColorChange( obj, ~, ~ )
            
            % Call method on subject
            obj.Subject.onBackgroundColorChange( source, eventData )
            
        end % onBackgroundColorChange
        
    end % event handlers
    
    methods
        
        function transplant( obj, oldAncestors, newAncestors )
            %transplant  Transplant container
            %
            %  c.transplant(a,b) transplants the container c from the
            %  ancestors a to the ancestors b.
            
            % Refresh location observer
            subject = obj.Subject;
            locationObserver = uix.LocationObserver( [newAncestors; subject] );
            obj.LocationObserver = locationObserver;
            
            % Refresh mouse listeners if figure has changed
            if isempty( oldAncestors ) || ...
                    ~isa( oldAncestors(1), 'matlab.ui.Figure' )
                oldFigure = matlab.graphics.GraphicsPlaceholder.empty( [0 0] );
            else
                oldFigure = oldAncestors(1);
            end
            if isempty( newAncestors ) || ...
                    ~isa( newAncestors(1), 'matlab.ui.Figure' )
                newFigure = matlab.graphics.GraphicsPlaceholder.empty( [0 0] );
            else
                newFigure = newAncestors(1);
            end
            if ~isequal( oldFigure, newFigure )
                if isempty( newFigure )
                    mousePressListener = event.listener.empty( [0 0] );
                    mouseReleaseListener = event.listener.empty( [0 0] );
                    mouseMotionListener = event.listener.empty( [0 0] );
                else
                    mousePressListener = event.listener( newFigure, ...
                        'WindowMousePress', @obj.onMousePress );
                    mouseReleaseListener = event.listener( newFigure, ...
                        'WindowMouseRelease', @obj.onMouseRelease );
                    mouseMotionListener = event.listener( newFigure, ...
                        'WindowMouseMotion', @obj.onMouseMotion );
                end
                obj.MousePressListener = mousePressListener;
                obj.MouseReleaseListener = mouseReleaseListener;
                obj.MouseMotionListener = mouseMotionListener;
            end
            
        end % transplant
        
    end % template methods
    
end % classdef