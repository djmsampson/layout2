classdef ( Abstract ) SharedContainerTests < glttestutilities.TestInfrastructure
    %CONTAINERTESTS Tests common to all GUI Layout Toolbox containers,
    %across both the +uiextras and +uix packages.

    properties ( TestParameter, Abstract )
        % The constructor name, or class, of the component under test.
        ConstructorName
        % Name-value pair arguments to use when testing the component's
        % constructor and get/set methods.
        NameValuePairs
    end % properties ( TestParameter, Abstract )

    properties ( Constant )
        % List of containers with get and set methods for the 'Enable'
        % property.
        ContainersWithEnableGetAndSetMethods = {
            'uiextras.CardPanel', ...
            'uiextras.Grid', ...
            'uiextras.GridFlex', ...
            'uiextras.HBox', ...
            'uiextras.HBoxFlex', ...
            'uiextras.TabPanel', ...
            'uiextras.VBox', ...
            'uiextras.VBoxFlex'
            }
        % List of containers that may need the 'Enable' property to be
        % added dynamically (depending on the MATLAB version). The 'Enable'
        % property was added to matlab.ui.container.Panel in R2020b.
        ContainersWithDynamicEnableProperty = {
            'uiextras.BoxPanel', ...
            'uiextras.Panel'
            }
        % List of containers that have the 'SelectedChild' property.
        ContainersWithSelectedChildProperty = {
            'uiextras.BoxPanel', ...
            'uiextras.CardPanel', ...
            'uiextras.Panel', ...
            'uiextras.TabPanel'
            }
    end % properties ( Constant )

    methods ( Test, Sealed )

        function tConstructorWithNoArgumentsIsWarningFree( ...
                testCase, ConstructorName )

            % This test only applies to containers in the uix namespace.
            % (Containers in the uiextras namespace exhibit auto-parenting
            % behavior, which is tested separately.)
            testCase.assumeComponentIsFromNamespace( ...
                ConstructorName, 'uix' )

            % Verify that constructing a component with no input arguments
            % is warning-free.
            creator = @() constructComponentWithoutFixture( ...
                ConstructorName );
            testCase.verifyWarningFree( creator, ...
                ['The ', ConstructorName, ' constructor was ', ...
                'not warning-free when called with no input arguments.'] )

        end % tConstructorWithNoArgumentsIsWarningFree

        function tConstructorWithNoArgumentsReturnsScalarComponent( ...
                testCase, ConstructorName )

            % This test only applies to containers in the uix namespace.
            % (Containers in the uiextras namespace exhibit auto-parenting
            % behavior, which is tested separately.)
            testCase.assumeComponentIsFromNamespace( ...
                ConstructorName, 'uix' )

            % Call the constructor with no input arguments.
            component = constructComponentWithoutFixture( ...
                ConstructorName );

            % Assert that the type is correct.
            testCase.assertClass( component, ConstructorName, ...
                ['The ', ConstructorName, ...
                ' constructor did not return ', ...
                'an object of type ', ConstructorName, '.'] )

            % Assert that the returned object is a scalar.
            testCase.assertSize( component, [1, 1], ...
                ['The ', ConstructorName, ...
                ' constructor did not return a scalar object.'] )

        end % tConstructorWithNoArgumentsReturnsScalarComponent

        function tConstructorWithAnEmptyParentIsWarningFree( ...
                testCase, ConstructorName )

            % Verify that constructing a component with the 'Parent'
            % property set to [] is warning-free.
            creator = @() constructComponentWithoutFixture( ...
                ConstructorName, 'Parent', [] );
            testCase.verifyWarningFree( creator, ...
                ['The ', ConstructorName, ' constructor was ', ...
                'not warning-free when called with ''Parent'' ', ...
                'set to [].'] )

        end % tConstructorWithAnEmptyParentIsWarningFree

        function tConstructorWithAnEmptyParentReturnsScalarComponent( ...
                testCase, ConstructorName )

            % Call the constructor with an empty 'Parent' input.
            component = constructComponentWithoutFixture( ...
                ConstructorName, 'Parent', [] );

            % Assert that the type is correct.
            testCase.assertClass( component, ConstructorName, ...
                ['The ', ConstructorName, ...
                ' constructor did not return ', ...
                'an object of type ', ConstructorName, '.'] )

            % Assert that the returned object is a scalar.
            testCase.assertSize( component, [1, 1], ...
                ['The ', ConstructorName, ...
                ' constructor did not return a scalar object.'] )

        end % tConstructorWithAnEmptyParentReturnsScalarComponent

        function tAutoParentBehaviorIsCorrect( testCase, ConstructorName )

            % Testing auto-parenting behavior only applies to containers in
            % the uiextras namespace. Containers in the uix namespace do
            % not exhibit auto-parenting behavior.
            testCase.assumeComponentIsFromNamespace( ...
                ConstructorName, 'uiextras' )

            % Create a new figure.
            newFig = figure();
            testCase.addTeardown( @() delete( newFig ) )

            % Instantiate the component, without specifying the parent.
            component = feval( ConstructorName );
            testCase.addTeardown( @() delete( component ) )

            % Verify the class and size of the component.
            testCase.assertClass( component, ConstructorName, ...
                ['The ', ConstructorName, ...
                ' constructor did not return ', ...
                'an object of type ', ConstructorName, '.'] )
            testCase.assertSize( component, [1, 1], ...
                ['The ', ConstructorName, ...
                ' constructor did not return a scalar object.'] )

            % Verify that the parent of the component is the new figure we
            % created above.
            testCase.verifySameHandle( component.Parent, newFig, ...
                [ConstructorName, ' has not auto-parented correctly.'] )

        end % tAutoParentBehaviorIsCorrect

        function tConstructorWithParentArgumentIsWarningFree( ...
                testCase, ConstructorName )

            % Verify that calling the component constructor with the
            % 'Parent' input argument given by the figure fixture is
            % warning-free.
            creator = @() testCase.constructComponent( ConstructorName );
            testCase.verifyWarningFree( creator, ...
                ['The ', ConstructorName, ' constructor was not ', ...
                'warning-free when called with the ''Parent'' input ', ...
                'argument.'] )

        end % tConstructorWithParentArgumentIsWarningFree

        function tConstructorWithParentArgumentReturnsScalarComponent( ...
                testCase, ConstructorName )

            % Call the component constructor.
            component = testCase.constructComponent( ConstructorName );

            % Assert that the type is correct.
            testCase.assertClass( component, ConstructorName, ...
                ['The ', ConstructorName, ...
                ' constructor did not return ', ...
                'an object of type ', ConstructorName, ' when called ', ...
                'with the ''Parent'' input argument.'] )

            % Assert that the returned object is a scalar.
            testCase.assertSize( component, [1, 1], ...
                ['The ', ConstructorName, ...
                ' constructor did not return ', ...
                'a scalar object when called with the ''Parent'' ', ...
                'input argument.'] )

        end % tConstructorWithParentArgumentReturnsScalarComponent

        function tConstructorSetsRepeatedNameValuePairsCorrectly( ...
                testCase, ConstructorName )

            % Create the component, passing in repeated name-value pairs.
            component = testCase.constructComponent( ConstructorName, ...
                'Tag', '1', 'Tag', '2', 'Tag', '3' );
            % Verify that the 'Tag' has been set correctly.
            testCase.verifyEqual( component.Tag, '3', ...
                ['The ', ConstructorName, ' constructor did not set ', ...
                'the ''Tag'' correctly when this property was passed ', ...
                'multiple times to the constructor.'] )

        end % tConstructorSetsRepeatedNameValuePairsCorrectly

        function tConstructorErrorsWithBadArguments( ...
                testCase, ConstructorName )

            % Test with providing the name of a property only.
            invalidConstructor = @() testCase.constructComponent( ...
                ConstructorName, 'BackgroundColor' );
            testCase.verifyError( ...
                invalidConstructor, 'uix:InvalidArgument' )

            % Test with providing a property value only.
            invalidConstructor = @() testCase.constructComponent( ...
                ConstructorName, 200 );
            testCase.verifyError( ...
                invalidConstructor, 'uix:InvalidArgument' );

        end % tConstructorErrorsWithBadArguments

        function tChildObserverDoesNotIncorrectlyAddElements( ...
                testCase, ConstructorName )

            % Create the component and verify that its 'Contents' property
            % has no elements.
            component = testCase.constructComponent( ConstructorName );
            testCase.verifyNumElements( component.Contents, 0 )

            % Add a control, and set its 'Internal' property to false.
            c = uicontrol( 'Parent', component );
            c.Internal = false;

            % Verify that the component's 'Contents' property has one
            % element.
            testCase.verifyNumElements( component.Contents, 1 )

        end % tChildObserverDoesNotIncorrectlyAddElements

        function tContentsAreUpdatedWhenChildrenAreAdded( ...
                testCase, ConstructorName )

            % Create the component, with children.
            [component, kids] = testCase...
                .constructComponentWithChildren( ConstructorName );
            % Verify that the contents are equal to the list of children.
            testCase.verifyEqual( component.Contents, kids, ...
                ['The ', ConstructorName, ' component has not ', ...
                'updated its ''Contents'' property correctly when ', ...
                'controls were added.'] )

        end % tContentsAreUpdatedWhenChildrenAreAdded

        function tContentsAreUpdatedWhenAChildIsDeleted( testCase, ...
                ConstructorName )

            % Create the component, with children.
            [component, kids] = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Delete a child.
            delete( kids(2) )

            % Verify that the 'Contents' property has been updated.
            testCase.verifyEqual( component.Contents, kids([1, 3, 4]), ...
                ['The ', ConstructorName, ' component has not ', ...
                'updated its ''Contents'' property correctly when ', ...
                'a child was deleted.'] )

        end % tContentsAreUpdatedWhenAChildIsDeleted

        function tContentsAreUpdatedWhenAChildIsReparented( ...
                testCase, ConstructorName )

            % Create the component, with children.
            [component, kids] = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Reparent a child.
            kids(2).Parent = testCase.ParentFixture.Parent;
            testCase.addTeardown( @() delete( kids(2) ) )

            % Verify that the 'Contents' property has been updated.
            testCase.verifyEqual( component.Contents, kids([1, 3, 4]), ...
                ['The ', ConstructorName, ' component has not ', ...
                'updated its ''Contents'' property correctly when ', ...
                'a child was reparented.'] )

        end % tContentsAreUpdatedWhenAChildIsReparented

        function tContentsAreUpdatedAfterChildrenAreReordered( ...
                testCase, ConstructorName )

            % Create the component, with children.
            component = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Reorder the children.
            previousContents = component.Contents;
            component.Children = component.Children(4:-1:1);

            % Verify that the 'Contents' property has been updated.
            testCase.verifyEqual( component.Contents, ...
                previousContents(4:-1:1), ...
                ['The ', ConstructorName, ' component has not ', ...
                'updated its ''Contents'' property correctly when ', ...
                'the children were reordered.'] )

        end % tContentsAreUpdatedAfterChildrenAreReordered

        function tPlottingInAxesInComponentRespectsContents( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Add two axes.
            ax(1) = axes( 'Parent', component );
            ax(2) = axes( 'Parent', component );

            % Plot into these axes.
            plot( ax(1), 1:10 )
            plot( ax(2), 1:10 )

            % Verify that the component's 'Contents' property is correct.
            testCase.verifyNumElements( component.Contents, 2, ...
                ['Plotting in axes in a ', ConstructorName, ...
                ' component resulted in the incorrect number of ', ...
                '''Contents''.'] )
            diagnostic = ['Plotting in axes in a ', ConstructorName, ...
                ' component resulted in an incorrect value for ', ...
                'the ''Contents'' property.'];
            testCase.verifySameHandle( ...
                component.Contents(1), ax(1), diagnostic )
            testCase.verifySameHandle( ...
                component.Contents(2), ax(2), diagnostic )

        end % tPlottingInAxesInComponentRespectsContents

        function tAxesInComponentRemainsVisibleAfter3DRotation( ...
                testCase, ConstructorName )
            
            % Assume that we're in R2015b or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2015b' )

            % Assume the component is rooted.
            testCase.assumeGraphicsAreRooted()

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Add an axes.
            ax = axes( 'Parent', component );

            % Enable 3D rotation mode.
            rotate3d( ax, 'on' )

            % Verify that the axes is still visible.
            testCase.verifyEqual( char( ax.Visible ), 'on', ...
                ['Enabling 3D rotation mode on an axes within a ', ...
                ConstructorName, ' component made the axes invisible.'] )

        end % tAxesInComponentRemainsVisibleAfter3DRotation

        function tEnablingDataCursorModeIsWarningFree( ...
                testCase, ConstructorName )

            % Skip this test if we're running in CI.
            testCase.assumeNotRunningOnCI()

            % Exclude the unrooted case.
            testCase.assumeGraphicsAreRooted()

            % Disable a warning for the duration of the test.
            warningID = 'MATLAB:modes:mode:InvalidPropertySet';
            warningState = warning( 'query', warningID );
            warning( 'off', warningID )
            propertySetWarningCleanup = ...
                onCleanup( @() warning( warningState ) );

            % Work around a bug in R2022a-R2023a by disabling a warning for
            % the duration of the test.
            v = ver( 'matlab' ); %#ok<VERMATLAB>
            v = v.Version;
            if ismember( v, {'9.12', '9.13', '9.14'} )
                warningID = 'MATLAB:callback:DynamicPropertyEventError';
                warningState = warning( 'query', warningID );
                warning( 'off', warningID )
                propertyEventWarningCleanup = ...
                    onCleanup( @() warning( warningState ) );
            end % if

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Add an axes.
            ax = axes( 'Parent', component );

            % Ensure that the axes is not too small.
            if isprop( component, 'ButtonSize' )
                component.ButtonSize = [200, 200];
            end % if

            % Plot into the axes.
            p = plot( ax, 1:10 );

            % Initialize a datacursor mode object.
            dcm = [];

            function enableDataCursorMode()

                dcm = datacursormode( component.Parent );
                dcm.Enable = 'on';
                pause( 0.5 )

            end % enableDataCursorMode

            % Verify that there are no warnings when enabling datacursor
            % mode.
            enabler = @() enableDataCursorMode();
            testCase.verifyWarningFree( enabler, ['Enabling data ', ...
                'cursor mode in a figure containing a ', ...
                ConstructorName, ' component was not warning-free.'] )

            function addDataTip()

                dcm.createDatatip( p );
                pause( 0.5 )

            end % addDataTip

            % Add a datatip and verify that no warnings occur.
            dataTipAdder = @() addDataTip();
            testCase.verifyWarningFree( dataTipAdder, ...
                ['Adding a data tip to a plot inside a ', ...
                ConstructorName, ' component was not warning-free.'] )

        end % tEnablingDataCursorModeIsWarningFree

        function tContentsRespectAddingAxesAndControl( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Add an axes.
            ax = axes( 'Parent', component );

            % Add a control.
            c = uicontrol( 'Parent', component );

            % Verify the 'Contents' property is correct initially.
            diagnostic = ['Adding an axes and a control to a ', ...
                ConstructorName, ' component resulted in an ', ...
                'incorrect value for the ''Contents'' property.'];
            testCase.verifyEqual( ...
                component.Contents, [ax; c], diagnostic )

            % Wait, and then repeat the verification.
            pause( 0.1 )
            testCase.verifyEqual( ...
                component.Contents, [ax; c], diagnostic )

        end % tContentsRespectAddingAxesAndControl

        function tSettingContentsAcceptsRowOrientation( ...
                testCase, ConstructorName )

            % Create a component with children.
            [component, kids] = testCase...
                .constructComponentWithChildren( ConstructorName );

            % Permute the 'Contents' property and set it as a row vector
            % (rather than a column vector).
            flipPerm = numel( kids ) : -1 : 1;
            component.Contents = transpose( component.Contents(flipPerm) );

            % Verify that the 'Contents' property has been updated
            % correctly.
            testCase.verifySameHandle( component.Contents, ...
                kids(flipPerm), ...
                ['Setting the ''Contents'' property of the ', ...
                ConstructorName, ' component as a row vector did not ', ...
                'assign the value correctly.'] )

        end % tSettingContentsAcceptsRowOrientation

        function tContainerEnableGetMethod( testCase, ConstructorName )

            % Filter the test if the container does not have get and set
            % methods for the 'Enable' property.
            testCase.assumeComponentHasEnableGetSetMethods( ...
                ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that the 'Enable' property is set to 'on'.
            testCase.verifyEqual( component.Enable, 'on', ...
                ['The ''Enable'' property of the ', ConstructorName, ...
                'container is not set to ''on''.'] )

        end % tContainerEnableGetMethod

        function tContainerEnableSetMethod( testCase, ConstructorName )

            % Filter the test if the container does not have get and set
            % methods for the 'Enable' property.
            testCase.assumeComponentHasEnableGetSetMethods( ...
                ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Check that setting 'on' or 'off' is accepted.
            for enable = {'on', 'off'}
                enableSetter = ...
                    @() set( component, 'Enable', enable{1} );
                testCase.verifyWarningFree( enableSetter, ...
                    [ConstructorName, ' has not accepted a value ', ...
                    'of ''', enable{1}, ...
                    ''' for the ''Enable'' property.'] )
            end % for

            % Check that setting an invalid value causes an error.
            errorID = 'uiextras:InvalidPropertyValue';
            invalidSetter = @() set( component, 'Enable', {} );
            testCase.verifyError( invalidSetter, errorID, ...
                [ConstructorName, ' has not produced an ', ...
                'error with the expected ID when the ''Enable'' ', ...
                'property was set to an invalid value.'] )

        end % tContainerEnableSetMethod

        function tContainerDynamicEnableGetMethod( ...
                testCase, ConstructorName )

            % Filter the test if the component does not have a dynamic
            % 'Enable' property.
            testCase.assumeComponentHasDynamicEnableProperty( ...
                ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that the 'Enable' property exists and is set to
            % 'on'.
            testCase.assertTrue( isprop( component, 'Enable' ), ...
                [ConstructorName, ' does not ', ...
                'have the ''Enable'' property.'] )
            testCase.verifyTrue( strcmp( component.Enable, 'on' ), ...
                ['The ''Enable'' property of the ', ...
                ConstructorName, ' is not set to ''on''.'] )

        end % tContainerDynamicEnableGetMethod

        function tContainerDynamicEnableSetMethod( ...
                testCase, ConstructorName )

            % Filter the test if the component does not have a dynamic
            % 'Enable' property.
            testCase.assumeComponentHasDynamicEnableProperty( ...
                ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Check that setting 'on' or 'off' is accepted.
            for enable = {'on', 'off'}
                enableSetter = ...
                    @() set( component, 'Enable', enable{1} );
                testCase.verifyWarningFree( enableSetter, ...
                    [ConstructorName, ' has not accepted a value ', ...
                    'of ''', enable{1}, ...
                    ''' for the ''Enable'' property.'] )
            end % for

            % Check that setting an invalid value causes an error.
            if verLessThan( 'matlab', '9.9' ) %#ok<*VERLESSMATLAB>
                errorID = 'uiextras:InvalidPropertyValue';
            elseif verLessThan( 'matlab', '9.13' )
                errorID = 'MATLAB:datatypes:InvalidEnumValueFor';
            else
                errorID = ...
                    'MATLAB:datatypes:onoffboolean:IncorrectValue';
            end % if
            invalidSetter = @() set( component, 'Enable', {} );
            testCase.verifyError( invalidSetter, errorID, ...
                [ConstructorName, ' has not produced an ', ...
                'error with the expected ID when the ''Enable'' ', ...
                'property was set to an invalid value.'] )

        end % tContainerDynamicEnableSetMethod

        function tGetSelectedChild( testCase, ConstructorName )

            % Filter the test if the component does not have the
            % 'SelectedChild' property.
            testCase.assumeComponentHasSelectedChildProperty( ...
                ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that the 'SelectedChild' property is equal to [] (for
            % Panel and BoxPanel) or 0 (for CardPanel and TabPanel).
            if ismember( ConstructorName, ...
                    {'uiextras.CardPanel', 'uiextras.TabPanel'} )
                expectedValue = 0;
            else
                expectedValue = [];
            end % if
            testCase.verifyEqual( component.SelectedChild, ...
                expectedValue, ...
                ['The ''SelectedChild'' property of ', ...
                ConstructorName, ' is not equal to [].'] )

            % Add a child to the component.
            uicontrol( component )

            % Verify that the 'SelectedChild' property is equal to 1.
            testCase.verifyEqual( component.SelectedChild, 1, ...
                ['The ''SelectedChild'' property of ', ...
                ConstructorName, ' is not equal to 1.'] )

        end % tGetSelectedChild

        function tSetSelectedChild( testCase, ConstructorName )

            % Filter the test if the component does not have the
            % 'SelectedChild' property.
            testCase.assumeComponentHasSelectedChildProperty( ...
                ConstructorName )

            % Create the component.
            component = testCase.constructComponentWithChildren( ...
                ConstructorName );

            % Verify that setting the 'SelectedChild' property is
            % warning-free.
            setter = @() set( component, 'SelectedChild', 1 );
            testCase.verifyWarningFree( setter, ...
                [ConstructorName, ' did not accept setting the ', ...
                '''SelectedChild'' property.'] )

        end % tSetSelectedChild

        function tAutoResizeChildrenIsNotAProperty( ...
                testCase, ConstructorName )

            % This test is only for containers (not panels).
            testCase.assumeComponentIsAContainer( ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that it does not have the 'AutoResizeChildren'
            % property.
            hasAutoResizeChildren = ...
                isprop( component, 'AutoResizeChildren' );
            testCase.verifyFalse( hasAutoResizeChildren, ...
                ['The ', ConstructorName, ' component has the ', ...
                '''AutoResizeChildren'' property. '] )

        end % tAutoResizeChildrenIsNotAProperty

        function tAutoResizeChildrenIsOffForPanels( ...
                testCase, ConstructorName )

            % This test is only for panels (not containers).
            testCase.assumeComponentIsAPanel( ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % The 'AutoResizeChildren' property was added to
            % matlab.ui.container.Panel in R2017a, so we need to check
            % whether this property exists to accommodate older releases.
            if isprop( component, 'AutoResizeChildren' )
                autoResizeKids = char( component.AutoResizeChildren );
                testCase.verifyEqual( autoResizeKids, 'off', ...
                    ['Expected the ''AutoResizeChildren'' property ', ...
                    'of the ', ConstructorName, ' component to be ', ...
                    '''off''.'] )
            end % if

        end % tAutoResizeChildrenIsOffForPanels

        function tSettingAutoResizeChildrenToOffIsPreserved( ...
                testCase, ConstructorName )

            % This test is only for panels (not containers).
            testCase.assumeComponentIsAPanel( ConstructorName )

            % The 'AutoResizeChildren' property was added to
            % matlab.ui.container.Panel in R2017a, so we need to be in this
            % version or later to run this test.
            testCase.assumeMATLABVersionIsAtLeast( 'R2017a' )

            % Create the component, setting 'AutoResizeChildren' to 'off'.
            component = testCase.constructComponent( ConstructorName, ...
                'AutoResizeChildren', 'off' );

            % Verify that the constructor switched this property off.
            autoResizeKids = char( component.AutoResizeChildren );
            testCase.verifyEqual( autoResizeKids, 'off', ...
                ['The ', ConstructorName, ' constructor did not ', ...
                'turn off the ''AutoResizeChildren'' property.'] )

        end % tSettingAutoResizeChildrenToOffIsPreserved

    end % methods ( Test, Sealed )

    methods ( Test, Sealed, ParameterCombination = 'sequential' )

        function tConstructorIsWarningFreeWithArguments( ...
                testCase, ConstructorName, NameValuePairs )

            % Verify that creating the component and passing additional
            % input arguments to the constructor is warning-free.
            creator = @() testCase.constructComponent( ...
                ConstructorName, NameValuePairs{:} );
            testCase.verifyWarningFree( creator, ...
                ['The ', ConstructorName, ' constructor was not ', ...
                'warning-free when called with additional ', ...
                'input arguments.'] )

        end % tConstructorIsWarningFreeWithArguments

        function tConstructorWithArgumentsReturnsScalarComponent( ...
                testCase, ConstructorName, NameValuePairs )

            % Call the component constructor.
            component = testCase.constructComponent( ...
                ConstructorName, NameValuePairs{:} );

            % Assert that the type is correct.
            testCase.assertClass( component, ConstructorName, ...
                ['The ', ConstructorName, ...
                ' constructor did not return ', ...
                'an object of type ', ConstructorName, ' when called ', ...
                'with the ''Parent'' input argument and additional ', ...
                'input arguments.'] )

            % Assert that the returned object is a scalar.
            testCase.assertSize( component, [1, 1], ...
                ['The ', ConstructorName, ...
                ' constructor did not return ', ...
                'a scalar object when called with the ''Parent'' ', ...
                'input argument and additional input arguments.'] )

        end % tConstructorWithArgumentsReturnsScalarComponent

        function tConstructorSetsNameValuePairsCorrectly( ...
                testCase, ConstructorName, NameValuePairs )

            % Call the component constructor.
            component = testCase.constructComponent( ...
                ConstructorName, NameValuePairs{:} );

            % Verify that the component constructor has correctly assigned
            % the name-value pairs.
            for k = 1 : 2 : numel( NameValuePairs )-1
                propertyName = NameValuePairs{k};
                propertyValue = NameValuePairs{k+1};
                actualValue = component.(propertyName);
                if ~isa( propertyValue, 'function_handle' )
                    classOfPropertyValue = class( propertyValue );
                    actualValue = feval( ...
                        classOfPropertyValue, actualValue );
                end % if
                testCase.verifyEqual( actualValue, propertyValue, ...
                    ['The ', ConstructorName, ' constructor has not ', ...
                    'assigned the ''', propertyName, ''' property ', ...
                    'correctly.'] )
            end % for

        end % tConstructorSetsNameValuePairsCorrectly

        function tGetAndSetMethodsFunctionCorrectly( ...
                testCase, ConstructorName, NameValuePairs )

            % Construct the component.
            component = testCase.constructComponent( ConstructorName );

            % For each property, set its value and verify that the
            % component has correctly assigned the value.
            for k = 1 : 2 : numel( NameValuePairs )
                % Extract the current name-value pair.
                propertyName = NameValuePairs{k};
                propertyValue = NameValuePairs{k+1};
                try
                    % Set the property in the component.
                    component.(propertyName) = propertyValue;
                    % Verify that the property has been assigned correctly,
                    % up to a possible data type conversion.
                    actual = component.(propertyName);
                    if ~isa( propertyValue, 'function_handle' )
                        propertyClass = class( propertyValue );
                        actual = feval( propertyClass, actual );
                    end % if
                    testCase.verifyEqual( actual, propertyValue, ...
                        ['Setting the ''', propertyName, ...
                        ''' property of the ', ConstructorName, ...
                        ' object did not store the value correctly.'] )
                catch e
                    newExc = MException( ['SharedContainerTests:', ...
                        'SettingPropertyCausedError'], ...
                        ['Setting the property ', propertyName, ...
                        ' caused an error.'] );
                    newExc = newExc.addCause( e );
                    newExc.throw()
                end % try/catch
            end % for

        end % tGetAndSetMethodsFunctionCorrectly

    end % methods ( Test, Sealed, ParameterCombination = 'sequential' )

    methods ( Sealed, Access = protected )

        function [component, componentChildren] = ...
                constructComponentWithChildren( testCase, constructorName )

            % Create a component of the type specified by the
            % constructorName input. Add three buttons with red, green, and
            % blue background colors, with an empty space between green and
            % blue. Return the four child references in the output argument
            % componentChildren.
            component = testCase.constructComponent( constructorName );
            componentChildren = [
                uicontrol( 'Parent', component, 'BackgroundColor', 'r' )
                uicontrol( 'Parent', component, 'BackgroundColor', 'g' )
                uiextras.Empty( 'Parent', component )
                uicontrol( 'Parent', component, 'BackgroundColor', 'b' )];

        end % constructComponentWithChildren

        function assumeComponentIsFromNamespace( testCase, ...
                ConstructorName, namespace )

            % Check whether the given container, specified by
            % ConstructorName, belongs to the given namespace.
            condition = strncmp( ConstructorName, namespace, ...
                numel( namespace ) );
            testCase.assumeTrue( condition, ...
                ['The component ', ConstructorName, ...
                ' is not from the ', namespace, ' namespace.'] )

        end % assumeComponentIsFromNamespace

        function assumeComponentHasDynamicEnableProperty( ...
                testCase, ConstructorName )

            % Assume that the component, specified by ConstructorName, has
            % a dynamic 'Enable' property.
            testCase.assumeTrue( ismember( ConstructorName, ...
                testCase.ContainersWithDynamicEnableProperty ), ...
                ['The component ', ConstructorName, ' does not have ', ...
                'a dynamic ''Enable'' property.'] )

        end % assumeComponentHasDynamicEnableProperty

        function assumeComponentHasEnableGetSetMethods( ...
                testCase, ConstructorName )

            % Assume that the component, specified by ConstructorName, has
            % get and set methods defined for its 'Enable' property.
            testCase.assumeTrue( ismember( ConstructorName, ...
                testCase.ContainersWithEnableGetAndSetMethods ), ...
                ['The component ', ConstructorName, ' does not have ', ...
                'get and set methods defined for its ', ...
                '''Enable'' property.'] )

        end % assumeContainerHasEnableGetSetMethods

        function assumeComponentHasSelectedChildProperty( ...
                testCase, ConstructorName )

            % Assume that the component, specified by ConstructorName, has
            % the 'SelectedChild' property.
            testCase.assumeTrue( ismember( ConstructorName, ...
                testCase.ContainersWithSelectedChildProperty ), ...
                ['The component ', ConstructorName, ' does not have ', ...
                'the ''SelectedChild'' property.'] )

        end % assumeComponentHasSelectedChildProperty

        function assumeComponentIsAPanel( testCase, ConstructorName )

            % Assume that the component, specified by ConstructorName, has
            % matlab.ui.container.Panel as one of its superclasses.
            panelClassName = 'matlab.ui.container.Panel';
            isapanel = ismember( panelClassName, ...
                superclasses( ConstructorName ) );
            testCase.assumeTrue( isapanel, ...
                ['This test is only applicable to subclasses of ', ...
                panelClassName, '.'] )

        end % assumeComponentIsAPanel

        function assumeComponentIsAContainer( testCase, ConstructorName )

            % Assume that the component, specified by ConstructorName, has
            % uix.Container (and thus
            % matlab.ui.container.internal.UIContainer) as one of its
            % superclasses.
            containerClassName = 'uix.Container';
            isacontainer = ismember( containerClassName, ...
                superclasses( ConstructorName ) );
            testCase.assumeTrue( isacontainer, ...
                ['This test is only applicable to subclasses of ', ...
                containerClassName, '.'] )

        end % assumeComponentIsAContainer

        function assumeNotButtonBox( testCase, ConstructorName )

            % Assume that the component, specified by ConstructorName, is
            % not a button box.
            isabuttonbox = ismember( 'uix.ButtonBox', ...
                superclasses( ConstructorName ) );
            testCase.assumeFalse( isabuttonbox, ...
                'This test is not applicable to button boxes.' )

        end % assumeNotButtonBox

    end % methods ( Sealed, Access = protected )

end % classdef

function varargout = ...
    constructComponentWithoutFixture( ConstructorName, varargin )
%CONSTRUCTCOMPONENTWITHOUTFIXTURE Construct a component of type
%ConstructorName, passing optional name-value pair arguments to the
%constructor. Optionally, return the component reference as an output
%argument for further testing. This local function does not use the figure
%fixture to facilitate component testing without necessarily using the
%'Parent' input argument.

% Check the number of output arguments.
nargoutchk( 0, 1 )

% Construct the component.
component = feval( ConstructorName, varargin{:} );

% Ensure it is cleaned up.
componentCleanup = onCleanup( @() delete( component ) );

% Return the component reference, if required.
if nargout == 1
    varargout{1} = component;
end % if

end % constructComponentWithoutFixture