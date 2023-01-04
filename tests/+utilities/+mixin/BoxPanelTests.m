classdef ( Abstract ) BoxPanelTests < utilities.mixin.SharedPanelTests
    %BOXPANELTESTS Tests common to box panels.

    methods ( Test, Sealed )

        function tPassingShadowColorToConstructorIsCorrect( ...
                testCase, ConstructorName )

            % Assume that the component is not in a web figure.
            testCase.assumeGraphicsAreNotWebBased()

            % Create a component.
            expectedColor = [0, 0, 0];
            component = testCase.constructComponent( ...
                ConstructorName, 'ShadowColor', expectedColor );

            % Verify that the 'ShadowColor' property has been set
            % correctly.
            testCase.verifyEqual( component.ShadowColor, ...
                expectedColor, ...
                ['The ', ConstructorName, ' constructor has not set ', ...
                'the ''ShadowColor'' property correctly.'] )

        end % tPassingShadowColorToConstructorIsCorrect

        function tGettingAndSettingShadowColorWorksCorrectly( ...
                testCase, ConstructorName )

            % Assume that the component is not in a web figure.
            testCase.assumeGraphicsAreNotWebBased()

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Set the 'ShadowColor' property.
            expectedColor = [0, 0, 0];
            component.ShadowColor = expectedColor;

            % Verify that the value has been stored correctly.
            testCase.verifyEqual( component.ShadowColor, ...
                expectedColor, ...
                ['The ', ConstructorName, ' component has not ', ...
                'assigned the ''ShadowColor'' property correctly ', ...
                'when this property was set.'] )

        end % tGettingAndSettingShadowColorWorksCorrectly

        function tSettingEmptyMinimizeFcnIsWarningFree( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that setting the 'MinimizeFcn' to an empty value is
            % warning-free.
            setter = @() set( component, 'MinimizeFcn', [] );
            testCase.verifyWarningFree( setter, ...
                ['Setting the ''MinimizeFcn'' property of the ', ...
                ConstructorName, ' component was not warning-free.'] )

        end % tSettingEmptyMinimizeFcnIsWarningFree

        function tGettingTitleHeightReturnsFeasibleValue( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Obtain the 'TitleHeight' property.
            titleHeight = component.TitleHeight;

            % Verify the data type, size, and attributes of this value.
            testCase.verifyClass( titleHeight, 'double', ...
                ['The ''TitleHeight'' property of the ', ...
                ConstructorName, ' component is not a double value.'] )
            testCase.verifySize( titleHeight, [1, 1], ...
                ['The ''TitleHeight'' property of the ', ...
                ConstructorName, ' component is not a scalar value.'] )
            testCase.verifyGreaterThanOrEqual( titleHeight, 0, ...
                ['The ''TitleHeight'' property of the ', ...
                ConstructorName, ' component is not >= 0.'] )

        end % tGettingTitleHeightReturnsFeasibleValue

        function tSettingEmptyTitleAssignsCorrectValue( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Set the 'Title' property.
            expectedTitle = '';
            component.Title = expectedTitle;

            % Verify that it has been assigned correctly.
            testCase.verifyEqual( component.Title, expectedTitle, ...
                ['Setting an empty value for the ''Title'' property ', ...
                'of the ', ConstructorName, ' component did not ', ...
                'store the correct value.'] )

        end % tSettingEmptyTitleAssignsCorrectValue

        function tSelectionWhenMinimizedIsCorrect( ...
                testCase, ConstructorName )

            % Create a component with children.
            [component, kids] = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Minimize the component.
            component.Minimized = true;

            % Make a selection.
            selectionIndex = 2;
            component.Selection = selectionIndex;

            % Verify that the selected child is not visible.
            actualVisibility = char( kids(selectionIndex).Visible );
            testCase.verifyEqual( actualVisibility, 'off', ...
                ['Creating a ', ConstructorName, ' component in the ', ...
                'minimized state and making a selection did not ', ...
                'switch off the visibility of the selected child.'] )

        end % tSelectionWhenMinimizedIsCorrect

        function tAxesSelectionWhenMinimizedIsCorrect( ...
                testCase, ConstructorName )

            % Create a component with children.
            [component, kids] = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Add an axes.
            ax = axes( 'Parent', component, ...
                'ActivePositionProperty', 'outerposition' );

            % Minimize the component.
            component.Minimized = true;

            % Select the axes.
            component.Selection = length( kids ) + 1;

            % Verify that the selected child is not visible.
            actualVisibility = char( ax.Visible );
            actualContentsVisibility = char( ax.ContentsVisible );
            testCase.verifyEqual( actualVisibility, 'off', ...
                ['Creating a ', ConstructorName, ' component in the ', ...
                'minimized state and selecting an axes did not ', ...
                'switch off the axes'' ''Visible'' property.'] )
            testCase.verifyEqual( actualContentsVisibility, 'off', ...
                ['Creating a ', ConstructorName, ' component in the ', ...
                'minimized state and selecting an axes did not ', ...
                'switch off the axes'' ''ContentsVisible'' property.'] )

        end % tAxesSelectionWhenMinimizedIsCorrect

    end % methods ( Test, Sealed )

end % class