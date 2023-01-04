classdef ( Abstract ) SharedGridTests < ...
        utilities.mixin.SharedContainerTests
    %GRIDCONTAINERTESTS Additional tests common to all grid containers
    %(*.Grid and *.GridFlex).

    properties ( Constant, Abstract )
        % Grid dimension name-value pairs used when testing the component's
        % get/set methods.
        GridDimensionNameValuePairs
    end % properties ( Constant, Abstract )

    methods ( Test, Sealed )

        function tAddingChildUpdatesGridContents( ...
                testCase, ConstructorName )

            % Create the grid.
            [component, kids] = testCase...
                .createGridWithChildren( ConstructorName );

            % Add a new child.
            newKid = uicontrol( component );

            % Verify that the 'Contents' property has been updated.
            testCase.verifyEqual( component.Contents, [kids; newKid], ...
                ['Adding a new child to the ', ConstructorName, ...
                ' component did not update the ''Contents'' property ', ...
                'correctly.'] )
            
        end % tAddingChildUpdatesGridContents

        function tRemovingChildUpdatesGridContents( ...
                testCase, ConstructorName )

            % Create the grid.
            [component, kids] = testCase...
                .createGridWithChildren( ConstructorName );

            % Remove a child.
            delete( kids(5) )

            % Verify that the 'Contents' property has been updated.
            testCase.verifyEqual( component.Contents, kids([1:4, 6]), ...
                ['Removing a child from the ', ConstructorName, ...
                ' component did not update the ''Contents'' property ', ...
                'correctly.'] )

        end % tRemovingChildUpdatesGridContents

        function tReparentingChildUpdatesGridContents( ...
                testCase, ConstructorName )

            % Create the grid.
            [component, kids] = testCase...
                .createGridWithChildren( ConstructorName );

            % Reparent a child.
            kids(5).Parent = [];
            testCase.addTeardown( @() delete( kids(5) ) )

            % Verify that the 'Contents' property has been updated.
            testCase.verifyEqual( component.Contents, kids([1:4, 6]), ...
                ['Reparenting a child from the ', ConstructorName, ...
                ' component did not update the ''Contents'' property ', ...
                'correctly.'] )

        end % tReparentingChildUpdatesGridContents

        function tSettingGridDimensionsAssignsValuesCorrectly( ...
                testCase, ConstructorName )

            % Create a component with children.
            component = testCase.createGridWithChildren( ConstructorName );

            % Set each grid dimension and verify that it has been assigned
            % correctly.
            gridPairs = testCase.GridDimensionNameValuePairs;
            for k = 1 : 2 : length( gridPairs )-1
                % Extract the current name-value pair.
                propertyName = gridPairs{k};
                propertyValue = gridPairs{k+1};
                % Assign the current property value.
                component.(propertyName) = propertyValue;
                % Verify that it has been assigned correctly.
                expectedValue = propertyValue(:);
                testCase.verifyEqual( component.(propertyName), ...
                    expectedValue, ['The ', ConstructorName, ...
                    ' component did not assign the ''', propertyName, ...
                    ''' property correctly.'] )
            end % for

        end % tSettingGridDimensionsAssignsValuesCorrectly

        function tSettingEmptyWidthsErrorsForNonEmptyContents( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Add a child.
            uicontrol( component )

            % Verify that setting an empty value for the 'Widths' property
            % results in an error.
            setter = @() set( component, 'Widths', double.empty( 0, 1 ) );
            testCase.verifyError( setter, 'uix:InvalidPropertyValue', ...
                ['The ', ConstructorName, ' component did not issue ', ...
                'the expected error when its ''Widths'' property was ', ...
                'set to an empty value when its ''Contents'' ', ...
                'property is nonempty.'] )

        end % tSettingEmptyWidthsErrorsForNonEmptyContents

        function tSettingWidthsProducingEmptyColumnsErrors( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Add children.
            for k = 1 : 4
                uicontrol( component )
            end % for

            % Verify that setting a value for 'Widths' that would produce
            % empty columns results in an error.
            setter = @() set( component, 'Widths', [-1, -1, -1] );
            testCase.verifyError( setter, 'uix:InvalidPropertyValue', ...
                ['The ', ConstructorName, ' component did not issue ', ...
                'the expected error when its ''Widths'' property was ', ...
                'set to a value with not enough elements.'] )

        end % tSettingWidthsProducingEmptyColumnsErrors

        function tSettingTooManyWidthsErrors( testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that setting too many elements in the 'Widths'
            % property results in an error.
            setter = @() set( component, 'Widths', -1 );
            testCase.verifyError( setter, 'uix:InvalidPropertyValue', ...
                ['The ', ConstructorName, ' component did not issue ', ...
                'the expected error when its ''Widths'' property was ', ...
                'set to a value with too many elements.'] )

        end % tSettingTooManyWidthsErrors

        function tDecreasingNumColumnsUpdatesDimensions( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Add children.
            for k = 1 : 6
                uicontrol( component )
            end % for

            % Set the 'Widths' property.
            component.Widths = [-1; -1; -1];

            % Reduce the number of columns.
            component.Widths = [-1; -1];

            % Verify that the grid dimensions have been updated.
            testCase.verifyEqual( component.MinimumWidths, [1; 1], ...
                ['Decreasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''MinimumWidths'' property correctly.'] )
            testCase.verifyEqual( component.Heights, [-1; -1; -1], ...
                ['Decreasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''Heights'' property correctly.'] )
            testCase.verifyEqual( component.MinimumHeights, [1; 1; 1], ...
                ['Decreasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''MinimumHeights'' property correctly.'] )

        end % tDecreasingNumColumnsUpdatesDimensions

        function tIncreasingNumColumnsUpdatesDimensions( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Add children.
            for k = 1 : 6
                uicontrol( component )
            end % for

            % Set the 'Widths' property.
            component.Widths = [-1; -1];

            % Increase the number of columns.
            component.Widths = [-1; -1; -1];

            % Verify that the grid dimensions have been updated.
            testCase.verifyEqual( component.MinimumWidths, [1; 1; 1], ...
                ['Increasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''MinimumWidths'' property correctly.'] )
            testCase.verifyEqual( component.Heights, [-1; -1], ...
                ['Increasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''Heights'' property correctly.'] )
            testCase.verifyEqual( component.MinimumHeights, [1; 1], ...
                ['Increasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''MinimumHeights'' property correctly.'] )

        end % tIncreasingNumColumnsUpdatesDimensions

        function tSettingEmptyHeightsErrorsForNonEmptyContents( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Add a child.
            uicontrol( component )

            % Verify that setting an empty value for the 'Heights' property
            % results in an error.
            setter = @() set( component, 'Heights', double.empty( 0, 1 ) );
            testCase.verifyError( setter, 'uix:InvalidPropertyValue', ...
                ['The ', ConstructorName, ' component did not issue ', ...
                'the expected error when its ''Heights'' property was ', ...
                'set to an empty value when its ''Contents'' ', ...
                'property is nonempty.'] )

        end % tSettingEmptyHeightsErrorsForNonEmptyContents

        function tSettingTooManyHeightsErrors( testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that setting too many elements in the 'Heights'
            % property results in an error.
            setter = @() set( component, 'Heights', -1 );
            testCase.verifyError( setter, 'uix:InvalidPropertyValue', ...
                ['The ', ConstructorName, ' component did not issue ', ...
                'the expected error when its ''Heights'' property was ', ...
                'set to a value with too many elements.'] )

        end % tSettingTooManyHeightsErrors

        function tDecreasingNumRowsUpdatesDimensions( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Add children.
            for k = 1 : 6
                uicontrol( component )
            end % for

            % Set the 'Heights' property.
            component.Heights = [-1; -1; -1];

            % Reduce the number of rows.
            component.Heights = [-1; -1];

            % Verify that the grid dimensions have been updated.
            testCase.verifyEqual( component.MinimumHeights, [1; 1], ...
                ['Decreasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''MinimumHeights'' property correctly.'] )
            testCase.verifyEqual( component.Widths, [-1; -1; -1], ...
                ['Decreasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''Widths'' property correctly.'] )
            testCase.verifyEqual( component.MinimumWidths, [1; 1; 1], ...
                ['Decreasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''MinimumWidths'' property correctly.'] )

        end % tDecreasingNumRowsUpdatesDimensions

        function tIncreasingNumRowsUpdatesDimensions( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Add children.
            for k = 1 : 6
                uicontrol( component )
            end % for

            % Set the 'Heights' property.
            component.Heights = [-1; -1];

            % Increase the number of rows.
            component.Heights = [-1; -1; -1];

            % Verify that the grid dimensions have been updated.
            testCase.verifyEqual( component.MinimumHeights, [1; 1; 1], ...
                ['Increasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''MinimumHeights'' property correctly.'] )
            testCase.verifyEqual( component.Widths, [-1; -1], ...
                ['Increasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''Widths'' property correctly.'] )
            testCase.verifyEqual( component.MinimumWidths, [1; 1], ...
                ['Increasing the number of columns in the ', ...
                ConstructorName, ' component did not update the ', ...
                '''MinimumWidths'' property correctly.'] )

        end % tIncreasingNumColumnsUpdatesDimension

        function tRemovingChildFromSingleColumnGridUpdatesDumensions( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Add children.
            for k = 1 : 3
                uicontrol( component )
            end % for

            % Create a single column grid.
            component.Heights = [-1; -1; -1];

            % Remove a child.
            delete( component.Contents(3) )

            % Verify that the height dimensions have been updated.
            testCase.verifyEqual( component.Heights, [-1; -1], ...
                ['Removing a child from a single-column grid (', ...
                ConstructorName, ') did not update the ''Heights''', ...
                ' property correctly.'] )
            testCase.verifyEqual( component.MinimumHeights, [1; 1], ...
                ['Removing a child from a single-column grid (', ...
                ConstructorName, ') did not update the ''', ...
                'MinimumHeights'' property correctly.'] )

        end % tRemovingChildFromSingleColumnGridUpdatesDumensions

    end % methods ( Test, Sealed )

    methods ( Sealed, Access = protected )

        function [component, kids] = createGridWithChildren( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Add six controls.
            kids = gobjects( 6, 1 );
            for k = 1 : length( kids )
                kids(k) = uicontrol( 'Parent', component );
            end % for

            % Reshape the grid to be 2-by-3.
            set( component, 'Heights', [-1, 200], ...
                'Widths', [-1, 100, 1] )

        end % createGridWithChildren

    end % methods ( Sealed, Access = protected )

end % class