classdef tTabPanelGestures < matlab.uitest.TestCase & ...
        glttestutilities.TestInfrastructure
    %TABPANELGESTURETESTS Interactive gesture tests for tab panels.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uiextras.TabPanel', 'uix.TabPanel'}
    end % properties ( TestParameter )

    methods ( Test, Sealed, TestTags = {'IncompatibleWithHeadlessMode'} )

        function tClickingTabPassesEventData( testCase, ConstructorName )

            % Assume that we are in the web graphics case.
            testCase.assumeGraphicsAreWebBased()

            % Create a tab panel.
            testFig = testCase.ParentFixture.Parent;
            tabPanel = feval( ConstructorName, 'Parent', testFig );

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

    end % methods ( Test, Sealed, TestTags = {'IncompatibleWithHeadlessMode'} )

end % class