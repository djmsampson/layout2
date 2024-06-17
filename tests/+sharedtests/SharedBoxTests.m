classdef ( Abstract ) SharedBoxTests < sharedtests.SharedContainerTests
    %LAYOUTTESTS Additional tests common to all layout containers
    %(*.HBox, *.VBox, *.HBoxFlex, *.VBoxFlex).

    properties ( TestParameter, Abstract )
        % Box dimension name-value pairs used when testing the component's
        % get/set methods.
        BoxDimensionNameValuePairs
    end % properties ( TestParameter, Abstract )

    properties ( Access = protected )
        % Layout orientation ('horizontal'|'vertical').
        Orientation
        % Dimension to adjust ('Widths'|'Heights').
        Dimension
        % Minimum dimension to adjust ('MinimumWidths'|'MinimumHeights').
        MinimumDimension
        % Dimension index, used in accessing positions (3|4).
        DimensionIndex
        % Expected axes positions.
        ExpectedAxesPositions
    end % properties ( Access = protected )

    methods ( TestClassSetup )

        function setOrientationRelatedProperties( testCase )

            % Determine the layout orientation based on the constructor
            % name. Set the other orientation-related properties.
            if ~isempty( cell2mat( strfind( ...
                    testCase.ConstructorName, 'HBox' ) ) )
                testCase.Orientation = 'horizontal';
                testCase.Dimension = 'Widths';
                testCase.MinimumDimension = 'MinimumWidths';
                testCase.DimensionIndex = 3;
                testCase.ExpectedAxesPositions = {[1, 1, 250, 500], ...
                    [251, 1, 250, 500]};
            elseif ~isempty( cell2mat( strfind( ...
                    testCase.ConstructorName, 'VBox' ) ) )
                testCase.Orientation = 'vertical';
                testCase.Dimension = 'Heights';
                testCase.MinimumDimension = 'MinimumHeights';
                testCase.DimensionIndex = 4;
                testCase.ExpectedAxesPositions = {[1, 251, 500, 250], ...
                    [1, 1, 500, 250]};
            end % if

        end % setOrientationRelatedProperties

    end % methods ( TestClassSetup )

    methods ( Test, Sealed )

        function tResizingParentFigurePreservesElementSizes( ...
                testCase, ConstructorName )

            % Exclude the unrooted case.
            testCase.assumeGraphicsAreRooted()

            % Create the component and resize its parent figure.
            [component, expectedSizes] = testCase...
                .createComponentWithChildrenAndResizeFigure( ...
                ConstructorName );

            % Extract the widths of the component's contents.
            actualSizes = NaN( 1, 4 );
            for k = 1 : 4
                actualSizes(k) = component...
                    .Contents(k).Position(testCase.DimensionIndex);
            end % for

            % Verify that the sizes are correct.
            testCase.verifyEqual( actualSizes, expectedSizes, ...
                ['Resizing the parent figure of the ', ...
                ConstructorName, ' component resulted in incorrect ', ...
                'sizes for the component''s contents.'] )

        end % tResizingParentFigurePreservesElementSizes

        function tAxesArePositionedCorrectly( testCase, ConstructorName )

            % Exclude the unrooted case.
            testCase.assumeGraphicsAreRooted()

            % Create the component.
            component = testCase.constructComponent( ConstructorName, ...
                'Units', 'pixels', ...
                'Position', [1, 1, 500, 500], ...
                'Spacing', 0 );

            % Add two axes.
            ax(1) = axes( 'Parent', component, ...
                'ActivePositionProperty', 'OuterPosition', ...
                'Units', 'pixels' );
            ax(2) = axes( 'Parent', component, ...
                'ActivePositionProperty', 'Position', ...
                'Units', 'pixels' );

            % Verify that the axes' sizes are correct.
            testCase.verifyEqual( ax(1).OuterPosition, ...
                testCase.ExpectedAxesPositions{1}, ...
                ['An axes added to the ', ConstructorName, ...
                ' was not positioned correctly.'] )
            testCase.verifyEqual( ax(2).Position, ...
                testCase.ExpectedAxesPositions{2}, ...
                ['An axes added to the ', ConstructorName, ...
                ' was not positioned correctly.'] )

        end % tAxesArePositionedCorrectly

        function tMinimumSizesAreRespected( testCase, ConstructorName )

            % Exclude the unrooted case.
            testCase.assumeGraphicsAreRooted()

            % Create the component.
            component = testCase.constructComponent( ConstructorName, ...
                'Units', 'pixels', ...
                'Position', [1, 1, 1000, 500] );

            % Add controls.
            numButtons = 5;
            buttons = gobjects( numButtons, 1 );
            for k = 1 : numButtons
                buttons(k) = uicontrol( 'Parent', component );
            end % for

            % Adjust the 'Widths' or 'Heights' and 'MinimumWidths' or
            % 'MinimumHeights' properties, respectively.
            component.(testCase.Dimension) = [100, 100, -1, -1, -2];
            minSize = 100;
            component.(testCase.MinimumDimension) = ...
                minSize * ones( numButtons, 1 );

            % Squeeze the component, then verify that all elements in the
            % container respect the 'Minimum*' values.
            component.Position(testCase.DimensionIndex) = 400;
            for k = 1 : numel( buttons )
                testCase.verifyEqual( ...
                    buttons(k).Position(testCase.DimensionIndex), ...
                    minSize, ...
                    ['Adding controls to a ', ConstructorName, ...
                    ' component then shrinking the component did ', ...
                    'not respect the ''', testCase.MinimumDimension, ...
                    ''' property.'] )
            end % for

        end % tMinimumSizesAreRespected

        function tReorderingContentsUpdatesBoxDimensions( testCase, ...
                ConstructorName )

            % Create a component with children.
            component = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Determine the dimension property name ('Widths' or
            % 'Heights').
            hNames = {'uiextras.HBox', 'uix.HBox', ...
                'uiextras.HBoxFlex', 'uix.HBoxFlex'};
            if ismember( ConstructorName, hNames )
                propertyName = 'Widths';
            else
                propertyName = 'Heights';
            end % if

            % Set the dimension values.
            oneToFour = 1:4;
            component.(propertyName) = -oneToFour;
            minimumPropertyName = ['Minimum', propertyName];
            component.(minimumPropertyName) = oneToFour;

            % Reorder the children.
            component.Contents = component.Contents(end:-1:1);

            % Verify that the box dimensions have been updated.
            expectedDimensionValue = flip( -oneToFour(:) );
            actualDimensionValue = component.(propertyName)(:);
            expectedMinimumDimensionValue = flip( oneToFour(:) );
            actualMinimumDimensionValue = ...
                component.(minimumPropertyName)(:);
            diagnostic = @( prop ) ['Reordering the contents of the ', ...
                ConstructorName, ' component did not update the ''', ...
                prop, ''' property correctly.'];
            testCase.verifyEqual( actualDimensionValue, ...
                expectedDimensionValue, diagnostic( propertyName ) )
            testCase.verifyEqual( actualMinimumDimensionValue, ...
                expectedMinimumDimensionValue, ...
                diagnostic( minimumPropertyName ) )

        end % tReorderingContentsUpdatesBoxDimensions

    end % methods ( Test, Sealed )

    methods ( Test, Sealed, ParameterCombination = 'sequential' )

        function tSettingBoxDimensionsAssignsValuesCorrectly( ...
                testCase, ConstructorName, BoxDimensionNameValuePairs )

            % Create a component with children.
            component = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Set each box dimension and verify that it has been assigned
            % correctly.
            boxPairs = BoxDimensionNameValuePairs;
            for k = 1 : 2 : numel( boxPairs )-1
                % Extract the current name-value pair.
                propertyName = boxPairs{k};
                propertyValue = boxPairs{k+1};
                % Assign the current property value.
                component.(propertyName) = propertyValue;
                % Verify that it has been assigned correctly, up to the
                % vector orientation.
                actualValue = component.(propertyName)(:);
                expectedValue = propertyValue(:);
                testCase.verifyEqual( actualValue, ...
                    expectedValue, ['The ', ConstructorName, ...
                    ' component did not assign the ''', propertyName, ...
                    ''' property correctly.'] )
            end % for

        end % tSettingBoxDimensionsAssignsValuesCorrectly

    end % methods ( Test, Sealed, ParameterCombination = 'sequential' )

    methods ( Sealed, Access = protected )

        function [component, expectedSizes] = ...
                createComponentWithChildrenAndResizeFigure( ...
                testCase, ConstructorName )

            % Create the component with children.
            component = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Set size-related properties of the component.
            padding = 10;
            spacing = 10;
            componentSizes = [-3, -1, -1, 50];
            set( component, 'Units', 'normalized', ...
                'Position', [0, 0, 1, 1], ...
                'Padding', padding, ...
                'Spacing', spacing, ...
                testCase.Dimension, componentSizes )

            % If the figure is docked, it cannot be resized.
            parentFigure = component.Parent;
            if strcmp( parentFigure.WindowStyle, 'docked' )
                numKids = numel( component.Contents );
                expectedSizes = NaN( 1, numKids );
                for k = 1 : numKids
                    expectedSizes(k) = component.Contents(k)...
                        .Position(testCase.DimensionIndex);
                end % for
            else
                % Resize the component's parent figure.
                newSize = 200;
                parentFigure.Position = [600, 600, newSize, newSize];
                % Compute the expected sizes of the controls within the
                % component.
                relativePartSizePixels = ...
                    (newSize - componentSizes(4) - 2 * padding - ...
                    (numel( componentSizes ) - 1) * spacing) / ...
                    sum( (-1) * componentSizes(1:3) );
                expectedSizes = (-1) * relativePartSizePixels * ...
                    [componentSizes(1:3), 0] + [zeros( 1, 3 ), 50];
            end % if

        end % createComponentWithChildrenAndResizeFigure

    end % methods ( Sealed, Access = protected )

end % classdef