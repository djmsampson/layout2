classdef EmptyTests < utilities.mixin.TestInfrastructure
    %EMPTYTESTS Tests common to uiextras.Empty and uix.Empty.

    properties ( TestParameter, Abstract )
        % The constructor name, or class, of the component under test.
        ConstructorName
    end % properties ( TestParameter, Abstract )

    methods ( Test, Sealed )

        function tConstructorIsWarningFree( testCase, ConstructorName )

            creator = @constructEmptyComponent;
            testCase.verifyWarningFree( creator, ...
                [ConstructorName, ' is not warning-free when ', ...
                'constructed with input arguments ''Parent'', [].'] )

            function constructEmptyComponent()

                emptyComponent = feval( ConstructorName, 'Parent', [] );
                emptyCleanup = onCleanup( @() delete( emptyComponent ) );

            end % constructEmptyComponent

        end % tConstructorIsWarningFree

        function tAutoParentBehaviorIsCorrect( testCase, ConstructorName )

            % This test only applies to uiextras.Empty.
            isuiextras = strcmp( ConstructorName, 'uiextras.Empty');
            testCase.assumeTrue( isuiextras, ...
                ['Testing auto-parenting behavior applies to ', ...
                'uiextras.Empty but not uix.Empty.'] )

            % Create a new figure.
            newFig = figure();
            testCase.addTeardown( @() delete( newFig ) )

            % Instantiate the component, without specifying the parent.
            component = feval( ConstructorName );
            testCase.addTeardown( @() delete( component ) )

            % Verify that the parent of the component is the new figure we
            % created above.
            testCase.verifySameHandle( component.Parent, newFig, ...
                'uiextras.Empty has not auto-parented correctly.' )

        end % tAutoParentBehaviorIsCorrect

        function tConstructorWithInputArgumentsIsCorrect( ...
                testCase, ConstructorName )

            % Specify some possible input arguments.
            newFig = figure();
            testCase.addTeardown( @() delete( newFig ) );
            emptyInputArguments = {'Parent', newFig, ...
                'Tag', 'Empty Component Test'};

            % Create the empty component.
            emptyComponent = feval( ConstructorName, ...
                emptyInputArguments{:} );
            testCase.addTeardown( @() delete( emptyComponent ) );

            % Verify that the properties are correct.
            testCase.verifySameHandle( emptyComponent.Parent, newFig, ...
                ['The ', ConstructorName, ' constructor has not ', ...
                'assigned the ''Parent'' input argument correctly.'] )
            testCase.verifyEqual( emptyComponent.Tag, ...
                emptyInputArguments{4}, ...
                ['The ', ConstructorName, ' constructor has not ', ...
                'assigned the ''Tag'' input argument correctly.'] )

        end % tConstructorWithInputArgumentsIsCorrect

        function tEmptyComponentOccupiesCorrectPosition( ...
                testCase, ConstructorName )

            % Create an HBox containing an empty component and a uicontrol.
            testFig = testCase.FigureFixture.Figure;
            hBox = uiextras.HBox( 'Parent', testFig, ...
                'Units', 'pixels', ...
                'Position', [1, 1, 500, 500] );
            testCase.addTeardown( @() delete( hBox ) )
            emptyComponent = feval( ConstructorName, 'Parent', hBox );
            uicontrol( 'Parent', hBox )

            % Verify that the empty component's position is correct.
            testCase.verifyEqual( emptyComponent.Position, ...
                hBox.Position .* [1, 1, 0.5, 1], ...
                [ConstructorName, ' does not have the correct ', ...
                'position when added to an HBox with another control.'] )

        end % tEmptyComponentOccupiesCorrectPosition

        function tEmptyComponentColorMatchesParentColor( ...
                testCase, ConstructorName )

            % Create an HBox with a specific color.
            testFig = testCase.FigureFixture.Figure;
            requiredColor = [1, 0, 0];
            hBox = uiextras.HBox( 'Parent', testFig, ...
                'BackgroundColor', requiredColor );
            testCase.addTeardown( @() delete( hBox ) )

            % Create an empty component in the HBox.
            emptyComponent = feval( ConstructorName, 'Parent', hBox );

            % Verify that the 'BackgroundColor' property has been updated.
            testCase.verifyEqual( emptyComponent.BackgroundColor, ...
                requiredColor, ...
                [ConstructorName, ' has not updated its ', ...
                '''BackgroundColor'' property when added to an HBox ', ...
                'with a non-default BackgroundColor.'] )

        end % tEmptyComponentColorMatchesParentColor

        function tColorUpdatesWhenParentColorIsChanged( ...
                testCase, ConstructorName )

            % Create an HBox and add an empty component.
            testFig = testCase.FigureFixture.Figure;
            hBox = uiextras.HBox( 'Parent', testFig );
            testCase.addTeardown( @() delete( hBox ) )
            emptyComponent = feval( ConstructorName, 'Parent', hBox );

            % Change the color of the HBox.
            requiredColor = [1, 0, 0];
            hBox.BackgroundColor = requiredColor;

            % Verify that the empty component has been updated.
            testCase.verifyEqual( emptyComponent.BackgroundColor, ...
                requiredColor, ...
                [ConstructorName, ' has not updated its ', ...
                '''BackgroundColor'' property when its parent''s ', ...
                '''BackgroundColor'' property was changed.'] )

        end % tColorUpdatesWhenParentColorIsChanged

        function tColorUpdatesWhenComponentIsReparented( ...
                testCase, ConstructorName )

            % Create an HBox with a specific color.
            testFig = testCase.FigureFixture.Figure;
            requiredColor = [1, 0, 0];
            hBox = uiextras.HBox( 'Parent', testFig, ...
                'BackgroundColor', requiredColor );
            testCase.addTeardown( @() delete( hBox ) )

            % Create an unparented empty component.
            emptyComponent = feval( ConstructorName, 'Parent', [] );

            % Reparent the empty component.
            emptyComponent.Parent = hBox;

            % Verify that the empty component has been updated.
            testCase.verifyEqual( emptyComponent.BackgroundColor, ...
                requiredColor, ...
                [ConstructorName, ' has not updated its ', ...
                '''BackgroundColor'' property when it was reparented.'] )

        end % tColorUpdatesWhenComponentIsReparented

    end % methods ( Test, Sealed )


end % class