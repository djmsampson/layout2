classdef tTabPanelGestures < matlab.uitest.TestCase & ...
        glttestutilities.TestInfrastructure
    %TABPANELGESTURETESTS Interactive gesture tests for tab panels.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uiextras.TabPanel', 'uix.TabPanel'}
    end % properties ( TestParameter )

    methods ( Test, Sealed )

        function tClickingTabPassesEventData( testCase, ConstructorName )

            % Assume that we are working in web graphics in at least
            % R2018a.
            testCase.assumeGraphicsAreWebBased()
            testCase.assumeMATLABVersionIsAtLeast( 'R2018a' )

            % Using the App Testing Framework in CI is supported from
            % R2023b onwards.
            if testCase.isCodeRunningOnCI()
                testCase.assumeMATLABVersionIsAtLeast( 'R2023b' )
            end % if

            % Create a tab panel in a grid layout.
            testFig = testCase.ParentFixture.Parent;
            testGrid = uigridlayout( testFig, [1, 1], 'Padding', 0 );
            tabPanel = feval( ConstructorName, 'Parent', testGrid );

            % Add two controls.
            uicontrol( 'Parent', tabPanel )
            uicontrol( 'Parent', tabPanel )

            % Create a listener.
            eventRaised = false;
            eventData = struct();
            event.listener( tabPanel, ...
                'SelectionChanged', @onSelectionChanged );

            % Use the app testing framework to click the first tab. This
            % should not change the selection.
            figureHeight = testFig.Position(4);
            tabWidth = tabPanel.TabWidth;
            testCase.press( testFig, [tabWidth-5, figureHeight-10] )
            testCase.verifyFalse( eventRaised, ...
                ['Clicking on the currently selected tab incorrectly ', ...
                'raised the ''SelectionChanged'' event.'] )

            % Use the app testing framework to click the second tab to
            % change the selection.
            testCase.press( testFig, [2*tabWidth-5, figureHeight-10] )

            % Verify that the event was raised.
            testCase.verifyTrue( eventRaised, ...
                ['Clicking on another tab to change the selection ', ...
                'did not raise the ''SelectionChanged'' event.'] )
            testCase.verifyClass( eventData, 'uix.SelectionData', ...
                ['Clicking on another tab to change the selection ', ...
                'did not pass event data of type ''uix.SelectionData''.'] )
            testCase.verifyEqual( eventData.OldValue, 1, ...
                ['Clicking on the second tab did not set the ', ...
                '''OldValue'' property in the event data to ', ...
                'the value 1.'] )
            testCase.verifyEqual( eventData.NewValue, 2, ...
                ['Clicking on the second tab did not set the ', ...
                '''NewValue'' property in the event data to ', ...
                'the value 2.'] )

            function onSelectionChanged( ~, e )

                eventRaised = true;
                eventData = e;

            end % onSelectionChanged

        end % tClickingTabPassesEventData

    end % methods ( Test, Sealed )

end % classdef