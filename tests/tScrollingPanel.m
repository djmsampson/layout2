classdef tScrollingPanel < sharedtests.SharedContainerTests
    %TSCROLLINGPANEL Tests for uix.ScrollingPanel.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uix.ScrollingPanel'}
        % Name-value pair arguments to use when testing the component's
        % constructor and get/set methods.
        NameValuePairs = {{
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Tag', 'Test', ...
            'Visible', 'on', ...
            'Padding', 5, ...
            'MouseWheelEnabled', 'on', ...
            'BackgroundColor', [1, 1, 0]
            }}
        % Whether to manually update the test figure's 'CurrentPoint'
        % property during the test. This is needed by tests for the mouse
        % wheel scroll callbacks.
        UpdateFigureCurrentPoint = {false, true}
        % Scrolling panel dimensions.
        ScrollingPanelDimension = {{'Width', 1000}, {'Height', 1000}}
    end % properties ( TestParameter )

    methods ( Test, Sealed )

        function tContentsPositionIsFullWhenPanelIsResized( ...
                testCase, ConstructorName )

            % Assume that the component is rooted.
            testCase.assumeGraphicsAreRooted()

            % Create a scrolling panel.
            scrollPanel = testCase.constructComponent( ...
                ConstructorName, 'Units', 'pixels' );

            % Add a child.
            c = uicontrol( 'Parent', scrollPanel, 'Units', 'pixels' );

            % Verify the initial position of the child.
            expectedPosition = [1, 1, scrollPanel.Position(3:4)];
            testCase.verifyEqual( c.Position, expectedPosition, ...
                ['Adding a child to ', ConstructorName, ' did not ', ...
                'set the child''s ''Position'' property correctly.'] )            

            % Update the 'Position' property of the scrolling panel.
            newDims = [0, -50];
            scrollPanel.Position = scrollPanel.Position + [0, 0, newDims];
            drawnow()
            
            % Verify that the child still fills the scroll panel.
            expectedPosition = [1, 1, scrollPanel.Position(3:4)];
            testCase.verifyEqual( c.Position, expectedPosition, ...
                'AbsTol', 1e-10, ...
                ['Changing the dimensions of the scrolling ', ...
                'panel did not update the ''Position'' property ', ...
                'of its contents correctly.'] )

        end % tContentsPositionIsFullWhenPanelIsResized

        function tContentsPositionUpdatesWhenPanelIsResized( ...
                testCase, ConstructorName )

            % Create a scrolling panel.
            testCase.assumeGraphicsAreRooted()
            scrollPanel = testCase.constructComponent( ...
                ConstructorName, ...
                'Units', 'pixels', ...
                'Position', [10, 10, 400, 400] );

            % Add a child.
            c = uicontrol( 'Parent', scrollPanel, 'Units', 'pixels' );

            % Set the dimensions.
            scrollPanel.Width = 500;
            scrollPanel.Height = 600;

            % Verify its initial position.
            scrollPanelDims = [scrollPanel.Width, scrollPanel.Height];
            expectedPosition = [1, -199, scrollPanelDims];
            testCase.verifyEqual( c.Position, expectedPosition, ...
                ['The initial position of a child of the scrolling ', ...
                'panel is incorrect.'] )

            % Run through a series of changes to the 'Position' property of
            % the scrolling panel.
            for width = [420, 380, 500]
                scrollPanel.Position(3) = width;
                testCase.verifyEqual( c.Position, expectedPosition, ...
                    ['Changing the width of the scrolling panel ', ...
                    'resulted in an incorrect position for its ', ...
                    'contents.'] )
            end % for

            % Change the 'HorizontalOffsets' property.
            scrollPanel.HorizontalOffset = 50;
            expectedPosition = [-19, -199, scrollPanelDims];
            testCase.verifyEqual( c.Position, expectedPosition, ...
                ['Changing the ''HorizontalOffsets'' property of ', ...
                'the scrolling panel resulted in an incorrect ', ...
                'position for its contents.'] )

            % Change the 'VerticalOffsets' property.
            scrollPanel.VerticalOffset = 50;
            expectedPosition = [-19, -148, scrollPanelDims];
            testCase.verifyEqual( c.Position, expectedPosition, ...
                ['Changing the ''VerticalOffsets'' property of ', ...
                'the scrolling panel resulted in an incorrect ', ...
                'position for its contents.'] )

        end % tContentsPositionUpdatesWhenPanelIsResized

        function tPanelRespectsMinimumWidths( testCase, ConstructorName )

            % Create a scrolling panel.
            testCase.assumeGraphicsAreRooted()
            scrollPanel = testCase.constructComponent( ...
                ConstructorName, ...
                'Units', 'pixels', ...
                'Position', [10, 10, 200, 200] );

            % Fill it with some controls.
            hBox = uix.HBoxFlex( 'Parent', scrollPanel, ...
                'Padding', 10, ...
                'Spacing', 10 );
            n = 4;
            b = gobjects( n, 1 );
            for k = 1 : n
                b(k) = uicontrol( 'Parent', hBox, 'String', k );
            end % for

            % Set dimensions.
            hBox.MinimumWidths(:) = 100;
            set( scrollPanel, 'MinimumWidth', 450, ...
                'MinimumHeight', 450 )

            % Verify the dimensions of the h-box.
            testCase.verifyEqual( hBox.Position(3:4), [450, 450], ...
                ['Setting the minimum dimensions of the scrolling ', ...
                'panel resulted in incorrect dimensions for its ', ...
                'contents.'] )

            % Verify the dimensions of the controls.
            for k = 1 : n
                testCase.verifyEqual( b(k).Position(3), 100, ...
                    ['Setting the minimum dimensions of the ', ...
                    'scrolling panel resulted in incorrect ', ...
                    'dimensions for its children''s children.'] )
            end % for

        end % tPanelRespectsMinimumWidths

        function tPanelRespectsMinimumHeights( testCase, ConstructorName )

            % Create a scrolling panel.
            testCase.assumeGraphicsAreRooted()
            scrollPanel = testCase.constructComponent( ...
                ConstructorName, ...
                'Units', 'pixels', ...
                'Position', [10, 10, 200, 200] );

            % Fill it with some controls.
            vBox = uix.VBoxFlex( 'Parent', scrollPanel, ...
                'Padding', 10, ...
                'Spacing', 10 );
            n = 4;
            b = gobjects( n, 1 );
            for k = 1 : n
                b(k) = uicontrol( 'Parent', vBox, 'String', k );
            end % for

            % Set dimensions.
            vBox.MinimumHeights(:) = 100;
            set( scrollPanel, 'MinimumWidth', 450, ...
                'MinimumHeight', 450 )

            % Verify the dimensions of the v-box.
            testCase.verifyEqual( vBox.Position(3:4), [450, 450], ...
                ['Setting the minimum dimensions of the scrolling ', ...
                'panel resulted in incorrect dimensions for its ', ...
                'contents.'] )

            % Verify the dimensions of the controls.
            for k = 1 : n
                testCase.verifyEqual( b(k).Position(4), 100, ...
                    ['Setting the minimum dimensions of the ', ...
                    'scrolling panel resulted in incorrect ', ...
                    'dimensions for its children''s children.'] )
            end % for

        end % tPanelRespectsMinimumHeights

        function tSettingEmptyParentFromNonEmptyIsWarningFree( ...
                testCase, ConstructorName )

            % Create a scrolling panel.
            testCase.assumeGraphicsAreRooted()
            scrollPanel = testCase.constructComponent( ConstructorName );
            testCase.addTeardown( @() delete( scrollPanel ) )

            % Verify that setting an empty value for the 'Parent' property
            % is warning-free.
            f = @() set( scrollPanel, 'Parent', [] );
            testCase.verifyWarningFree( f, ...
                ['The ', ConstructorName, ' component was not ', ...
                'warning-free when its ''Parent'' property was ', ...
                'changed from a nonempty value to an empty value.'] )

        end % tSettingEmptyParentFromNonEmptyIsWarningFree

        function tOffsetsAreCorrectInThePresenceOfSliders( ...
                testCase, ConstructorName )

            % Create a scrolling panel.
            testCase.assumeGraphicsAreRooted()
            scrollPanel = testCase.constructComponent( ConstructorName );

            % Add a control.
            uicontrol( 'Parent', scrollPanel, ...
                'Units', 'pixels', ...
                'Position', [1, 1, 1000, 1000] )

            % Adjust the dimensions.
            set( scrollPanel, 'Width', 600, 'Height', 600 )

            % Verify the offsets.
            testCase.verifyEqual( scrollPanel.VerticalOffset, 0, ...
                ['The ''VerticalOffset'' property on the ', ...
                'scrolling panel is not correct when a large ', ...
                'child was added and the dimensions of the panel ', ...
                'were large.'] )
            testCase.verifyEqual( scrollPanel.HorizontalOffset, 0, ...
                ['The ''HorizontalOffset'' property on the ', ...
                'scrolling panel is not correct when a large ', ...
                'child was added and the dimensions of the panel ', ...
                'were large.'] )

        end % tOffsetsAreCorrectInThePresenceOfSliders

        function tStringSupportForMouseWheelEnabled( ...
                testCase, ConstructorName )

            % Assume we are in R2016b or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2016b' )

            % Create a scrolling panel.
            testCase.assumeGraphicsAreRooted()
            scrollPanel = testCase.constructComponent( ConstructorName );

            % Verify that setting a string value is accepted.
            expectedValue = 'off';
            scrollPanel.MouseWheelEnabled = ...
                string( expectedValue ); %#ok<*STRQUOT>
            testCase.verifyEqual( scrollPanel.MouseWheelEnabled, ...
                expectedValue, ['The ', ConstructorName, ...
                ' component did not accept a string value for the ', ...
                '''MouseWheelEnabled''', ' property.'] )

        end % tStringSupportForMouseWheelEnabled

        function tOnSliderScrollingMethodRaisesScrollingEvent( ...
                testCase, ConstructorName )

            % Create a scrolling panel.
            scrollPanel = testCase.constructComponent( ConstructorName );

            % Create a listener to receive the event.
            eventRaised = false;
            event.listener( scrollPanel, 'Scrolling', @onSliderScrolling );

            function onSliderScrolling( ~, ~ )

                eventRaised = true;

            end % onSliderScrolling

            % Invoke the method.
            scrollPanel.onSliderScrolling()

            % Verify that the event was raised.
            testCase.verifyTrue( eventRaised, ...
                ['The ''onSliderScrolling'' method of ', ...
                ConstructorName, ' did not raise the ''Scrolling''', ...
                ' event.'] )

        end % tOnSliderScrollingMethodRaisesScrollingEvent

        function tOnSliderScrolledMethodRaisesScrolledEvent( ...
                testCase, ConstructorName )

            % Create a scrolling panel.
            scrollPanel = testCase.constructComponent( ConstructorName );

            % Create a listener to receive the event.
            eventRaised = false;
            event.listener( scrollPanel, 'Scrolled', @onSliderScrolled );

            function onSliderScrolled( ~, ~ )

                eventRaised = true;

            end % onSliderScrolled

            % Invoke the method.
            scrollPanel.onSliderScrolled()

            % Verify that the event was raised.
            testCase.verifyTrue( eventRaised, ...
                ['The ''onSliderScrolled'' method of ', ...
                ConstructorName, ' did not raise the ''Scrolled''', ...
                ' event.'] )

        end % tOnSliderScrolledMethodRaisesScrolledEvent

        function tOnMouseScrolledReturnsWhenNoSelectionExists( ...
                testCase, ConstructorName )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Create a scrolling panel.
            scrollPanel = testCase.constructComponent( ConstructorName );

            % Create a listener to receive the event.
            eventRaised = false;
            event.listener( scrollPanel, 'Scrolled', @onMouseScrolled );

            function onMouseScrolled( ~, ~ )

                eventRaised = true;

            end % onMouseScrolled

            % Invoke the method.
            scrollPanel.onMouseScrolled()

            % Verify that the event was not raised.
            testCase.verifyFalse( eventRaised, ...
                ['The ''onMouseScrolled'' method of ', ...
                ConstructorName, ' raised the ''Scrolled'' event', ...
                ' when the ''Selection'' property was 0.'] )

        end % tOnMouseScrolledReturnsWhenNoSelectionExists

        function tOnMouseScrolledRaisesScrolledEvent( ...
                testCase, ConstructorName, UpdateFigureCurrentPoint, ...
                ScrollingPanelDimension )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Create a scrolling panel.
            scrollPanel = testCase.constructComponent( ...
                ConstructorName, 'Units', 'normalized', ...
                'Position', [0.2, 0.2, 0.6, 0.6] );

            % Add a child and enable scrolling.
            uicontrol( scrollPanel )
            set( scrollPanel, ScrollingPanelDimension{:} )

            % Create a listener to receive the event.
            eventRaised = false;
            event.listener( scrollPanel, 'Scrolled', @onMouseScrolled );

            function onMouseScrolled( ~, ~ )

                eventRaised = true;

            end % onMouseScrolled

            % Move the mouse pointer over the scrolling panel.
            panelPosition = getpixelposition( scrollPanel );
            testFigure = ancestor( scrollPanel, 'figure' );
            figurePosition = testFigure.Position;
            r = groot();
            midPanelOffset = 0.5 * panelPosition(3:4);
            r.PointerLocation = figurePosition(1:2) + midPanelOffset;
            if UpdateFigureCurrentPoint
                testFigure.CurrentPoint = midPanelOffset;
            end % if
            drawnow()

            % Invoke the method with some fake event data.
            eventData.VerticalScrollCount = 0;
            eventData.VerticalScrollAmount = 1;
            scrollPanel.onMouseScrolled( [], eventData )

            % Verify that the event was raised.
            if UpdateFigureCurrentPoint
                testCase.verifyTrue( eventRaised, ...
                    ['The ''onMouseScrolled'' method of ', ...
                    ConstructorName, ' did not raise the ''Scrolled''', ...
                    ' event when a child was added to the component.'] )
            else
                testCase.verifyFalse( eventRaised, ...
                    ['The ''onMouseScrolled'' method of ', ...
                    ConstructorName, ' raised the ''Scrolled''', ...
                    ' event when a child was added to the component.'] )
            end % if

        end % tOnMouseScrolledRaisesScrolledEvent

    end % methods ( Test, Sealed )

end % classdef