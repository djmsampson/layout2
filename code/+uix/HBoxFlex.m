classdef HBoxFlex < uix.HBox
    
    properties( Access = private )
        Dividers = uix.Divider.empty( [0 1] )
        FrontDivider
        LocationObserver
        MousePressListener = event.listener.empty( [0 0] )
        MouseReleaseListener = event.listener.empty( [0 0] )
        MouseMotionListener = event.listener.empty( [0 0] )
        OldMouseOver = false
        ActiveDivider = 0
        MousePressLocation = [NaN NaN]
        OldDividerPosition = [NaN NaN NaN NaN]
        OldPointer = 'unset'
        BackgroundColorListener
    end
    
    methods
        
        function obj = HBoxFlex( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.HBox( notmypv{:} )
            
            % Create front divider
            divider = uix.Divider( 'Parent', obj, ...
                'Orientation', 'vertical', 'Markings', 'on', ...
                'Color', obj.BackgroundColor * 0.75, 'Visible', 'off' );
            
            % Create observers and listeners
            locationObserver = uix.LocationObserver( obj );
            backgroundColorListener = event.proplistener( obj, ...
                findprop( obj, 'BackgroundColor' ), 'PostSet', ...
                @obj.onBackgroundColorChange );
            
            % Store properties
            obj.FrontDivider = divider;
            obj.LocationObserver = locationObserver;
            obj.BackgroundColorListener = backgroundColorListener;
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods( Access = protected )
        
        function onMousePress( obj, ~, ~ )
            %onMousePress  Handler for WindowMousePress events
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            % Check whether mouse is over a divider
            [tf, loc] = obj.isMouseOverDivider();
            if ~tf, return, end
            
            % Capture state at button down
            divider = obj.Dividers(loc);
            obj.ActiveDivider = loc;
            obj.MousePressLocation = ROOT.PointerLocation;
            obj.OldDividerPosition = divider.Position;
            
            % Activate divider
            frontDivider = obj.FrontDivider;
            frontDivider.Position = divider.Position;
            divider.Visible = 'off';
            frontDivider.Visible = 'on';
            
        end % onMousePress
        
        function onMouseRelease( obj, ~, ~ )
            %onMousePress  Handler for WindowMouseRelease events
            
            % Check whether a divider is active
            loc = obj.ActiveDivider;
            if loc == 0, return, end
            
            % Deactivate divider
            obj.FrontDivider.Visible = 'off';
            obj.Dividers(loc).Visible = 'on';
            
            % Compute new positions
            delta = obj.getMouseDragLength();
            oldWidths = obj.Widths_(loc:loc+1);
            contents = obj.Contents_;
            oldPixelWidths = [contents(loc).Position(3); ...
                contents(loc+1).Position(3)];
            newPixelWidths = oldPixelWidths + delta * [1;-1];
            if oldWidths(1) < 0 && oldWidths(2) < 0 % weight, weight
                newWidths = oldWidths .* newPixelWidths ./ oldPixelWidths;
            elseif oldWidths(1) < 0 && oldWidths(2) >= 0 % weight, pixels
                newWidths = [oldWidths(1) * newPixelWidths(1) / ...
                    oldPixelWidths(1); newPixelWidths(2)];
            elseif oldWidths(1) >= 0 && oldWidths(2) < 0 % pixels, weight
                newWidths = [newPixelWidths(1); oldWidths(2) * ...
                    newPixelWidths(2) / oldPixelWidths(2)];
            else % sizes(1) >= 0 && sizes(2) >= 0 % pixels, pixels
                newWidths = newPixelWidths;
            end
            
            % Reset state at button down
            obj.ActiveDivider = 0;
            obj.MousePressLocation = [NaN NaN];
            obj.OldDividerPosition = [NaN NaN NaN NaN];
            
            % Abort set
            if isequal( oldWidths, newWidths ), return, end
            
            % Reposition contents
            obj.Widths_(loc:loc+1) = newWidths;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onMouseRelease
        
        function onMouseMotion( obj, source, ~ )
            %onMouseMotion  Handler for WindowMouseMotion events
            
            loc = obj.ActiveDivider;
            if loc == 0 % hovering
                % Update pointer for mouse enter and mouse leave
                isOver = obj.isMouseOverDivider();
                wasOver = obj.OldMouseOver;
                if wasOver ~= isOver
                    figure = source;
                    if isOver % enter
                        obj.OldPointer = figure.Pointer;
                        figure.Pointer = 'left';
                    else % leave
                        figure.Pointer = obj.OldPointer;
                        obj.OldPointer = 'unset';
                    end
                    obj.OldMouseOver = isOver;
                end
            else % dragging
                % Reposition divider
                delta = obj.getMouseDragLength();
                obj.FrontDivider.Position = ...
                    obj.OldDividerPosition + [delta 0 0 0];
            end
            
        end % onMouseMotion
        
        function onBackgroundColorChange( obj, ~, ~ )
            
            color = obj.BackgroundColor;
            dividers = obj.Dividers;
            for ii = 1:numel( dividers )
                dividers(ii).Color = color;
            end
            frontDivider = obj.FrontDivider;
            frontDivider.Color = color * 0.75;
            
        end % onBackgroundColorChange
        
    end % event handlers
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw contents
            %
            %  c.redraw() redraws the container c.
            
            % Call superclass method
            redraw@uix.HBox( obj )
            
            % Update pointer
            obj.onMouseMotion( ancestor( obj, 'figure' ), [] )
            
        end % redraw
        
        function addChild( obj, child )
            %addChild  Add child
            %
            %  c.addChild(x) adds the child x to the container c.
            
            % Add divider if there will be more than one child
            if numel( obj.Contents_ ) > 0
                divider = uix.Divider( 'Parent', obj, ...
                    'Orientation', 'vertical', 'Markings', 'on', ...
                    'Color', obj.BackgroundColor );
                obj.Dividers(end+1,:) = divider;
            end
            
            % Bring front divider to the front
            frontDivider = obj.FrontDivider;
            frontDivider.Parent = [];
            frontDivider.Parent = obj;
            
            % Call superclass method
            addChild@uix.HBox( obj, child )
            
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
            removeChild@uix.HBox( obj, child )
            
        end % removeChild
        
        function transplant( obj, oldAncestors, newAncestors )
            %transplant  Transplant container
            %
            %  c.transplant(a,b) transplants the container c from the
            %  ancestors a to the ancestors b.
            
            % Refresh location observer
            locationObserver = uix.LocationObserver( [newAncestors; obj] );
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
            
            % Call superclass method
            transplant@uix.Container( obj, oldAncestors, newAncestors )
            
        end % transplant
        
        function reposition( obj, positions )
            %reposition  Reposition contents
            %
            %  c.reposition(p) repositions the contents of the container c
            %  to the pixel positions p.
            
            % Call superclass method
            reposition@uix.HBox( obj, positions )
            
            % Set divider positions
            dividerPositions = [ ...
                positions(1:end-1,1)+positions(1:end-1,3), ...
                positions(1:end-1,2), ...
                diff( positions(:,1), 1, 1 ) - positions(1:end-1,3), ...
                positions(1:end-1,4)];
            dividerPositions(:,3) = max( dividerPositions(:,3), eps );
            dividers = obj.Dividers;
            for ii = 1:numel( dividers )
                obj.Dividers(ii).Position = dividerPositions(ii,:);
            end
            
        end % reposition
        
    end % template methods
    
    methods( Access = private )
        
        function delta = getMouseDragLength( obj )
            %getMouseDragLength  Get length of current mouse drag
            %
            %  d = c.getMouseDragLength() returns the drag length, that is
            %  the distance between the button down location and the
            %  current pointer location in the direction of dragging, in
            %  pixels.  Note that a divider cannot be dragged beyond the
            %  minimum width from its neighbors.
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            loc = obj.ActiveDivider;
            assert( loc ~= 0, 'uix:InvalidOperation', ...
                'Divider is not being dragged.' )
            delta = ROOT.PointerLocation(1) - obj.MousePressLocation(1);
            minimumWidths = obj.MinimumWidths_;
            cPixelPositions = get( obj.Contents_, {'Position'} );
            pixelPositions = vertcat( cPixelPositions{:} );
            pixelWidths = pixelPositions(:,3);
            if delta < 0 % limit to minimum distance from left neighbor
                delta = max( delta, minimumWidths(loc) - pixelWidths(loc) );
            else % limit to minimum distance from right neighbor
                delta = min( delta, pixelWidths(loc+1) - minimumWidths(loc+1) );
            end
            
        end % getMouseDragLength
        
        function [tf, loc] = isMouseOverDivider( obj )
            %isMouseOverDivider  Test for mouse over divider
            %
            %  tf = c.isMouseOverDivider() returns true if the mouse is
            %  over any divider of the container c, and false otherwise.
            %
            %  [tf,loc] = c.isMouseOverDivider() also returns an index loc
            %  corresponding to the divider that the mouse is over.  If the
            %  mouse is not over any divider then loc is 0.
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            point = ROOT.PointerLocation - ...
                obj.LocationObserver.Location(1:2) + [1 1];
            cPositions = get( obj.Dividers, {'Position'} );
            positions = vertcat( cPositions{:} );
            if isempty( positions )
                overs = true( size( positions ) );
            else
                overs = point(1) >= positions(:,1) & ...
                    point(1) < positions(:,1) + positions(:,3) & ...
                    point(2) >= positions(:,2) & ...
                    point(2) < positions(:,2) + positions(:,4);
            end
            index = find( overs, 1, 'first' );
            if isempty( index )
                tf = false;
                loc = 0;
            else
                tf = true;
                loc = index;
            end
            
        end % isMouseOverDivider
        
    end % helper methods
    
end % classdef