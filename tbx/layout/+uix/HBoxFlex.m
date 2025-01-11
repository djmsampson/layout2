classdef HBoxFlex < uix.HBox & uix.mixin.Flex
    %uix.HBoxFlex  Flexible horizontal box
    %
    %  b = uix.HBoxFlex(p1,v1,p2,v2,...) constructs a flexible horizontal
    %  box and sets parameter p1 to value v1, etc.
    %
    %  A horizontal box lays out contents from left to right.  Users can
    %  resize contents by dragging the dividers.
    %
    %  See also: uix.VBoxFlex, uix.GridFlex, uix.HBox, uix.HButtonBox

    %  Copyright 2009-2025 The MathWorks, Inc.

    properties( Access = private )
        ColumnDividers = uix.Divider.empty( [0 1] ) % column dividers
        FrontDivider % front divider
        MousePressListener = event.listener.empty( [0 0] ) % mouse press listener
        MouseReleaseListener = event.listener.empty( [0 0] ) % mouse release listener
        MouseMotionListener = event.listener.empty( [0 0] ) % mouse motion listener
        ThemeListener = event.listener.empty( [0 0] ) % theme listener
        ActiveDivider = 0 % active divider index
        ActiveDividerPosition = [NaN NaN NaN NaN] % active divider position
        MousePressLocation = [NaN NaN] % mouse press location
    end

    methods

        function obj = HBoxFlex( varargin )
            %uix.HBoxFlex  Flexible horizontal box constructor
            %
            %  b = uix.HBoxFlex() constructs a flexible horizontal box.
            %
            %  b = uix.HBoxFlex(p1,v1,p2,v2,...) sets parameter p1 to value
            %  v1, etc.

            % Create front divider
            frontDivider = uix.Divider( 'Parent', obj, 'Visible', 'off' );

            % Store divider
            obj.FrontDivider = frontDivider;

            % Initialize decorations
            obj.updateBackgroundColor()

            % Create listeners
            addlistener( obj, 'BackgroundColor', 'PostSet', ...
                @obj.onBackgroundColorChanged );

            % Set Spacing property (may be overwritten by uix.set)
            obj.Spacing = 5;

            % Set properties
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end

        end % constructor

    end % structors

    methods( Access = protected )

        function onMousePress( obj, source, eventData )
            %onMousePress  Handler for WindowMousePress events

            % Check whether mouse is over a divider
            loc = find( obj.ColumnDividers.isMouseOver( eventData ) );
            if isempty( loc ), return, end

            % Capture state at button down
            divider = obj.ColumnDividers(loc);
            obj.ActiveDivider = loc;
            obj.ActiveDividerPosition = divider.Position;
            root = groot();
            obj.MousePressLocation = root.PointerLocation;

            % Make sure the pointer is appropriate
            obj.updateMousePointer( source, eventData );

            % Activate divider
            frontDivider = obj.FrontDivider;
            frontDivider.Position = divider.Position;
            divider.Visible = 'off';
            frontDivider.Parent = [];
            frontDivider.Parent = obj;
            frontDivider.Visible = 'on';

        end % onMousePress

        function onMouseRelease( obj, ~, ~ )
            %onMousePress  Handler for WindowMouseRelease events

            % Compute new positions
            loc = obj.ActiveDivider;
            if loc > 0
                root = groot();
                delta = root.PointerLocation(1) - obj.MousePressLocation(1);
                iw = loc;
                jw = loc + 1;
                ic = loc;
                jc = loc + 1;
                divider = obj.ColumnDividers(loc);
                contents = obj.Contents_;
                ip = uix.getPosition( contents(ic), 'pixels' );
                jp = uix.getPosition( contents(jc), 'pixels' );
                oldPixelWidths = [ip(3); jp(3)];
                minimumWidths = obj.MinimumWidths_(iw:jw,:);
                if delta < 0 % limit to minimum distance from left neighbor
                    delta = max( delta, minimumWidths(1) - oldPixelWidths(1) );
                else % limit to minimum distance from right neighbor
                    delta = min( delta, oldPixelWidths(2) - minimumWidths(2) );
                end
                oldWidths = obj.Widths_(iw:jw);
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
                obj.Widths_(iw:jw) = newWidths;
            else
                return
            end

            % Deactivate divider
            obj.FrontDivider.Visible = 'off';
            divider.Visible = 'on';

            % Reset state at button down
            obj.ActiveDivider = 0;
            obj.ActiveDividerPosition = [NaN NaN NaN NaN];
            obj.MousePressLocation = [NaN NaN];

            % Mark as dirty
            obj.Dirty = true;

        end % onMouseRelease

        function onMouseMotion( obj, source, eventData )
            %onMouseMotion  Handler for WindowMouseMotion events

            loc = obj.ActiveDivider;
            if loc == 0 % hovering, update pointer
                obj.updateMousePointer( source, eventData );
            else % dragging column divider
                root = groot();
                delta = root.PointerLocation(1) - obj.MousePressLocation(1);
                iw = loc;
                jw = loc + 1;
                ic = loc;
                jc = loc + 1;
                contents = obj.Contents_;
                ip = uix.getPosition( contents(ic), 'pixels' );
                jp = uix.getPosition( contents(jc), 'pixels' );
                oldPixelWidths = [ip(3); jp(3)];
                minimumWidths = obj.MinimumWidths_(iw:jw,:);
                if delta < 0 % limit to minimum distance from left neighbor
                    delta = max( delta, minimumWidths(1) - oldPixelWidths(1) );
                else % limit to minimum distance from right neighbor
                    delta = min( delta, oldPixelWidths(2) - minimumWidths(2) );
                end
                obj.FrontDivider.Position = ...
                    obj.ActiveDividerPosition + [delta 0 0 0];
            end

        end % onMouseMotion

        function onBackgroundColorChanged( obj, ~, ~ )
            %onBackgroundColorChanged  Handler for BackgroundColor changes

            obj.updateBackgroundColor()

        end % onBackgroundColorChanged

    end % event handlers

    methods( Access = protected )

        function redraw( obj )
            %redraw  Redraw contents
            %
            %  c.redraw() redraws the container c.

            % Call superclass method
            redraw@uix.HBox( obj )

            % Create or destroy column dividers
            b = numel( obj.ColumnDividers ); % current number of dividers
            c = max( [numel( obj.Widths_ )-1 0] ); % required number of dividers
            if b < c % create
                for ii = b+1:c
                    divider = uix.Divider( 'Parent', obj, ...
                        'Color', obj.BackgroundColor );
                    obj.ColumnDividers(ii,:) = divider;
                end
            elseif b > c % destroy
                % Destroy dividers
                delete( obj.ColumnDividers(c+1:b,:) )
                obj.ColumnDividers(c+1:b,:) = [];
                % Update pointer
                if c == 0 && strcmp( obj.Pointer, 'left' )
                    obj.unsetPointer()
                end
            end

            % Compute container bounds
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );

            % Retrieve size properties
            widths = obj.Widths_;
            minimumWidths = obj.MinimumWidths_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;

            % Compute column divider positions
            xColumnSizes = uix.calcPixelSizes( bounds(3), widths, ...
                minimumWidths, padding, spacing );
            xColumnPositions = [cumsum( xColumnSizes(1:c,:) ) + padding + ...
                spacing * transpose( 0:c-1 ) + 1, repmat( spacing, [c 1] )];
            yColumnPositions = [padding + 1, max( bounds(4) - 2 * padding, 1 )];
            yColumnPositions = repmat( yColumnPositions, [c 1] );
            columnPositions = [xColumnPositions(:,1), yColumnPositions(:,1), ...
                xColumnPositions(:,2), yColumnPositions(:,2)];

            % Position column dividers
            for jj = 1:c
                obj.ColumnDividers(jj).Position = columnPositions(jj,:);
            end

        end % redraw

        function reparent( obj, oldFigure, newFigure )
            %reparent  Reparent container
            %
            %  c.reparent(a,b) reparents the container c from the figure a
            %  to the figure b.

            % Update mouse listeners
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

            % Update theme listener
            if isempty( newFigure ) || ~any( strcmp( ...
                    {metaclass( newFigure ).EventList.Name}, 'ThemeChanged' ) )
                themeListener = event.listener.empty( [0 0] );
            else
                themeListener = event.listener( newFigure, ...
                    'ThemeChanged', @obj.onThemeChanged );
            end
            obj.ThemeListener = themeListener;

            % Call superclass method
            reparent@uix.HBox( obj, oldFigure, newFigure )

            % Update pointer
            if ~isempty( oldFigure ) && ~strcmp( obj.Pointer, 'unset' )
                obj.unsetPointer()
            end

        end % reparent

    end % template methods

    methods( Access = protected )

        function updateBackgroundColor( obj )
            %updateBackgroundColor  Update background color

            backgroundColor = obj.BackgroundColor;
            set( obj.ColumnDividers, 'Color', backgroundColor )
            if mean( backgroundColor ) > 0.5 % light
                obj.FrontDivider.Color = backgroundColor / 2; % darker
            else % dark
                obj.FrontDivider.Color = backgroundColor / 2 + 0.5; % lighter
            end

        end % updateBackgroundColor

        function updateMousePointer ( obj, source, eventData  )
            %updateMousePointer  Update mouse pointer

            oldPointer = obj.Pointer;
            if any( obj.ColumnDividers.isMouseOver( eventData ) )
                newPointer = 'left';
            else
                newPointer = 'unset';
            end
            switch newPointer
                case oldPointer % no change
                    % do nothing
                case 'unset' % change, unset
                    obj.unsetPointer()
                otherwise % change, set
                    obj.setPointer( source, newPointer )
            end

        end % updateMousePointer

    end % helper methods

end % classdef