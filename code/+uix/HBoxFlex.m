classdef HBoxFlex < uix.HBox
    
    properties
        Dividers = uix.Divider.empty( [0 1] )
        FrontDivider
        AncestryObserver
        AncestryListener
        LocationObserver
        MousePressListener
        MouseReleaseListener
        MouseMotionListener
        OldMouseOver = false
        ActiveDivider = 0
        MousePressLocation = [NaN NaN]
        OldDividerPosition = [NaN NaN NaN NaN]
        OldPointer = 'unset'
    end
    
    methods
        
        function obj = HBoxFlex( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.HBox( notmypv{:} );
            
            % Create front divider
            divider = uix.Divider( 'Parent', obj, ...
                'Orientation', 'vertical', 'Markings', 'on', ...
                'Visible', 'off' );
            
            % Store front divider
            obj.FrontDivider = divider;
            
            % Create observers
            ancestryObserver = uix.AncestryObserver( obj );
            
            % Store observers
            obj.AncestryObserver = ancestryObserver;
            
            % Create listeners
            ancestryListener = event.listener( ancestryObserver, ...
                'AncestryChange', @obj.onAncestryChange );
            
            % Store listeners
            obj.AncestryListener = ancestryListener;
            
            % Force ancestry change
            obj.onAncestryChange()
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods( Access = protected )
        
        function onChildAdded( obj, source, eventData )
            
            % Add divider if there will be more than one child
            if numel( obj.Contents_ ) > 0
                divider = uix.Divider( 'Parent', obj, ...
                    'Orientation', 'vertical', 'Markings', 'on' );
                obj.Dividers(end+1,:) = divider;
            end
            
            % Bring front divider to the front
            frontDivider = obj.FrontDivider;
            frontDivider.Parent = [];
            frontDivider.Parent = obj;
            
            % Call superclass method
            onChildAdded@uix.HBox( obj, source, eventData );
            
            % Update pointer
            obj.onMouseMotion()
            
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData )
            
            % Do nothing if container is being deleted
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            % Remove divider if there is more than one child
            if numel( obj.Contents_ ) > 1
                loc = max( find( obj.Contents == eventData.Child ) - 1, 1 );
                delete( obj.Dividers(loc) )
                obj.Dividers(loc,:) = [];
            end
            
            % Call superclass method
            onChildRemoved@uix.HBox( obj, source, eventData );
            
            % Update pointer
            obj.onMouseMotion()
            
        end % onChildRemoved
        
        function onAncestryChange( obj, ~, ~ )
            
            % Create fresh location observer
            ancestryObserver = obj.AncestryObserver;
            ancestors = ancestryObserver.Ancestors;
            locationObserver = uix.LocationObserver( ancestors );
            
            % Create fresh mouse listeners
            figure = ancestryObserver.Figure;
            if isempty( figure )
                mousePressListener = event.listener.empty( [0 0] );
                mouseReleaseListener = event.listener.empty( [0 0] );
                mouseMotionListener = event.listener.empty( [0 0] );
            else
                mousePressListener = event.listener( figure, ...
                    'WindowMousePress', @obj.onMousePress );
                mouseReleaseListener = event.listener( figure, ...
                    'WindowMouseRelease', @obj.onMouseRelease );
                mouseMotionListener = event.listener( figure, ...
                    'WindowMouseMotion', @obj.onMouseMotion );
            end
            
            % Replace existing observers and listeners
            obj.LocationObserver = locationObserver;
            obj.MousePressListener = mousePressListener;
            obj.MouseReleaseListener = mouseReleaseListener;
            obj.MouseMotionListener = mouseMotionListener;
            
        end % onAncestryChange
        
        function onMousePress( obj, ~, ~ )
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            % Check whether mouse is over a divider
            [tf, loc] = obj.isMouseOverDivider();
            if ~tf, return, end
            
            % Capture relevant state
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
            
            % Check whether a divider is active
            loc = obj.ActiveDivider;
            if loc == 0, return, end
            
            % Deactivate divider
            obj.FrontDivider.Visible = 'off';
            obj.Dividers(loc).Visible = 'on';
            
            % Reposition contents
            delta = obj.getMouseDragLength();
            oldWidths = obj.Widths(loc:loc+1);
            oldPixelWidths = obj.PixelWidths(loc:loc+1);
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
            obj.Widths(loc:loc+1) = newWidths;
            
            % Reset button down event and divider state
            obj.ActiveDivider = 0;
            obj.MousePressLocation = [NaN NaN];
            obj.OldDividerPosition = [NaN NaN NaN NaN];
            
        end % onMouseRelease
        
        function onMouseMotion( obj, ~, ~ )
            
            loc = obj.ActiveDivider;
            if loc == 0 % hovering
                isOver = obj.isMouseOverDivider();
                wasOver = obj.OldMouseOver;
                if wasOver ~= isOver
                    figure = obj.AncestryObserver.Figure;
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
        
    end % event handlers
    
    methods( Access = protected )
        
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
        
        function delta = getMouseDragLength( obj )
            %getMouseDragLength  Get length of current mouse drag
            %
            %  d = c.getMouseDragLength() returns the drag length, that is
            %  the distance between the button down location and the
            %  current pointer location in the direction of dragging, in
            %  pixels.  Note that a divider cannot be dragged beyond 1
            %  pixel from its neighbors.
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            loc = obj.ActiveDivider;
            assert( loc ~= 0, 'uix:InvalidOperation', ...
                'Divider is not being dragged.' )
            delta = ROOT.PointerLocation(1) - obj.MousePressLocation(1);
            if delta < 0 % limit to 1 pixel from left neighbor
                delta = max( delta, 1-obj.PixelWidths(loc) );
            else % limit to 1 pixel from right neighbor
                delta = min( delta, obj.PixelWidths(loc+1)-1 );
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
        
    end % methods
    
end % classdef