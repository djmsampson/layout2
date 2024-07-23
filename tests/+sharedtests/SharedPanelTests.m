classdef ( Abstract ) SharedPanelTests < sharedtests.SharedContainerTests
    %PANELCONTAINERTESTS Additional tests common to all panel containers
    %(*.CardPanel and *.TabPanel). Note that *.BoxPanel, ScrollingPanel,
    %and *.Panel no longer have the 'Selection' property and do not include
    %these tests.

    properties ( TestParameter )
        % Collection of invalid values for the 'Selection' property, used
        % to test that panels issue an error.
        InvalidSelection = {2.4, -2, [2, 3, 4], 5}
    end % properties ( TestParameter )

    methods ( Test, Sealed )

        function tContentsRespectPlacingBoxInPanel( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Add a box.
            box = uiextras.HBox( 'Parent', component );

            % Verify that the 'Contents' property is correct.
            testCase.verifyEqual( component.Contents, box )

        end % tContentsRespectPlacingBoxInPanel

        function tPanelContentsHaveCorrectVisibility( ...
                testCase, ConstructorName )

            % Create the component with children.
            [component, kids] = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Select one of the children.
            selectionIndex = 2;
            component.Selection = selectionIndex;

            % Verify that the selected child is visible.
            selectedKidVisibility = char( kids(2).Visible );
            testCase.verifyEqual( selectedKidVisibility, 'on', ...
                ['The selected child in the ', ConstructorName, ...
                ' component is not visible.'] )
            % Verify that the other children are not visible.
            for k = [1, 3, 4]
                kidVisibility = char( kids(k).Visible );
                testCase.verifyEqual( kidVisibility, 'off', ...
                    ['The unselected child in the ', ...
                    ConstructorName, ' component is visible.'] )
            end % for

        end % tPanelContentsHaveCorrectVisibility

        function tSettingInvalidSelectionErrors( ...
                testCase, ConstructorName, InvalidSelection )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that setting an invalid value for the 'Selection'
            % property throws an error.
            invalidSetter = ...
                @() set( component, 'Selection', InvalidSelection );
            testCase.verifyError( invalidSetter, ...
                'uix:InvalidPropertyValue', ...
                ['The ', ConstructorName, ' component did not throw ', ...
                'the expected exception when the ''Selection'' ', ...
                'property was set to an invalid value.'] )

        end % tSettingInvalidSelectionErrors

        function tSettingInvalidSelectionErrorsWhenChildrenArePresent( ...
                testCase, ConstructorName, InvalidSelection )

            % Create the component.
            component = testCase.constructComponentWithChildren( ...
                ConstructorName );

            % Verify that setting an invalid value for the 'Selection'
            % property throws an error.
            invalidSetter = ...
                @() set( component, 'Selection', InvalidSelection );
            testCase.verifyError( invalidSetter, ...
                'uix:InvalidPropertyValue', ...
                ['The ', ConstructorName, ' component did not throw ', ...
                'the expected exception when the ''Selection'' ', ...
                'property was set to an invalid value.'] )

        end % tSettingInvalidSelectionErrorsWhenChildrenArePresent

        function tSettingSelectionPropertyIsCorrect( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Set the 'Selection' property.
            component.Selection = 0;

            % Verify that the 'Selection' property has been set correctly.
            testCase.verifyEqual( component.Selection, 0, ...
                ['Setting the ''Selection'' property on the ', ...
                ConstructorName, ' component when it has no ', ...
                'children did not return 0.'] )

        end % tSettingSelectionPropertyIsCorrect

        function tSettingSelectionPropertyWithChildrenIsCorrect( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponentWithChildren( ...
                ConstructorName );

            % Set the 'Selection' property.
            component.Selection = 2;

            % Verify that the 'Selection' property has been set correctly.
            testCase.verifyEqual( component.Selection, 2, ...
                ['Setting the ''Selection'' property on the ', ...
                ConstructorName, ' component when it has ', ...
                'children did not return the correct value.'] )

        end % tSettingSelectionPropertyWithChildrenIsCorrect

        function tAddingInvisibleContainerIsWarningFree( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Create an invisible container then reparent it to the
            % component.
            container = uicontainer( 'Parent', [], 'Visible', 'off' );
            testCase.addTeardown( @() delete( container ) )
            reparenter = @() set( container, 'Parent', component );
            testCase.verifyWarningFree( reparenter, ...
                ['Reparenting an invisible container to the ', ...
                ConstructorName, ' component was not warning-free.'] )

        end % tAddingInvisibleContainerIsWarningFree

        function tAddingInvisibleControlIsWarningFree( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Create an invisible control then reparent it to the
            % component.
            button = uicontrol( 'Parent', [], 'Visible', 'off' );
            testCase.addTeardown( @() delete( button ) )
            reparenter = @() set( button, 'Parent', component );
            testCase.verifyWarningFree( reparenter, ...
                ['Reparenting an invisible control to the ', ...
                ConstructorName, ' component was not warning-free.'] )

        end % tAddingInvisibleControlIsWarningFree

        function tAddingInternalControlDoesNotAffectContents( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Add an internal control to the component.
            button = uicontrol( 'Parent', component, 'Internal', true );

            % Verify that the component's 'Contents' property remains
            % empty.
            testCase.verifyEmpty( component.Contents, ...
                ['Adding an internal control to the ', ...
                ConstructorName, ' component did not leave the ', ...
                '''Contents'' property empty.'] )

            % Switch the 'Internal' property of the button to false and
            % verify that the 'Contents' property of the component updates.
            button.Internal = false;
            testCase.verifyNumElements( component.Contents, 1, ...
                ['The ''Contents'' property of the ', ConstructorName, ...
                ' component did not update when an internal control ', ...
                'was switched to non-internal.'] )

        end % tAddingInternalControlDoesNotAffectContents 

        function tAddingChildIsWarningFreeUnderBugConditions( testCase, ...
                ConstructorName )

            % Assume that we're in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Construct the component.
            component = testCase.constructComponent( ConstructorName );
            testFig = component.Parent;

            % Set the bug flag if we're not in R2014b.
            if ~verLessThan( 'matlab', '8.5' )
                component.G1136196 = true;
            end % if

            for visibility = {'on', 'off'}
                % Create a control.
                c = uicontrol( 'Parent', testFig, ...
                    'Visible', visibility{1} );
                testCase.addTeardown( @() delete( c ) )

                % Test that parenting the control to the component is
                % warning-free.
                f = @() set( c, 'Parent', component );
                testCase.verifyWarningFree( f, ['Parenting a control ', ...
                    'to a ', ConstructorName, ' component was not ', ...
                    'warning-free.'] )
            end % for

        end % tAddingChildIsWarningFreeUnderBugConditions

        function tAddingInvisibleChildUpdatesContents( testCase, ...
                ConstructorName )

            % Assume that we're in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Construct the component.
            component = testCase.constructComponent( ConstructorName );
            testFig = component.Parent;

            % Set the bug flag if we're not in R2014b.
            if ~verLessThan( 'matlab', '8.5' )
                component.G1136196 = true;
            end % if

            % Create a control.
            c = uicontrol( 'Parent', testFig, 'Visible', 'off' );
            testCase.addTeardown( @() delete( c ) )

            % Parent the control.
            c.Parent = component;

            % Verify that the Contents property is correct.
            actual = component.Contents(component.Selection);
            testCase.verifySameHandle( actual, c, ['Parenting an ', ...
                'invisible control to a ', ConstructorName, ...
                ' component did not update the ''Contents'' ', ...
                'property correctly.'] )

        end % tAddingInvisibleChildUpdatesContents

        function tAddingInvisibleChildEventuallyMakesLayoutVisible( ...
                testCase, ConstructorName )

            % Assume that we're in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Construct the component.
            component = testCase.constructComponent( ConstructorName );
            testFig = component.Parent;

            % Set the bug flag if we're not in R2014b.
            if ~verLessThan( 'matlab', '8.5' )
                component.G1136196 = true;
            end % if

            % Create a control.
            c = uicontrol( 'Parent', testFig, 'Visible', 'off' );
            testCase.addTeardown( @() delete( c ) )

            % Parent the control to the component.
            c.Parent = component;
            f = @() char( component.Visible );
            testCase.verifyThat( f, matlab.unittest.constraints...
                .Eventually( matlab.unittest.constraints...
                .IsEqualTo( 'on' ), 'WithTimeoutOf', 5 ) )

        end % tAddingInvisibleChildEventuallyMakesLayoutVisible

        function tReorderingEmptyContentsDoesNotChangeSelection( ...
                testCase, ConstructorName )

            % Construct the component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that the 'Selection' property is 0.
            testCase.verifyEqual( component.Selection, 0, ...
                ['The ''Selection'' property of the ', ConstructorName, ...
                ' component was not 0 immediately after construction.'] )

            % Perform a no-op shuffle of the 'Contents' to trigger the
            % reorder method.
            component.Contents = component.Contents([]);
            testCase.verifyEqual( component.Selection, 0, ...
                ['The ''Selection'' property of the ', ConstructorName, ...
                ' component was not 0 after performing a no-op ', ...
                'shuffle of the empty ''Contents'' property.'] )

        end % tReorderingEmptyContentsDoesNotChangeSelection

    end % methods ( Test, Sealed )

end % classdef