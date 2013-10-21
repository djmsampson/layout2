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
            frontDivider = uix.Divider( 'Parent', obj, ...
                'Orientation', 'vertical', 'Markings', 'on', ...
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
            obj.MousePressLocation = pointerLocation;
            obj.OldDividerPosition = divider.Position;
            
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
            delta = ROOT.PointerLocation(1) - obj.MousePressLocation(1);
            if delta < 0 % limit to minimum distance from left neighbor
                delta = max( delta, obj.MinimumWidths_(loc) - ...
                    obj.Contents_(loc).Position(3) );
            else % limit to minimum distance from right neighbor
                delta = min( delta, obj.Contents_(loc+1).Position(3) - ...
                    obj.MinimumWidths_(loc+1) );
            end
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
            
            % Deactivate divider
            obj.FrontDivider.Visible = 'off';
            obj.Dividers(loc).Visible = 'on';
            
            % Reset state at button down
            obj.ActiveDivider = 0;
            obj.MousePressLocation = [NaN NaN];
            obj.OldDividerPosition = [NaN NaN NaN NaN];
            
            % Reposition contents
            obj.Widths_(loc:loc+1) = newWidths;
            
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
                        figure.Pointer = 'left';
                    else % leave
                        figure.Pointer = obj.OldPointer;
                        obj.OldPointer = 'unset';
                    end
                    obj.OldMouseOver = isOver;
                end
            else % dragging
                % Reposition divider
                delta = ROOT.PointerLocation(1) - obj.MousePressLocation(1);
                if delta < 0 % limit to minimum distance from left neighbor
                    delta = max( delta, obj.MinimumWidths_(loc) - ...
                        obj.Contents_(loc).Position(3) );
                else % limit to minimum distance from right neighbor
                    delta = min( delta, obj.Contents_(loc+1).Position(3) - ...
                        obj.MinimumWidths_(loc+1) );
                end
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
            
            % Create or destroy dividers
            b = numel( obj.Dividers ); % current number of dividers
            c = max( [numel( obj.Widths_ )-1 0] ); % required number of dividers
            if b < c % create
                for ii = b+1:c
                    divider = uix.Divider( 'Parent', obj, ...
                        'Orientation', 'vertical', 'Markings', 'on', ...
                        'Color', obj.BackgroundColor );
                    obj.Dividers(ii,:) = divider;
                end
                % Bring front divider to the front
                frontDivider = obj.FrontDivider;
                frontDivider.Parent = [];
                frontDivider.Parent = obj;
            elseif b > c % destroy
                % Destroy dividers
                delete( obj.Dividers(c+1:b,:) )
                obj.Dividers(c+1:b,:) = [];
            end
            
            % Position dividers
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            widths = obj.Widths_;
            minimumWidths = obj.MinimumWidths_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            xSizes = uix.calcPixelSizes( bounds(3), widths, ...
                minimumWidths, padding, spacing );
            xPositions = [cumsum( xSizes(1:c,:) ) + padding + ...
                spacing * transpose( 0:c-1 ) + 1, repmat( spacing, [c 1] )];
            yPositions = [padding + 1, max( bounds(4) - 2 * padding, 1 )];
            yPositions = repmat( yPositions, [c 1] );
            positions = [xPositions(:,1), yPositions(:,1), ...
                xPositions(:,2), yPositions(:,2)];
            for ii = 1:c
                divider = obj.Dividers(ii);
                divider.Position = positions(ii,:);
            end
            
            % Update pointer
            obj.onMouseMotion( ancestor( obj, 'figure' ), [] )
            
        end % redraw
        
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
        
    end % template methods
    
end % classdef