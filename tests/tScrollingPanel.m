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
            'Continuous', 'off', ...
            'BackgroundColor', [1, 1, 0], ...
            'Heights', double.empty( 0, 1 ), ...
            'MinimumHeights', double.empty( 0, 1 ), ...
            'VerticalOffsets', double.empty( 0, 1 ), ...
            'VerticalSteps', double.empty( 0, 1 ), ...
            'Widths', double.empty( 0, 1 ), ...
            'MinimumWidths', double.empty( 0, 1 ), ...
            'HorizontalOffsets', double.empty( 0, 1 ), ...
            'HorizontalSteps', double.empty( 0, 1 )
            }}
        % Properties accepting both a row vector and a column vector.
        VectorAcceptingProperties = {
            'VerticalSteps', ...
            'HorizontalSteps'
            }
        % Whether to manually update the test figure's 'CurrentPoint'
        % property during the test. This is needed by tests for the mouse
        % wheel scroll callbacks.
        UpdateFigureCurrentPoint = {false, true}
        % Scrolling panel dimensions.
        ScrollingPanelDimension = {{'Widths', 1000}, {'Heights', 1000}}
    end % properties ( TestParameter )

    methods ( Test, Sealed )

        function tSettingPropertyAsRowStoresValue( ...
                testCase, ConstructorName, VectorAcceptingProperties )

            % Create the component with children.
            [component, kids] = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Set the property as a row vector.
            value = 5 * ones( 1, numel( kids ) );
            component.(VectorAcceptingProperties) = value;

            % Verify that a column vector has been stored.
            testCase.verifyEqual( ...
                component.(VectorAcceptingProperties), ...
                transpose( value ), ...
                ['Setting the ''', VectorAcceptingProperties, ...
                ''' property of the ', ConstructorName, ...
                ' component as a row vector did ', ...
                'not store the value as a column vector.'] )

        end % tSettingPropertyAsRowStoresValue

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
            scrollPanel.Widths = 500;
            scrollPanel.Heights = 600;

            % Verify its initial position.
            scrollPanelDims = [scrollPanel.Widths, scrollPanel.Heights];
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
            scrollPanel.HorizontalOffsets = 50;
            expectedPosition = [-19, -199, scrollPanelDims];
            testCase.verifyEqual( c.Position, expectedPosition, ...
                ['Changing the ''HorizontalOffsets'' property of ', ...
                'the scrolling panel resulted in an incorrect ', ...
                'position for its contents.'] )

            % Change the 'VerticalOffsets' property.
            scrollPanel.VerticalOffsets = 50;
            expectedPosition = [-19, -149, scrollPanelDims];
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
            set( scrollPanel, 'MinimumWidths', 450, ...
                'MinimumHeights', 450 )

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
            set( scrollPanel, 'MinimumWidths', 450, ...
                'MinimumHeights', 450 )

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
            set( scrollPanel, 'Widths', 600, 'Heights', 600 )

            % Verify the offsets.
            testCase.verifyEqual( scrollPanel.VerticalOffsets, 0, ...
                ['The ''VerticalOffsets'' property on the ', ...
                'scrolling panel is not correct when a large ', ...
                'child was added and the dimensions of the panel ', ...
                'were large.'] )
            testCase.verifyEqual( scrollPanel.HorizontalOffsets, 0, ...
                ['The ''HorizontalOffsets'' property on the ', ...
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

        function tOnSliderScrollingMethodRaisesScrolledEvent( ...
                testCase, ConstructorName )

            % Create a scrolling panel.
            scrollPanel = testCase.constructComponent( ConstructorName );

            % Create a listener to receive the event.
            eventRaised = false;
            event.listener( scrollPanel, 'Scrolled', @onSliderScrolling );

            function onSliderScrolling( ~, ~ )

                eventRaised = true;

            end % onSliderScrolling

            % Do not fire event when scrolling.
            scrollPanel.Continuous = 'off';

            % Invoke the method.
            scrollPanel.onSliderScrolling()

            % Verify that the event not raised.
            testCase.verifyFalse( eventRaised, ...
                ['The ''onSliderScrolled'' method of ', ...
                ConstructorName, ' raised the ''Scrolled''', ...
                ' event with continuous scrolling ''off''.'] )

            % Fire event when scrolling.
            scrollPanel.Continuous = 'on';

            % Invoke the method.
            scrollPanel.onSliderScrolling()

            % Verify that the event was raised.
            testCase.verifyTrue( eventRaised, ...
                ['The ''onSliderScrolled'' method of ', ...
                ConstructorName, ' did not raise the ''Scrolled''', ...
                ' event with continuous scrolling ''on''.'] )

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

        function tSettingMouseWheelEnabledErrorsForInvalidInput( ...
                testCase, ConstructorName )

            % Construct a component.
            component = testCase.constructComponent( ConstructorName );

            % Attempt to set an invalid value for 'MouseWheelEnabled'.
            f = @() set( component, 'MouseWheelEnabled', false );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['Setting the ''MouseWheelEnabled'' property of the ', ...
                ConstructorName, ' component did not error when an ', ...
                'invalid value was specified.'] )

        end % tSettingMouseWheelEnabledErrorsForInvalidInput

        function tSettingContinuousErrorsForInvalidInput( ...
                testCase, ConstructorName )

            % Construct a component.
            component = testCase.constructComponent( ConstructorName );

            % Attempt to set an invalid value for 'Continuous'.
            f = @() set( component, 'Continuous', false );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['Setting the ''Continuous'' property of the ', ...
                ConstructorName, ' component did not error when an ', ...
                'invalid value was specified.'] )

        end % tSettingContinuousErrorsForInvalidInput

        function tSettingEmptyPropertyValuesStoresValuesCorrectly( ...
                testCase, ConstructorName )

            % Create a scrolling panel (with no content).
            component = testCase.constructComponent( ConstructorName );

            % List the properties.
            propertyList = {'Heights', 'MinimumHeights', ...
                'Widths', 'MinimumWidths', ...
                'VerticalSteps', 'VerticalOffsets', ...
                'HorizontalSteps', 'HorizontalOffsets'};

            % Iterate over the properties.
            expected = double.empty( 0, 1 );
            for propertyIdx = 1 : numel( propertyList )
                % Extract the current property.
                currentProperty = propertyList{propertyIdx};
                % Set the empty value.
                component.(currentProperty) = [];
                % Verify that the property has been stored correctly.
                testCase.verifyEqual( component.(currentProperty), ...
                    expected, ['Setting an empty value ([]) to the ''', ...
                    currentProperty, ''' property of the ', ...
                    ConstructorName, ' component did not store the ', ...
                    'expected value (double.empty( 0, 1 ).)'] )
            end % for

        end % tSettingEmptyPropertyValuesStoresValuesCorrectly

        function tSettingMouseWheelEnabledWhenUnrootedStoresValue( ...
                testCase, ConstructorName )

            % Assume that we're in the case that 'Parent' is [].
            testCase.assumeComponentHasEmptyParent()

            % Create a scrolling panel.
            component = testCase.constructComponent( ConstructorName );

            % Set the 'MouseWheelEnabled' property and verify that the
            % property has been stored correctly.
            diagnostic = ['Setting the ''MouseWheelEnabled'' ', ...
                'property of the ', ConstructorName, ...
                ' component when the ''Parent'' property is [] did ', ...
                'not store the value.'];
            if strcmp( component.MouseWheelEnabled, 'on' )
                expected = 'off';
                component.MouseWheelEnabled = expected;
                actual = char( component.MouseWheelEnabled );
                testCase.verifyEqual( actual, expected, diagnostic )
            else
                expected = 'on';
                component.MouseWheelEnabled = expected;
                actual = char( component.MouseWheelEnabled );
                testCase.verifyEqual( actual, expected, diagnostic )
            end % if

        end % tSettingMouseWheelEnabledWhenUnrootedStoresValue

        function tScrollingMouseWithNoScrollbarsRaisesEvent( testCase, ...
                ConstructorName )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Construct a component.
            component = testCase.constructComponent( ConstructorName );

            % Ensure that no scrollbars are present.
            set( component, 'Height', -1, 'Width', -1 )

            % Create a listener to receive the event.
            eventRaised = false;
            event.listener( component, 'Scrolled', @onScrolled );

            % Move the mouse pointer over the scrolling panel.
            panelPosition = getpixelposition( component );
            testFigure = ancestor( component, 'figure' );
            figurePosition = testFigure.Position;
            r = groot();
            midPanelOffset = 0.5 * panelPosition(3:4);
            r.PointerLocation = figurePosition(1:2) + midPanelOffset;

            % Invoke the onMouseScrolled method.
            component.onMouseScrolled()

            % Verify that the event was raised.
            testCase.verifyTrue( eventRaised, ['Scrolling the ', ...
                'mouse when the ', ConstructorName, ' component has ', ...
                'no scrollbars did not raise the ''Scrolled'' event.'] )

            function onScrolled( ~, ~ )

                eventRaised = true;

            end % onScrolled

        end % tScrollingMouseWithNoScrollbarsRaisesEvent

        function tRedrawEdgeCasesAreWarningFree( testCase, ...
                ConstructorName )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Create a scrolling panel.
            component = testCase.constructComponent( ConstructorName );

            % Set the panel Height and Width properties.
            set( component, 'Height', 1000, 'Width', 1000 )

            % Test several edge cases obtained by varying the slider size.
            for sliderSize = [0, 0.001, 0.01, 0.1, 1, 5, 20, 50, 500, 5000]

                % Override the slider size property.
                component.SliderSize = sliderSize;

                % Verify that a redraw is warning-free.
                f = @() axes( 'Parent', component );
                testCase.verifyWarningFree( f, ['Adding an axes to ', ...
                    'the ', ConstructorName, ' component with a ', ...
                    '''SliderSize'' value of ', num2str( sliderSize ), ...
                    ' was not warning-free.'] )

                % Tidy up.
                delete( component.Children )

            end % for

        end % tRedrawEdgeCasesAreWarningFree

        function tMouseScrolledCallbackReturnsWhenMouseIsNotOverPanel( ...
                testCase, ConstructorName )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Create a scrolling panel.
            component = testCase.constructComponent( ConstructorName );

            % Create a listener to receive the event.
            eventRaised = false;
            event.listener( component, 'Scrolled', @onScrolled );

            % Set the figure's 'CurrentPoint' property to be outside the
            % scrolling panel.
            testFigure = ancestor( component, 'figure' );
            figure( testFigure ) % Bring to front
            figurePosition = testFigure.Position;
            outsideMargin = 10;

            % Left outside.
            testFigure.CurrentPoint = [(-1) * outsideMargin, ...
                figurePosition(4)/2];
            component.onMouseScrolled()

            % Verify that the event was not raised.
            testCase.verifyFalse( eventRaised, ['Scrolling the ', ...
                'mouse outside the ', ConstructorName, ' component ', ...
                'has raised the ''Scrolled'' event.'] )

            % Top outside.
            testFigure.CurrentPoint = [figurePosition(3)/2, ...
                figurePosition(4) + outsideMargin];
            component.onMouseScrolled()

            % Verify that the event was not raised.
            testCase.verifyFalse( eventRaised, ['Scrolling the ', ...
                'mouse outside the ', ConstructorName, ' component ', ...
                'has raised the ''Scrolled'' event.'] )

            % Right outside.
            testFigure.CurrentPoint = [figurePosition(3) + ...
                outsideMargin, figurePosition(4)/2];
            component.onMouseScrolled()

            % Verify that the event was not raised.
            testCase.verifyFalse( eventRaised, ['Scrolling the ', ...
                'mouse outside the ', ConstructorName, ' component ', ...
                'has raised the ''Scrolled'' event.'] )

            % Bottom outside.
            testFigure.CurrentPoint = [figurePosition(3)/2, ...
                (-1) * outsideMargin];
            component.onMouseScrolled()

            function onScrolled( ~, ~ )

                eventRaised = true;

            end % onScrolled

        end % tMouseScrolledCallbackReturnsWhenMouseIsNotOverPanel

        function tSettingPaddingUpdatesContentsPosition( testCase, ...
                ConstructorName )

            % Assume that we're in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Create a scrolling panel.
            component = testCase.constructComponent( ConstructorName );

            % Add a control.
            button = uicontrol( 'Parent', component );

            % With zero padding, the control's dimensions should equal the
            % scrolling panel's dimensions.
            component.Padding = 0;

            % Read off the positions.
            buttonPosition = getpixelposition( button, true );
            panelPosition = getpixelposition( component, true );
            buttonDimensions = buttonPosition(3:4);
            panelDimensions = panelPosition(3:4);

            % Check.
            testCase.verifyEqual( buttonDimensions, panelDimensions, ...
                ['The dimensions of a button in a ', ConstructorName, ...
                ' component were not correct when the ''Padding''', ...
                ' property has value 0.'] )

            % Adjust the 'Padding' property and repeat the test.
            padding = 20;
            component.Padding = padding;

            % Read off the positions.
            buttonPosition = getpixelposition( button, true );
            panelPosition = getpixelposition( component, true );
            buttonDimensions = buttonPosition(3:4);
            panelDimensions = panelPosition(3:4);
            expectedButtonDimensions = panelDimensions - 2 * padding;

            % Check.
            testCase.verifyEqual( buttonDimensions, ...
                expectedButtonDimensions, ...
                ['The dimensions of a button in a ', ConstructorName, ...
                ' component were not correct when the ''Padding''', ...
                ' property has value ', num2str( padding ), '.'] )

        end % tSettingPaddingUpdatesContentsPosition

        function tSettingPaddingWithScrollbarsUpdatesContentsPosition( ...
                testCase, ConstructorName )

            % Assume that we're in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Create a scrolling panel.
            component = testCase.constructComponent( ConstructorName );

            % Add a control.
            button = uicontrol( 'Parent', component );

            % Adjust sizes to enable scrollbars.
            h = 1000;
            w = 1000;
            set( component, 'Height', h, 'Width', w )

            % With zero padding, verify the pixel position of the button.
            component.Padding = 0;

            % Read off the positions.
            figurePosition = component.Parent.Position;
            buttonPosition = getpixelposition( button, true );
            panelPosition = getpixelposition( component, true );
            figureDimensions = figurePosition(3:4);
            panelDimensions = panelPosition(3:4);

            % Check the component dimensions.
            testCase.verifyEqual( panelDimensions, figureDimensions, ...
                ['The dimensions of the ', ConstructorName, ...
                ' component were not correct when the ''Height''', ...
                ' was ', num2str( h ), ', the ''Width'' was ', ...
                num2str( w ), ', and the ''Padding'' was zero.'] )

            % Check the button position.
            expectedButtonPosition = [1, panelDimensions(2)-h+1, w, h];
            testCase.verifyEqual( buttonPosition, ...
                expectedButtonPosition, ['The dimensions of a button ', ...
                'placed in a ', ConstructorName, ' component were ', ...
                'not correct when the ''Height'' was ', num2str( h ), ...
                ', the ''Width'' was ', num2str( w ), ', and the ', ...
                '''Padding'' was zero.'] )

            % Adjust the 'Padding' property and repeat the test.
            padding = 20;
            component.Padding = padding;

            % Read off the positions.
            figurePosition = component.Parent.Position;
            buttonPosition = getpixelposition( button, true );
            panelPosition = getpixelposition( component, true );
            figureDimensions = figurePosition(3:4);
            panelDimensions = panelPosition(3:4);

            % Check the component dimensions.
            testCase.verifyEqual( panelDimensions, figureDimensions, ...
                ['The dimensions of the ', ConstructorName, ...
                ' component were not correct when the ''Height''', ...
                ' was ', num2str( h ), ', the ''Width'' was ', ...
                num2str( w ), ', and the ''Padding'' was ', ...
                num2str( padding ), '.'] )

            % Check the button position.
            expectedButtonPosition = ...
                [1+padding, panelDimensions(2)-h-padding+1, w, h];
            testCase.verifyEqual( buttonPosition, ...
                expectedButtonPosition, ['The dimensions of a button ', ...
                'placed in a ', ConstructorName, ' component were ', ...
                'not correct when the ''Height'' was ', num2str( h ), ...
                ', the ''Width'' was ', num2str( w ), ', and the ', ...
                '''Padding'' was ', num2str( padding ), '.'] )

        end % tSettingPaddingWithScrollbarsUpdatesContentsPosition

    end % methods ( Test, Sealed )

end % classdef