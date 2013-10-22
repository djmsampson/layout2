classdef VBoxFlex < uix.VBox
    
    properties( Access = private )
        Dividers = uix.Divider.empty( [0 1] )
        FrontDivider
        LocationObserver
        MousePressListener = event.listener.empty( [0 0] )
        MouseReleaseListener = event.listener.empty( [0 0] )
        MouseMotionListener = event.listener.empty( [0 0] )
        OldMouseOver = false
        ActiveDivider = 0
        ActiveDividerPosition = [NaN NaN NaN NaN]
        MousePressLocation = [NaN NaN]
        OldPointer = 'unset'
        BackgroundColorListener
    end
    
    methods
        
        function obj = VBoxFlex( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.VBox( notmypv{:} )
            
            % Create front divider
            frontDivider = uix.Divider( 'Parent', obj, ...
                'Orientation', 'horizontal', 'Markings', 'on', ...
                'Color', obj.BackgroundColor * 0.75, 'Visible', 'off' );
            
            % Create observers and listeners
            locationObserver = uix.LocationObserver( obj );
            backgroundColorListener = event.proplistener( obj, ...
                findprop( obj, 'BackgroundColor' ), 'PostSet', ...
                @obj.onBackgroundColorChange );
            
            % Store properties
            obj.FrontDivider = frontDivider;
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
            pointerLocation = ROOT.PointerLocation;
            point = pointerLocation - ...
                obj.LocationObserver.Location(1:2) + [1 1];
            cPositions = get( obj.Dividers, {'Position'} );
            positions = vertcat( cPositions{:} );
            [tf, loc] = uix.inrectangle( point, positions );
            if ~tf, return, end
            
            % Capture state at button down
            divider = obj.Dividers(loc);
            obj.ActiveDivider = loc;
            obj.ActiveDividerPosition = divider.Position;
            obj.MousePressLocation = pointerLocation;
            
            % Activate divider
            frontDivider = obj.FrontDivider;
            frontDivider.Position = divider.Position;
            divider.Visible = 'off';
            frontDivider.Visible = 'on';
            
        end % onMousePress
        
        function onMouseRelease( obj, ~, ~ )
            %onMousePress  Handler for WindowMouseRelease events
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            % Check whether a divider is active
            loc = obj.ActiveDivider;
            if loc == 0, return, end
            
            % Compute new positions
            delta = ROOT.PointerLocation(2) - obj.MousePressLocation(2);
            if delta < 0 % limit to minimum distance from lower neighbor
                delta = max( delta, obj.MinimumHeights_(loc+1) - ...
                    obj.Contents_(loc+1).Position(4) );
            else % limit to minimum distance from upper neighbor
                delta = min( delta, obj.Contents_(loc).Position(4) - ...
                    obj.MinimumHeights_(loc) );
            end
            oldHeights = obj.Heights_(loc:loc+1);
            contents = obj.Contents_;
            oldPixelHeights = [contents(loc).Position(4); ...
                contents(loc+1).Position(4)];
            newPixelHeights = oldPixelHeights - delta * [1;-1];
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
            
            % Deactivate divider
            obj.FrontDivider.Visible = 'off';
            obj.Dividers(loc).Visible = 'on';
            
            % Reset state at button down
            obj.ActiveDivider = 0;
            obj.ActiveDividerPosition = [NaN NaN NaN NaN];
            obj.MousePressLocation = [NaN NaN];
            
            % Reposition contents
            obj.Heights_(loc:loc+1) = newHeights;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onMouseRelease
        
        function onMouseMotion( obj, source, ~ )
            %onMouseMotion  Handler for WindowMouseMotion events
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            loc = obj.ActiveDivider;
            if loc == 0 % hovering
                % Update pointer for mouse enter and mouse leave
                point = ROOT.PointerLocation - ...
                    obj.LocationObserver.Location(1:2) + [1 1];
                cPositions = get( obj.Dividers, {'Position'} );
                positions = vertcat( cPositions{:} );
                isOver = uix.inrectangle( point, positions );
                wasOver = obj.OldMouseOver;
                if wasOver ~= isOver
                    figure = source;
                    if isOver % enter
                        obj.OldPointer = figure.Pointer;
                        figure.Pointer = 'top';
                    else % leave
                        figure.Pointer = obj.OldPointer;
                        obj.OldPointer = 'unset';
                    end
                    obj.OldMouseOver = isOver;
                end
            else % dragging
                % Reposition divider
                delta = ROOT.PointerLocation(2) - obj.MousePressLocation(2);
                if delta < 0 % limit to minimum distance from lower neighbor
                    delta = max( delta, obj.MinimumHeights_(loc+1) - ...
                        obj.Contents_(loc+1).Position(4) );
                else % limit to minimum distance from upper neighbor
                    delta = min( delta, obj.Contents_(loc).Position(4) - ...
                        obj.MinimumHeights_(loc) );
                end
                obj.FrontDivider.Position = ...
                    obj.ActiveDividerPosition + [0 delta 0 0];
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
            redraw@uix.VBox( obj )
            
            % Create or destroy dividers
            q = numel( obj.Dividers ); % current number of dividers
            r = max( [numel( obj.Heights_ )-1 0] ); % required number of dividers
            if q < r % create
                for ii = q+1:r
                    divider = uix.Divider( 'Parent', obj, ...
                        'Orientation', 'horizontal', 'Markings', 'on', ...
                        'Color', obj.BackgroundColor );
                    obj.Dividers(ii,:) = divider;
                end
                % Bring front divider to the front
                frontDivider = obj.FrontDivider;
                frontDivider.Parent = [];
                frontDivider.Parent = obj;
            elseif q > r % destroy
                % Destroy dividers
                delete( obj.Dividers(r+1:q,:) )
                obj.Dividers(r+1:q,:) = [];
            end
            
            % Position dividers
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            heights = obj.Heights_;
            minimumHeights = obj.MinimumHeights_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            xPositions = [padding + 1, max( bounds(3) - 2 * padding, 1 )];
            xPositions = repmat( xPositions, [r 1] );
            ySizes = uix.calcPixelSizes( bounds(4), heights, ...
                minimumHeights, padding, spacing );
            yPositions = [bounds(4) - cumsum( ySizes(1:r,:) ) - padding - ...
                spacing * transpose( 1:r ) + 1, repmat( spacing, [r 1] )];
            positions = [xPositions(:,1), yPositions(:,1), ...
                xPositions(:,2), yPositions(:,2)];
            for ii = 1:r
                divider = obj.Dividers(ii);
                divider.Position = positions(ii,:);
            end
            
            % Update pointer
            obj.onMouseMotion( ancestor( obj, 'figure' ), [] )
            
        end % redraw
        
        function unparent( obj, oldAncestors )
            %unparent  Unparent container
            %
            %  c.unparent(a) unparents the container c from the ancestors
            %  a.
            
            % Restore figure pointer
            if ~isempty( oldAncestors ) && ...
                    isa( oldAncestors(1), 'matlab.ui.Figure' )
                oldFigure = oldAncestors(1);
                oldPointer = obj.OldPointer;
                if oldPointer ~= 0
                    oldFigure.Pointer = obj.Pointer;
                    obj.Pointer = 'unset';
                    obj.OldPointer = 0;
                end
            end
            
            % Call superclass method
            unparent@uix.Container( obj, oldAncestors )
            
        end % unparent
        
        function reparent( obj, oldAncestors, newAncestors )
            %reparent  Reparent container
            %
            %  c.reparent(a,b) reparents the container c from the ancestors
            %  a to the ancestors b.
            
            % Refresh location observer
            locationObserver = uix.LocationObserver( [newAncestors; obj] );
            obj.LocationObserver = locationObserver;
            
            % Refresh mouse listeners if figure has changed
            if isempty( oldAncestors ) || ...
                    ~isa( oldAncestors(1), 'matlab.ui.Figure' )
                oldFigure = gobjects( [0 0] );
            else
                oldFigure = oldAncestors(1);
            end
            if isempty( newAncestors ) || ...
                    ~isa( newAncestors(1), 'matlab.ui.Figure' )
                newFigure = gobjects( [0 0] );
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
            reparent@uix.Container( obj, oldAncestors, newAncestors )
            
            % Update pointer
            obj.onMouseMotion( ancestor( obj, 'figure' ), [] )
            
        end % reparent
        
    end % template methods
    
end % classdef