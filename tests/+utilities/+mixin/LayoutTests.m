classdef ( Abstract ) LayoutTests < utilities.mixin.ContainerTests
    %LAYOUTTESTS Additional tests common to all layout containers
    %(*.HBox, *.VBox, *.HBoxFlex, *.VBoxFlex).

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
            for k = 1 : length( buttons )
                testCase.verifyEqual( ...
                    buttons(k).Position(testCase.DimensionIndex), ...
                    minSize, ...
                    ['Adding controls to a ', ConstructorName, ...
                    ' component then shrinking the component did ', ...
                    'not respect the ''', testCase.MinimumDimension, ...
                    ''' property.'] )
            end % for

        end % tMinimumSizesAreRespected

    end % methods ( Test, Sealed )

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
                numKids = length( component.Contents );
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
                    (length( componentSizes ) - 1) * spacing) / ...
                    sum( (-1) * componentSizes(1:3) );
                expectedSizes = (-1) * relativePartSizePixels * ...
                    [componentSizes(1:3), 0] + [zeros( 1, 3 ), 50];
            end % if

        end % createComponentWithChildrenAndResizeFigure

    end % methods ( Sealed, Access = protected )

end % class