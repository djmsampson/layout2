classdef ( Abstract ) SharedFlexTests < sharedtests.SharedContainerTests
    %SHAREDFLEXTESTS Additional tests common to all flexible containers
    %(*.HBoxFlex, *.VBoxFlex, and *.GridFlex).

    properties ( TestParameter )
        % Sample flexible layout children sizes. We need all pairwise
        % combinations of relative and fixed sizes.
        ChildrenSizes = {[-1, -1], [200, -1], [-1, 200], [200, 200]}
    end % properties ( TestParameter )

    methods ( Test, Sealed )

        function tDraggingDividerIsWarningFree( ...
                testCase, ConstructorName, ChildrenSizes )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % If running in CI, assume we have at least R2023b.
            if testCase.isCodeRunningOnCI()
                testCase.assumeMATLABVersionIsAtLeast( 'R2023b' )
            end % if

            % Create a component.
            component = testCase.constructComponent( ConstructorName, ...
                'Spacing', 10 );

            % Add children.
            uicontrol( component )
            uicontrol( component )

            % Identify the dividers.
            c = hgGetTrueChildren( component );
            d = findobj( c, 'Tag', 'uix.Divider', 'Visible', 'on' );

            % Wait until the figure renders.
            testFig = ancestor( component, 'figure' );
            % Ensure the figure is not docked.
            testFig.WindowStyle = 'normal';
            isuifigure = isempty( get( testFig, 'JavaFrame_I' ) );
            if isuifigure
                pause( 5 )
            else
                pause( 1 )
            end % if

            % The direction of the drag operation will be either horizontal
            % or vertical. Set either the 'Widths' or 'Heights' property.
            isvbox = isa( component, 'uix.VBox' );
            if isvbox
                dragOffsets = {[0, 10], [0, -10]};
                component.Heights = ChildrenSizes;
            else
                % Offsets for h-boxes and grids.
                dragOffsets = {[10, 0], [-10, 0]};
                component.Widths = ChildrenSizes;
            end % if

            % Obtain a reference to the graphics root, for moving the mouse
            % pointer.
            r = groot();

            % Drag the divider in both directions.
            for offset = dragOffsets
                if isvbox
                    initialOffset = [d.Position(3)/2, 0];
                else
                    initialOffset = [0, d.Position(4)/2];
                end % if
                % Focus the figure.
                figure( testFig )
                % Move the mouse pointer.
                r.PointerLocation = testFig.Position(1:2) + ...
                    d.Position(1:2) + initialOffset;
                drawnow()
                testCase.verifyWarningFree( ...
                    @() dragger( offset{1} ), ...
                    ['Dragging a divider in the ', ConstructorName, ...
                    ' component was not warning-free.'] )
                pause( 0.5 )
            end % for

            function dragger( offset )

                % Simulate a click and drag operation on the divider.

                % Create the robot.
                bot = java.awt.Robot();

                % Click.
                bot.mousePress( java.awt.event.InputEvent.BUTTON1_MASK );
                pause( 0.5 )

                % Drag.
                for k = 1 : 10
                    pointerLoc = r.PointerLocation;
                    r.PointerLocation = pointerLoc + offset;
                    pause( 0.05 )
                end % for

                % Let go.
                bot.mouseRelease( java.awt.event.InputEvent.BUTTON1_MASK );

            end % dragger

        end % tDraggingDividerIsWarningFree

        function tClickingFlexibleLayoutIsWarningFree( ...
                testCase, ConstructorName )

            % Assume that the graphics are rooted and in the JavaScript
            % desktop.
            testCase.assumeGraphicsAreRooted()

            % If running in CI, assume we have at least R2023b.
            if testCase.isCodeRunningOnCI()
                testCase.assumeMATLABVersionIsAtLeast( 'R2023b' )
            end % if

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Move the mouse pointer.
            r = groot();
            testFig = ancestor( component, 'figure' );
            testFig.WindowStyle = 'normal';
            r.PointerLocation = testFig.Position(1:2) + ...
                getpixelcenter( component, true );

            % Focus the figure.
            figure( testFig )

            % Verify that clicking on it is warning-free.
            testCase.verifyWarningFree( @clicker, ...
                ['Clicking on a ', ConstructorName, ' component ', ...
                'was not warning-free.'] )

            function clicker()

                % Create the robot.
                bot = java.awt.Robot();

                % Click.
                bot.mousePress( java.awt.event.InputEvent.BUTTON1_MASK );
                pause( 0.25 )

                % Let go.
                bot.mouseRelease( java.awt.event.InputEvent.BUTTON1_MASK );

            end % clicker

        end % tClickingFlexibleLayoutIsWarningFree

        function tMouseOverDividerInDockedFigureUpdatesPointer( ...
                testCase, ConstructorName )

            % Exclude unrooted and web graphics.
            testCase.assumeGraphicsAreRooted()
            testCase.assumeGraphicsAreNotWebBased()

            % Exclude Mac OS.
            testCase.assumeNotMac()

            % If running in CI, assume we have at least R2023b.
            if testCase.isCodeRunningOnCI()
                testCase.assumeMATLABVersionIsAtLeast( 'R2023b' )
            end % if

            % Create the flexible container.
            component = testCase.constructComponent( ConstructorName, ...
                'Padding', 10, ...
                'Spacing', 10 );

            % Add controls to the component.
            for k = 1 : 9
                uicontrol( 'Parent', component );
            end % for

            % Dock the test figure and focus it.
            testFig = ancestor( component, 'figure' );
            testFig.WindowStyle = 'docked';
            windowStyleCleanup = onCleanup( ...
                @() set( testFig, 'WindowStyle', 'normal' ) );
            figure( testFig ) % bring to front

            % Ensure that grids are two-dimensional.
            if isa( component, 'uix.GridFlex' )
                component.Widths = [-1, -1, -1];
            end % if

            % Find the dividers.
            c = hgGetTrueChildren( component );
            d = findobj( c, 'Tag', 'uix.Divider', 'Visible', 'on' );

            % Move the mouse to the figure origin.
            figureOrigin = getFigureOrigin( testFig );
            moveMouseTo( figureOrigin )

            % Check that we start with an arrow pointer.
            testCase.verifyEqual( testFig.Pointer, 'arrow', ...
                ['The mouse pointer over the ', ConstructorName, ...
                ' component is not ''arrow'' when hovering over the ', ...
                'lower left corner of the component.'] )

            % Move the mouse over the dividers, and verify that the mouse
            % pointer updates.
            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.Matches

            for k = 1 : numel( d )
                moveMouseTo( figureOrigin + getpixelcenter( d(k), true ) )
                pointerFun = @() testFig.Pointer;
                testCase.verifyThat( pointerFun, ...
                    Eventually( Matches( '(left|right|top|bottom)' ) ), ...
                    ['The mouse pointer over the ' ConstructorName, ...
                    ' component did not update to ''left'', ''right''', ...
                    ', ''top'', or ''bottom'' when moved over the ', ...
                    'dividers in the flexible layout.'] )
            end % for

        end % tMouseOverDividerInDockedFigureUpdatesPointer

        function tClickingDividerIsWarningFree( testCase, ConstructorName )

            % This test is only for rooted components.
            testCase.assumeGraphicsAreRooted()

            % If running in CI, assume we have at least R2023b.
            if testCase.isCodeRunningOnCI()
                testCase.assumeMATLABVersionIsAtLeast( 'R2023b' )
            end % if

            % Create the layout and add children.
            [component, dividers] = createFlexibleLayoutWithChildren( ...
                testCase, ConstructorName );

            % Move the mouse to the center of a divider.
            testFig = ancestor( component, 'figure' );
            figure( testFig ) % Focus the figure
            figureOrigin = getFigureOrigin( testFig );
            dividerCenter = figureOrigin + ...
                getpixelcenter( dividers(1), true );
            moveMouseTo( dividerCenter )

            % Verify that clicking the divider is warning-free.
            testCase.verifyWarningFree( @clicker, ...
                ['Clicking the divider in a ', ConstructorName, ...
                ' component was not warning-free.'] )

            function clicker()

                % Create the robot.
                bot = java.awt.Robot();

                % Click.
                bot.mousePress( java.awt.event.InputEvent.BUTTON1_MASK );
                pause( 0.5 )

                % Let go.
                bot.mouseRelease( java.awt.event.InputEvent.BUTTON1_MASK );
                pause( 0.5 )

            end % clicker

        end % tClickingDividerIsWarningFree

        function tMousePointerUpdatesOnFlexChange( ...
                testCase, ConstructorName )

            % This test is only for rooted components in the JavaScript
            % desktop environment.
            testCase.assumeGraphicsAreRooted()
            testCase.assumeJavaScriptDesktop()

            % Create the component
            testFig = testCase.ParentFixture.Parent;
            testFig.WindowStyle = 'normal';

            % Determine the layout based on the component type.
            switch ConstructorName
                case {'uiextras.VBoxFlex', 'uix.VBoxFlex'}
                    childType = 'VBoxFlex';
                    parentType = 'HBox';
                case {'uiextras.HBoxFlex', 'uix.HBoxFlex'}
                    childType = 'HBoxFlex';
                    parentType = 'VBox';
                case {'uiextras.GridFlex', 'uix.GridFlex'}
                    childType = 'GridFlex';
                    parentType = 'Grid';
            end % switch/case

            % Create the parent component, add two child layouts, then
            % populate the child layouts with buttons.
            parentComponent = uix.(parentType)( 'Parent', testFig );
            numChildren = 9;

            kid1 = uix.(childType)( 'Parent', parentComponent, ...
                'Spacing', 10 );
            buttons1 = gobjects( 1, numChildren );
            for k = 1:numChildren
                buttons1(k) = uicontrol( 'Parent', kid1 );
            end % for

            kid2 = uix.(childType)( 'Parent', parentComponent, ...
                'Spacing', 10 );
            buttons2 = gobjects( 1, numChildren );
            for k = 1:numChildren
                buttons2(k) = uicontrol( 'Parent', kid2 );
            end % for

            % Ensure that grids are two-dimensional.
            if strcmp( childType, 'GridFlex' )
                parentComponent.Widths = -1;
                kid1.Widths = [-1, -1, -1];
                kid2.Widths = [-1, -1, -1];
            end % if

            % Find the dividers.
            allKids1 = hgGetTrueChildren( kid1 );
            div1 = findobj( allKids1, 'Tag', 'uix.Divider', ...
                'Visible', 'on' );
            allKids2 = hgGetTrueChildren( kid2 );
            div2 = findobj( allKids2, 'Tag', 'uix.Divider', ...
                'Visible', 'on' );

            % Highlight the test elements.
            buttons1(1).BackgroundColor = 'r';
            buttons2(2).BackgroundColor = 'g';
            div1(end).BackgroundColor = 'c';
            div2(end).BackgroundColor = 'm';

            % Move the mouse over a button.
            figureOrigin = getFigureOrigin( testFig );
            buttonCenter = figureOrigin + ...
                getpixelcenter( buttons1(1), true );
            figure( testFig ) % Focus the figure
            moveMouseTo( buttonCenter )
            pause( 1 )
            testCase.verifyEqual( testFig.Pointer, 'arrow', ...
                ['The mouse pointer did not change to ''arrow''', ...
                ' when moved over a button in a ', ConstructorName, ...
                ' component.'] )

            % Move the mouse over a divider.
            dividerCenter = figureOrigin + ...
                getpixelcenter( div1(end), true );
            moveMouseTo( dividerCenter )
            pause( 1 )
            testCase.verifyMatches( testFig.Pointer, ...
                '(left|right|top|bottom)', ...
                ['The mouse pointer did not change to ''left'', ', ...
                '''right'', ''top'', or ''bottom'' when moved over ', ...
                'a divider in a ', ConstructorName, ' component.'] )

            % Move the mouse over the matching divider of the other
            % flexible component.
            dividerCenter = figureOrigin + ...
                getpixelcenter( div2(end), true );
            moveMouseTo( dividerCenter )
            pause( 1 )
            testCase.verifyMatches( testFig.Pointer, ...
                '(left|right|top|bottom)', ...
                ['The mouse pointer did not change to ''left'', ', ...
                '''right'', ''top'', or ''bottom'' when moved over ', ...
                'a divider in a ', ConstructorName, ' component.'] )

            % Move the mouse back to a button.
            buttonCenter = figureOrigin + ...
                getpixelcenter( buttons2(2), true );
            moveMouseTo( buttonCenter )
            pause( 1 )
            testCase.verifyMatches( testFig.Pointer, 'arrow', ...
                ['The mouse pointer did not change to ''arrow''', ...
                ' when moved over a button in a ', ConstructorName, ...
                ' component.'] )

            % Repeat the test in reverse.
            dividerCenter = figureOrigin + ...
                getpixelcenter( div2(end), true );
            moveMouseTo( dividerCenter )
            pause( 1 )
            testCase.verifyMatches( testFig.Pointer, ...
                '(left|right|top|bottom)', ...
                ['The mouse pointer did not change to ''left'', ', ...
                '''right'', ''top'', or ''bottom'' when moved over ', ...
                'a divider in a ', ConstructorName, ' component.'] )
            dividerCenter = figureOrigin + ...
                getpixelcenter( div1(end), true );
            moveMouseTo( dividerCenter )
            pause( 1 )
            testCase.verifyMatches( testFig.Pointer, ...
                '(left|right|top|bottom)', ...
                ['The mouse pointer did not change to ''left'', ', ...
                '''right'', ''top'', or ''bottom'' when moved over ', ...
                'a divider in a ', ConstructorName, ' component.'] )
            buttonCenter = figureOrigin + ...
                getpixelcenter( buttons1(1), true );
            moveMouseTo( buttonCenter )
            pause( 1 )
            testCase.verifyEqual( testFig.Pointer, 'arrow', ...
                ['The mouse pointer did not change to ''arrow''', ...
                ' when moved over a button in a ', ConstructorName, ...
                ' component.'] )

        end % tMousePointerUpdatesOnFlexChange

        function tMousePointerUpdatesOverDivider( ...
                testCase, ConstructorName )

            % This test is only for rooted components in the JavaScript
            % Desktop.
            testCase.assumeGraphicsAreRooted()

            % If running in CI, assume we have at least R2023b and we're
            % running in the JavaScript desktop.
            if testCase.isCodeRunningOnCI()
                testCase.assumeJavaScriptDesktop()
            end % if

            % Create the layout and add children.
            [component, dividers] = createFlexibleLayoutWithChildren( ...
                testCase, ConstructorName );

            % Move the mouse to the center of a divider.
            testFig = ancestor( component, 'figure' );
            figure( testFig ) % Focus the figure
            figureOrigin = getFigureOrigin( testFig );
            dividerCenter = figureOrigin + ...
                getpixelcenter( dividers(1), true );
            moveMouseTo( dividerCenter - [10, 10] )
            pause( 0.5 )
            moveMouseTo( dividerCenter )
            pause( 0.5 )
            testCase.verifyMatches( testFig.Pointer, ...
                '(left|right|top|bottom)', ...
                ['The mouse pointer did not change to ''left'', ', ...
                '''right'', ''top'', or ''bottom'' when moved over ', ...
                'a divider in a ', ConstructorName, ' component.'] )

        end % tMousePointerUpdatesOverDivider

        function tDeletingChildRestoresPointer( testCase, ConstructorName )

            % This test is for rooted components.
            testCase.assumeGraphicsAreRooted()

            % If running in CI, assume we have at least R2023b.
            if testCase.isCodeRunningOnCI()
                testCase.assumeMATLABVersionIsAtLeast( 'R2023b' )
            end % if

            % Create a component with children.
            [component, dividers] = testCase...
                .createFlexibleLayoutWithChildren( ConstructorName );

            % Increase the spacing.
            component.Spacing = 10;

            % Move the mouse over a divider.
            r = groot();
            testFig = ancestor( component, 'figure' );
            figure( testFig ) % Focus the figure
            r.PointerLocation = testFig.Position(1:2) + ...
                dividers(1).Position(1:2);
            pause( 0.5 )

            % Delete all the children.
            delete( component.Children )
            pause( 0.5 )

            % Verify that the figure's 'Pointer' property has been
            % restored.
            testCase.verifyEqual( testFig.Pointer, 'arrow', ...
                ['Deleting the children of a ', ConstructorName, ...
                ' component did not restore the figure''s ', ...
                '''Pointer'' property.'] )

        end % tDeletingChildRestoresPointer

        function tReparentingLayoutRestoresPointer( ...
                testCase, ConstructorName )

            % This test is for rooted components.
            testCase.assumeGraphicsAreRooted()

            % If running in CI, assume we have the JavaScript desktop.
            if testCase.isCodeRunningOnCI()
                testCase.assumeJavaScriptDesktop()
            end % if

            % Create a component with children.
            [component, dividers] = testCase...
                .createFlexibleLayoutWithChildren( ConstructorName );

            % Increase the spacing.
            component.Spacing = 10;

            % Move the mouse over a divider.
            r = groot();
            testFig = ancestor( component, 'figure' );
            figure( testFig ) % Focus the figure
            r.PointerLocation = testFig.Position(1:2) + ...
                dividers(1).Position(1:2);
            pause( 0.5 )

            % Reparent the layout.
            component.Parent = [];

            % Verify that the figure's 'Pointer' property has been
            % restored.
            testCase.verifyEqual( testFig.Pointer, 'arrow', ...
                ['Reparenting a ', ConstructorName, ...
                ' component did not restore the figure''s ', ...
                '''Pointer'' property.'] )

        end % tReparentingLayoutRestoresPointer

    end % methods ( Test, Sealed )

    methods ( Test, Sealed )

        function tSettingBackgroundColorUpdatesDividers( ...
                testCase, ConstructorName )

            % Create the layout and add children.
            [component, dividers] = createFlexibleLayoutWithChildren( ...
                testCase, ConstructorName );

            % Set the background color.
            newColor = [1, 0, 0];
            component.BackgroundColor = newColor;

            % Verify that the dividers have been updated.
            diagnostic = ['Setting the ''BackgroundColor'' of ', ...
                'a ', ConstructorName, ' component did not ', ...
                'update the color of the dividers correctly.'];
            for k = 1 : numel( dividers )
                testCase.verifyEqual( dividers(k).BackgroundColor, ...
                    newColor, diagnostic )
            end % for

        end % tSettingBackgroundColorUpdatesDividers

        function tTurningOffDividerMarkingsSetsDividerMarkingsProperty( ...
                testCase, ConstructorName )

            % Create the layout and add children.
            [component, ~] = createFlexibleLayoutWithChildren( ...
                testCase, ConstructorName );

            % Switch off the divider markings.
            component.DividerMarkings = 'off';
            testCase.verifyEqual( component.DividerMarkings, 'off' );

            % Switch off the divider markings.
            component.DividerMarkings = 'on'; % no effect
            testCase.verifyEqual( component.DividerMarkings, 'off' );

        end % tTurningOffDividerMarkingsSetsDividerMarkingsProperty

        function tReparentingToEmptyFigureIsWarningFree( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that setting its 'Parent' property to [] is
            % warning-free.
            reparenter = @() set( component, 'Parent', [] );
            testCase.verifyWarningFree( reparenter, ...
                ['Reparenting the ', ConstructorName, ' component to ', ...
                'an empty value was not warning-free.'] )

        end % tReparentingToEmptyFigureIsWarningFree

        function tStringSupportForDividerMarkings( ...
                testCase, ConstructorName )

            % Assume we are in R2016b or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2016b' )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Set the 'DividerMarkings' property.
            component.DividerMarkings = string( 'off' ); %#ok<*STRQUOT>

            % Verify that this syntax is supported.
            testCase.verifyEqual( component.DividerMarkings, 'off', ...
                ['The ', ConstructorName, ' component did not ', ...
                'accept a string value for the ''DividerMarkings''', ...
                ' property.'] )

        end % tStringSupportForDividerMarkings

    end % methods ( Test, Sealed )

    methods ( Access = private )

        function [component, dividers] = ...
                createFlexibleLayoutWithChildren( ...
                testCase, ConstructorName )

            % Create the component and add children.
            component = testCase.constructComponent( ConstructorName, ...
                'Spacing', 10 );
            numChildren = 4;
            buttons = gobjects( 1, numChildren );
            for k = 1:numChildren
                buttons(k) = uicontrol( 'Parent', component );
            end % for

            % Ensure that we have multiple rows and columns if the
            % component is a grid.
            if isa( component, 'uix.Grid' )
                component.Widths = [-1, -1];
            end % if

            % Find the dividers.
            allKids = hgGetTrueChildren( component );
            dividers = findobj( allKids, 'Tag', 'uix.Divider', ...
                'Visible', 'on' );

        end % createFlexibleLayoutWithChildren

    end % methods ( Access = private )

end % classdef

function p = getFigureOrigin( f )
%GETFIGUREORIGIN Get figure origin location onscreen.
%
%  p = getFigureOrigin( f ) returns the location onscreen of the
%  bottom-left corner of the figure f.
%
%  The method used is unreliable if the display resolution or
%  scaling is changed after MATLAB starts.

if ~strcmp( f.WindowStyle, 'docked' )

    % Undocked figures return their position as expected.
    p = f.Position(1:2);

else
    % Docked figures are problematic and require special treatment to find
    % their correct position.

    % Pause duration during screen sweep.
    t = 0.1;

    % Focus the figure.
    figure( f )
    pause( t )

    % As the mouse moves, update the pointer location.
    li = event.listener( f, 'WindowMouseMotion', @onMouseMotion );

    % Determine the monitor positions, sorting by primary monitor.
    r = groot();
    m = r.MonitorPositions;
    m = sortrows( m, [-1, -2] );

    % Initialize the position.
    p = [NaN, NaN];

    % Sweep monitors.
    for ii = 1:size( m, 1 )
        nx = ceil( m(ii,3)/f.Position(3) ) + 1;
        ny = ceil( m(ii,4)/f.Position(4) ) + 1;
        % Create a search grid.
        x = linspace( m(ii,1), m(ii,1) + m(ii,3), 2*nx );
        y = linspace( m(ii,2), m(ii,2) + m(ii,4), 2*ny );
        % Sweep vertically.
        for kk = 1:numel( y )
            % Sweep horizontally.
            for jj = 1:numel( x )
                % Move the pointer.
                r.PointerLocation = [x(jj), y(kk)];
                % Wait.
                pause( t )
                % Stop if we've found the figure.
                if ~all( isnan( p ) ), return, end
            end % for
        end % for
    end % for

end % if

    function onMouseMotion( ~, e )

        p = r.PointerLocation - e.Point + [1, 1];

    end % onMouseMotion

end % getFigureOrigin

function c = getpixelcenter( varargin )
%GETPIXELCENTER Get center of object in pixel units.

p = getpixelposition( varargin{:} );
c = p(1:2) + p(3:4)/2;

end % getpixelcenter

function moveMouseTo( new )
%MOVEMOUSETO Move mouse pointer to new position.
%
%  moveMouseTo( p ) moves the mouse to the location p.

% Number of steps in transition.
n = 5;

% Pause duration.
t = 0.1;

r = groot();
old = r.PointerLocation;
x = linspace( old(1), new(1), n );
y = linspace( old(2), new(2), n );
for k = 2 : n
    r.PointerLocation = [x(k), y(k)];
    pause( t )
end % for

end % moveMouseTo