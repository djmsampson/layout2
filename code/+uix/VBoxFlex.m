classdef VBoxFlex < uix.VBox
    
    properties( SetAccess = private )
        MouseObserver
        MousePressListener
        MouseReleaseListener
        MouseMotionListener
        Dividers = uix.Divider.empty( [0 1] )
        FrontDivider
        ActiveDivider = 0
        Dragging = false
        MousePressLocation = [NaN NaN]
        OldDividerPosition = [NaN NaN NaN NaN]
        OldPointer = 'unset'
    end
    
    methods
        
        function obj = VBoxFlex( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.VBox( notmypv{:} )
            
            % Create mouse observer
            mouseObserver = uix.MouseObserver( obj );
            mousePressListener = event.listener( mouseObserver, ...
                'MousePress', @obj.onMousePress );
            mouseReleaseListener = event.listener( mouseObserver, ...
                'MouseRelease', @obj.onMouseRelease );
            mouseMotionListener = event.listener( mouseObserver, ...
                'MouseMotion', @obj.onMouseMotion );
            
            % Create front divider
            frontDivider = uix.Divider( 'Parent', obj, ...
                'Orientation', 'vertical', 'Markings', 'on', ...
                'Color', obj.BackgroundColor * 0.75, 'Visible', 'off' );
            
            % Store properties
            obj.MouseObserver = mouseObserver;
            obj.MousePressListener = mousePressListener;
            obj.MouseReleaseListener = mouseReleaseListener;
            obj.MouseMotionListener = mouseMotionListener;
            obj.FrontDivider = frontDivider;
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods( Access = protected )
        
        function addChild( obj, child )
            %addChild  Add child
            %
            %  c.addChild(x) adds the child x to the container c.
            
            % Add divider if there will be more than one child
            if numel( obj.Contents_ ) > 0
                divider = uix.Divider( 'Parent', obj, ...
                    'Orientation', 'horizontal', 'Markings', 'on', ...
                    'Color', obj.BackgroundColor );
                obj.Dividers(end+1,:) = divider;
            end
            
            % Bring front divider to the front
            frontDivider = obj.FrontDivider;
            frontDivider.Parent = [];
            frontDivider.Parent = obj;
            
            % Call superclass method
            addChild@uix.VBox( obj, child )
            
        end % addChild
        
        function removeChild( obj, child )
            %removeChild  Remove child
            %
            %  c.removeChild(x) removes the child x from the container c.
            
            % Remove divider if there is more than one child
            contents = obj.Contents_;
            tf = contents == child;
            if numel( contents ) > 1
                loc = max( find( tf ) - 1, 1 );
                delete( obj.Dividers(loc) )
                obj.Dividers(loc,:) = [];
            end
            
            % Call superclass method
            removeChild@uix.VBox( obj, child )
            
        end % removeChild
        
        function transplant( obj, oldAncestors, newAncestors )
            
            % Identify old and new figures
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
            
            % Create new mouse observer if necessary
            if ~isequal( oldFigure, newFigure )
                mouseObserver = uix.MouseObserver( obj );
                mousePressListener = event.listener( mouseObserver, ...
                    'MousePress', @obj.onMousePress );
                mouseReleaseListener = event.listener( mouseObserver, ...
                    'MouseRelease', @obj.onMouseRelease );
                mouseMotionListener = event.listener( mouseObserver, ...
                    'MouseMotion', @obj.onMouseMotion );
                obj.MouseObserver = mouseObserver;
                obj.MousePressListener = mousePressListener;
                obj.MouseReleaseListener = mouseReleaseListener;
                obj.MouseMotionListener = mouseMotionListener;
            end
            
        end % transplant
        
    end % template methods
    
    methods( Access = private )
        
        function onMousePress( obj, ~, ~ )
            %onMousePress  Handler for MousePress events
            
            % Check whether mouse is over a divider
            mouseObserver = obj.MouseObserver;
            cPositions = get( obj.Dividers, {'Position'} );
            positions = vertcat( cPositions{:} );
            [tf, loc] = mouseObserver.isOver( positions );
            if ~tf, return, end
            
            % Capture state at button down
            obj.MousePressLocation = mouseObserver.PointerLocation;
            obj.Dragging = true;
            divider = obj.Dividers(loc);
            obj.ActiveDivider = loc;
            obj.OldDividerPosition = divider.Position;
            
            % Activate divider
            frontDivider = obj.FrontDivider;
            frontDivider.Position = divider.Position;
            divider.Visible = 'off';
            frontDivider.Visible = 'on';
            
        end % onMousePress
        
        function onMouseRelease( obj, ~, ~ )
            %onMousePress  Handler for MouseRelease events
            
            % Check whether dragging
            if ~obj.Dragging, return, end
            
            % Deactivate divider
            loc = obj.ActiveDivider;
            obj.FrontDivider.Visible = 'off';
            obj.Dividers(loc).Visible = 'on';
            
            % Compute new positions
            delta = obj.MouseObserver.PointerLocation - obj.MousePressLocation;
            oldHeights = obj.Heights_(loc:loc+1);
            contents = obj.Contents_;
            oldPixelHeights = [contents(loc).Position(3); ...
                contents(loc+1).Position(3)];
            newPixelHeights = oldPixelHeights + delta * [1;-1];
            if oldHeights(1) < 0 && oldHeights(2) < 0 % weight, weight
                newHeights = oldHeights .* newPixelHeights ./ oldPixelHeights;
            elseif oldHeights(1) < 0 && oldHeights(2) >= 0 % weight, pixels
                newHeights = [oldHeights(1) * newPixelHeights(1) / ...
                    oldPixelHeights(1); newPixelHeights(2)];
            elseif oldHeights(1) >= 0 && oldHeights(2) < 0 % pixels, weight
                newHeights = [newPixelHeights(1); oldHeights(2) * ...
                    newPixelHeights(2) / oldPixelHeights(2)];
            else % sizes(1) >= 0 && sizes(2) >= 0 % pixels, pixels
                newHeights = newPixelHeights;
            end
            
            % Reset state at button down
            obj.Dragging = false;
            obj.MousePressLocation = [NaN NaN];
            obj.OldDividerPosition = [NaN NaN NaN NaN];
            
            % Abort set
            if isequal( oldHeights, newHeights ), return, end
            
            % Reposition contents
            obj.Heights_(loc:loc+1) = newHeights;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onMouseRelease
        
        function onMouseMotion( obj, source, eventData )
            %onMouseMotion  Handler for MouseMotion events
            
            disp MouseMotion
            
            %             loc = obj.ActiveDivider;
            %             if loc == 0 % hovering
            %                 % Update pointer for mouse enter and mouse leave
            %                 isOver = obj.isMouseOverDivider();
            %                 wasOver = obj.OldMouseOver;
            %                 if wasOver ~= isOver
            %                     figure = source;
            %                     if isOver % enter
            %                         obj.OldPointer = figure.Pointer;
            %                         figure.Pointer = 'left';
            %                     else % leave
            %                         figure.Pointer = obj.OldPointer;
            %                         obj.OldPointer = 'unset';
            %                     end
            %                     obj.OldMouseOver = isOver;
            %                 end
            %             else % dragging
            %                 % Reposition divider
            %                 delta = obj.getMouseDragLength();
            %                 obj.FrontDivider.Position = ...
            %                     obj.OldDividerPosition + [delta 0 0 0];
            %             end
            
        end % onMouseMotion
        
        function onBackgroundColorChange( obj, source, eventData )
            
            disp onBackgroundColorChange
            
        end % onBackgroundColorChange
        
    end % event handlers
    
end % classdef