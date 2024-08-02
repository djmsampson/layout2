classdef tTabPanelGestures < matlab.uitest.TestCase & ...
        glttestutilities.TestInfrastructure
    %TABPANELGESTURETESTS Interactive gesture tests for tab panels.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uiextras.TabPanel', 'uix.TabPanel'}
    end % properties ( TestParameter )

    methods ( Test, Sealed )

        function tClickingAnotherTabChangesSelection( testCase, ...
                ConstructorName )

            % Create a tab panel.
            tabPanel = testCase...
                .createTabPanelWithContents( ConstructorName );

            % Use the app testing framework to select the second tab. This
            % should change the Selection property.
            testCase.choose( tabPanel.TabGroup.Children(2) )

            % Verify that the Selection property has changed.
            testCase.verifyEqual( tabPanel.Selection, 2, ...
                ['Clicking on another tab did not change the ', ...
                '''Selection'' property to the expected value.'] )

        end % tClickingAnotherTabChangesSelection

        function tClickingAnotherTabInvokesCallback( testCase, ...
                ConstructorName )

            % Create a tab panel.
            tabPanel = testCase...
                .createTabPanelWithContents( ConstructorName );

            % Define the SelectionChangedFcn callback.
            tabPanel.SelectionChangedFcn = @onSelectionChanged;

            % Define shared variables for testing.
            callbackInvoked = false;
            eventData = struct();

            % Use the app testing framework to select the second tab. This
            % should invoke the callback.
            testCase.choose( tabPanel.TabGroup.Children(2) )
            testCase.verifyTrue( callbackInvoked, ...
                ['Clicking another tab did not invoke the ', ...
                '''SelectionChangedFcn'' callback.'] )
            testCase.verifyClass( eventData, ...
                'uix.SelectionChangedData', ...
                ['Clicking another tab did not pass event data of ', ...
                'type ''uix.SelectionChangedData''.'] )
            testCase.verifyEqual( eventData.OldValue, 1, ...
                ['Clicking another tab did not produce a value of 1', ...
                ' in the ''OldValue'' property of the event data.'] )
            testCase.verifyEqual( eventData.NewValue, 2, ...
                ['Clicking the second tab did not produce a value ', ...
                'of 2 in the ''NewValue'' property of the event data.'] )

            function onSelectionChanged( ~, e )

                callbackInvoked = true;
                eventData = e;

            end % onSelectionChanged

        end % tClickingAnotherTabInvokesCallback

        function tClickingSelectedTabDoesNotChangeSelection( testCase, ...
                ConstructorName )

            % Create a tab panel.
            tabPanel = testCase...
                .createTabPanelWithContents( ConstructorName );

            % Use the app testing framework to select the first tab. This
            % should not change the Selection property.
            testCase.choose( tabPanel.TabGroup.Children(1) )

            % Verify that the Selection property has not changed.
            testCase.verifyEqual( tabPanel.Selection, 1, ...
                ['Clicking on the currently selected tab incorrectly ', ...
                'changed the ''Selection'' property.'] )

        end % tClickingSelectedTabDoesNotChangeSelection

        function tClickingSelectedTabDoesNotInvokeCallback( testCase, ...
                ConstructorName )

            % Create a tab panel.
            tabPanel = testCase...
                .createTabPanelWithContents( ConstructorName );

            % Define the SelectionChangedFcn callback.
            tabPanel.SelectionChangedFcn = @onSelectionChanged;

            % Define a shared variable for testing.
            callbackInvoked = false;

            % Use the app testing framework to select the first tab. This
            % should not invoke the callback.
            testCase.choose( tabPanel.TabGroup.Children(1) )
            testCase.verifyFalse( callbackInvoked, ...
                ['Clicking on the currently selected tab incorrectly ', ...
                'called the ''SelectionChangedFcn'' callback.'] )

            function onSelectionChanged( ~, ~ )

                callbackInvoked = true;

            end % onSelectionChanged

        end % tClickingSelectedTabDoesNotInvokeCallback

        function tClickingDisabledTabDoesNotChangeSelection( testCase, ...
                ConstructorName )

            % Create a tab panel.
            tabPanel = testCase...
                .createTabPanelWithContents( ConstructorName );

            % Disable the second tab.
            tabPanel.TabEnables{2} = 'off';

            % Use the app testing framework to select the second tab. This
            % should not change the Selection property.
            testCase.choose( tabPanel.TabGroup.Children(2) )

            % Verify that the Selection property has not changed.
            testCase.verifyEqual( tabPanel.Selection, 1, ...
                ['Clicking on a disabled tab incorrectly ', ...
                'changed the ''Selection'' property.'] )

        end % tClickingDisabledTabDoesNotChangeSelection

        function tClickingDisabledTabDoesNotInvokeCallback( testCase, ...
                ConstructorName )

            % Create a tab panel.
            tabPanel = testCase...
                .createTabPanelWithContents( ConstructorName );

            % Disable the second tab.
            tabPanel.TabEnables{2} = 'off';

            % Define the SelectionChangedFcn callback.
            tabPanel.SelectionChangedFcn = @onSelectionChanged;

            % Define a shared variable for testing.
            callbackInvoked = false;

            % Use the app testing framework to select the second tab. This
            % should not invoke the callback.
            testCase.choose( tabPanel.TabGroup.Children(2) )
            testCase.verifyFalse( callbackInvoked, ...
                ['Clicking a disabled tab incorrectly ', ...
                'called the ''SelectionChangedFcn'' callback.'] )

            function onSelectionChanged( ~, ~ )

                callbackInvoked = true;

            end % onSelectionChanged

        end % tClickingDisabledTabDoesNotInvokeCallback

    end % methods ( Test, Sealed )

    methods ( Access = private )

        function tabPanel = createTabPanelWithContents( testCase, ...
                ConstructorName )

            % Assume that we are working in web graphics in at least
            % R2018a.
            testCase.assumeGraphicsAreWebBased()
            testCase.assumeMATLABVersionIsAtLeast( 'R2018a' )

            % Using the App Testing Framework in CI is supported from
            % R2023b onwards.
            if testCase.isCodeRunningOnCI()
                testCase.assumeMATLABVersionIsAtLeast( 'R2023b' )
            end % if

            % Create a tab panel in a grid layout. This is to work around
            % some sizing/positioning bugs in releases R2023a-R2023b.
            testFig = testCase.ParentFixture.Parent;
            testGrid = uigridlayout( testFig, [1, 1], "Padding", 0 );
            tabPanel = feval( ConstructorName, 'Parent', testGrid );
            testCase.addTeardown( @() delete( testGrid ) )
            testCase.addTeardown( @() delete( tabPanel ) )

            % Add controls.
            uicontrol( 'Parent', tabPanel )
            uicontrol( 'Parent', tabPanel )
            pause( 1 )

        end % createTabPanelWithContents

    end % methods ( Access = private )

end % classdef