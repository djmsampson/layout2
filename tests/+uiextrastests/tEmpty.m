classdef tEmpty < matlab.unittest.TestCase
    %TEMPTY Tests for uiextras.Empty. Empty is not a container, so does not
    %utilize the shared container tests.

    properties ( ClassSetupParameter )
        % Graphics parent type ('legacy'|'web'|'unrooted'). See also
        % parentTypes.
        ParentType = utilities.parentTypes()
    end % properties ( ClassSetupParameter )

    properties
        % Figure fixture, providing the top-level parent
        % graphics object for the containers during the test procedures.
        % See also the ParentType class setup parameter and
        % matlab.unittest.fixtures.FigureFixture.
        FigureFixture
        % Current GUI Layout Toolbox tracking status, to be restored after
        % the tests run. Tracking is disabled whilst the tests run.
        CurrentTrackingStatus = 'unset'
    end % properties

    methods ( TestClassSetup )

        function assumeMinimumMATLABVersion( testCase )

            % This collection of tests requires MATLAB R2014b or later.
            utilities.assumeMATLABVersionIsAtLeast( testCase, 'R2014b' )

        end % assumeMinimumMATLABVersion

        function setupToolboxPath( testCase )

            % Apply a path fixture for the GUI Layout Toolbox main folder.
            utilities.applyGLTFolderFixture( testCase )

        end % setupToolboxPath

        function setupFigureFixture( testCase, ParentType )

            % Apply a custom fixture to provide the top-level parent
            % graphics object for the GUI Layout Toolbox components during
            % the test procedures.
            utilities.applyFigureFixture( testCase, ParentType )

        end % setupFigureFixture

        function disableTrackingDuringTests( testCase )

            % Disable GUI Layout Toolbox tracking during the test
            % procedures.
            utilities.disableTracking( testCase )

        end % disableTracking

    end % methods ( TestClassSetup )

    methods ( Test )

        function tConstructorIsWarningFree( testCase )

            creator = @constructEmptyComponent;
            testCase.verifyWarningFree( creator, ...
                ['uiextras.Empty is not free of warnings when ', ...
                'constructed with input arguments ''Parent'', [].'] )

            function constructEmptyComponent()

                emptyComponent = uiextras.Empty( 'Parent', [] );
                emptyCleanup = onCleanup( @() delete( emptyComponent ) );

            end % constructEmptyComponent

        end % tConstructorIsWarningFree

        function tAutoParentBehaviorIsCorrect( testCase )

            % Create a new figure.
            newFig = figure();
            testCase.addTeardown( @() delete( newFig ) )

            % Instantiate the component, without specifying the parent.
            component = uiextras.Empty();
            testCase.addTeardown( @() delete( component ) )

            % Verify that the parent of the component is the new figure we
            % created above.
            testCase.verifySameHandle( component.Parent, newFig, ...
                'uiextras.Empty has not auto-parented correctly.' )

        end % tAutoParentBehaviorIsCorrect

        function tConstructorWithInputArgumentsIsCorrect( testCase )

            % Specify some possible input arguments.
            newFig = figure();
            testCase.addTeardown( @() delete( newFig ) );
            emptyInputArguments = {'Parent', newFig, ...
                'Tag', 'Empty Component Test'};

            % Create the empty component.
            emptyComponent = uiextras.Empty( emptyInputArguments{:} );
            testCase.addTeardown( @() delete( emptyComponent ) );

            % Verify that the properties are correct.
            testCase.verifySameHandle( emptyComponent.Parent, newFig, ...
                ['The uiextras.Empty constructor has not assigned ', ...
                'the ''Parent'' input argument correctly.'] )
            testCase.verifyEqual( emptyComponent.Tag, ...
                emptyInputArguments{4}, ...
                ['The uiextras.Empty constructor has not assigned ', ...
                'the ''Tag'' input argument correctly.'] )

        end % tConstructorWithInputArgumentsIsCorrect

        function tEmptyComponentOccupiesCorrectPosition( testCase )

            % Create an HBox containing an empty component and a uicontrol.
            testFig = testCase.FigureFixture.Figure;
            hBox = uiextras.HBox( 'Parent', testFig, ...
                'Units', 'pixels', ...
                'Position', [1, 1, 500, 500] );
            testCase.addTeardown( @() delete( hBox ) )
            emptyComponent = uiextras.Empty( 'Parent', hBox );
            uicontrol( 'Parent', hBox )

            % Verify that the empty component's position is correct.
            testCase.verifyEqual( emptyComponent.Position, ...
                hBox.Position .* [1, 1, 0.5, 1], ...
                ['uiextras.Empty does not have the correct position ', ...
                'when added to an HBox with another control.'] )

        end % tEmptyComponentOccupiesCorrectPosition

        function tEmptyComponentColorMatchesParentColor( testCase )

            % Create an HBox with a specific color.
            testFig = testCase.FigureFixture.Figure;
            requiredColor = [1, 0, 0];
            hBox = uiextras.HBox( 'Parent', testFig, ...
                'BackgroundColor', requiredColor );
            testCase.addTeardown( @() delete( hBox ) )

            % Create an empty component in the HBox.
            emptyComponent = uiextras.Empty( 'Parent', hBox );

            % Verify that the 'BackgroundColor' property has been updated.
            testCase.verifyEqual( emptyComponent.BackgroundColor, ...
                requiredColor, ...
                ['uiextras.Empty has not updated its ', ...
                '''BackgroundColor'' property when added to an HBox ', ...
                'with a non-default BackgroundColor.'] )

        end % tEmptyComponentColorMatchesParentColor

        function tColorUpdatesWhenParentColorIsChanged( testCase )

            % Create an HBox and add an empty component.
            testFig = testCase.FigureFixture.Figure;
            hBox = uiextras.HBox( 'Parent', testFig );
            testCase.addTeardown( @() delete( hBox ) )
            emptyComponent = uiextras.Empty( 'Parent', hBox );

            % Change the color of the HBox.
            requiredColor = [1, 0, 0];
            hBox.BackgroundColor = requiredColor;

            % Verify that the empty component has been updated.
            testCase.verifyEqual( emptyComponent.BackgroundColor, ...
                requiredColor, ...
                ['uiextras.Empty has not updated its ', ...
                '''BackgroundColor'' property when its parent''s ', ...
                '''BackgroundColor'' property was changed.'] )

        end % tColorUpdatesWhenParentColorIsChanged

        function tColorUpdatesWhenComponentIsReparented( testCase )

            % Create an HBox with a specific color.
            testFig = testCase.FigureFixture.Figure;
            requiredColor = [1, 0, 0];
            hBox = uiextras.HBox( 'Parent', testFig, ...
                'BackgroundColor', requiredColor );
            testCase.addTeardown( @() delete( hBox ) )

            % Create an unparented empty component.
            emptyComponent = uiextras.Empty( 'Parent', [] );

            % Reparent the empty component.
            emptyComponent.Parent = hBox;

            % Verify that the empty component has been updated.
            testCase.verifyEqual( emptyComponent.BackgroundColor, ...
                requiredColor, ...
                ['uiextras.Empty has not updated its ', ...
                '''BackgroundColor'' property when it was reparented.'] )

        end % tColorUpdatesWhenComponentIsReparented

    end % methods ( Test )

end % class