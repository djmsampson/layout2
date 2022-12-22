classdef ( Abstract ) ContainerTests < matlab.unittest.TestCase
    %CONTAINERTESTS Tests common to all GUI Layout Toolbox containers,
    %across both the +uiextras and +uix packages.

    properties ( ClassSetupParameter )
        % Graphics parent type ('legacy'|'web'|'unrooted'). See also
        % parentTypes.
        ParentType = utilities.parentTypes()
    end % properties ( ClassSetupParameter )

    properties ( TestParameter, Abstract )
        % The constructor name, or class, of the component under test.
        ConstructorName
        % Name-value pair input arguments to use when testing the component
        % constructor.
        ConstructorInputArguments
        % Name-value pairs to use when testing the component's get and set
        % methods.
        GetSetNameValuePairs
    end % properties ( TestParameter, Abstract )

    properties
        % Figure fixture, providing the top-level parent
        % graphics object for the components during the test procedures.
        % See also the ParentType class setup parameter and
        % matlab.unittest.fixtures.FigureFixture.
        FigureFixture
        % Current GUI Layout Toolbox tracking status, to be restored after
        % the tests run. Tracking will be disabled whilst the tests run.
        CurrentTrackingStatus = 'unset'
    end % properties

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
            'uiextras.Panel'
            }
    end % properties ( Constant )

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
            % procedures. Restore the previous tracking state when the
            % tests are complete.
            utilities.disableTracking( testCase )

        end % disableTracking

    end % methods ( TestClassSetup )

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

        function tConstructorIsWarningFreeWithArguments( ...
                testCase, ConstructorName, ConstructorInputArguments )

            % Verify that creating the component and passing additional
            % input arguments to the constructor is warning-free.
            creator = @() testCase.constructComponent( ...
                ConstructorName, ConstructorInputArguments{:} );
            testCase.verifyWarningFree( creator, ...
                ['The ', ConstructorName, ' constructor was not ', ...
                'warning-free when called with additional ', ...
                'input arguments.'] )

        end % tConstructorIsWarningFreeWithArguments

        function tConstructorWithArgumentsReturnsScalarComponent( ...
                testCase, ConstructorName, ConstructorInputArguments )

            % Call the component constructor.
            component = testCase.constructComponent( ...
                ConstructorName, ConstructorInputArguments{:} );

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
                testCase, ConstructorName, ConstructorInputArguments )

            % Call the component constructor.
            component = testCase.constructComponent( ...
                ConstructorName, ConstructorInputArguments{:} );

            % Verify that the component constructor has correctly assigned
            % the name-value pairs.
            for k = 1 : 2 : length( ConstructorInputArguments )-1
                propertyName = ConstructorInputArguments{k};
                propertyValue = ConstructorInputArguments{k+1};
                actualValue = component.(propertyName);
                classOfPropertyValue = class( propertyValue );
                actualValue = feval( classOfPropertyValue, actualValue );
                testCase.verifyEqual( actualValue, propertyValue, ...
                    ['The ', ConstructorName, ' constructor has not ', ...
                    'assigned the ''', propertyName, ''' property ', ...
                    'correctly.'] )
            end % for

        end % tConstructorSetsNameValuePairsCorrectly

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

        function tGetAndSetMethodsFunctionCorrectly( ...
                testCase, ConstructorName, GetSetNameValuePairs )

            % Construct the component, with children.
            component = testCase.constructComponentWithChildren( ...
                ConstructorName );

            % For each property, set its value and verify that the
            % component has correctly assigned the value.
            for k = 1 : 2 : length( GetSetNameValuePairs )
                % Extract the current name-value pair.
                propertyName = GetSetNameValuePairs{k};
                propertyValue = GetSetNameValuePairs{k+1};
                % Set the property in the component.
                component.(propertyName) = propertyValue;
                % Verify that the property has been assigned correctly.
                actual = component.(propertyName);
                testCase.verifyEqual( actual, propertyValue, ...
                    ['Setting the ''', propertyName, ''' property of ', ...
                    'the ', ConstructorName, ' object did not store ', ...
                    'the value correctly.'] )
            end % for

        end % tGetAndSetMethodsFunctionCorrectly

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
            kids(2).Parent = testCase.FigureFixture.Figure;
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

        function tEnablingDataCursorModePreservesAxesPosition( ...
                testCase, ConstructorName )

            % Data cursor mode only works in Java figures, so we need to
            % exclude the unrooted and Web figure cases.
            testCase.assumeGraphicsAreRooted()
            testCase.assumeGraphicsAreNotWebBased()

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

            % Enable data cursor mode.
            dcm = datacursormode( component.Parent );
            dcm.Enable = 'on';
            drawnow()

            % Capture the current axes position, add a datatip, then
            % capture the axes position again.
            oldPosition = ax.Position;
            dcm.createDatatip( p );
            drawnow()
            newPosition = ax.Position;

            % Verify that the axes 'Position' property has not changed.
            testCase.verifyEqual( newPosition, oldPosition, ...
                ['Enabling data cursor mode on an axes in a ', ...
                ConstructorName, ' component caused the axes ', ...
                '''Position'' property to change.'] )

        end % tEnablingDataCursorModePreservesAxesPosition

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
            if verLessThan( 'matlab', '9.9' )
                errorID = 'uiextras:InvalidPropertyValue';
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

            % Verify that the 'SelectedChild' property is equal to [].
            testCase.verifyEqual( component.SelectedChild, [], ...
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
            component = testCase.constructComponent( ConstructorName );

            % Verify that setting the 'SelectedChild' property is
            % warning-free.
            setter = @() set( component, 'SelectedChild', 1 );
            testCase.verifyWarningFree( setter, ...
                [ConstructorName, ' did not accept setting the ', ...
                '''SelectedChild'' property.'] )

        end % tSetSelectedChild

    end % methods ( Test, Sealed )

    methods ( Sealed )

        function component = constructComponent( ...
                testCase, constructorName, varargin )

            % Construct the component under test, using the figure fixture,
            % and passing through any arguments for the component
            % constructor.
            component = feval( constructorName, ...
                'Parent', testCase.FigureFixture.Figure, varargin{:} );
            testCase.addTeardown( @() delete( component ) )

        end % constructComponent

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

        function assumeGraphicsAreRooted( testCase )

            % Assume that the component under test is rooted (i.e., there
            % is a nonempty top-level figure or uifigure ancestor).
            unrooted = strcmp( testCase.FigureFixture.Type, ...
                testCase.ParentType.Unrooted );
            testCase.assumeFalse( unrooted, ...
                'This test is not applicable to unrooted components.' )

        end % assumeGraphicsAreRooted

        function assumeGraphicsAreNotWebBased( testCase )

            % Assume that the component under test does not have a
            % top-level web figure ancestor.
            webBased = strcmp( testCase.FigureFixture.Type, ...
                testCase.ParentType.WebFigure );
            testCase.assumeFalse( webBased, ...
                ['This test is not applicable to components ', ...
                'based in web figures.'] )

        end % assumeGraphicsAreNotWebBased

        function assumeTestEnvironmentHasDisplay( testCase )

            % Check that the test environment has a display. This is
            % required for the mouse tests used for the flexible
            % containers.
            currentFolder = fileparts( mfilename( 'fullpath' ) );
            BaTFolder = fullfile( matlabroot(), 'test', ...
                'fileexchangeapps', 'GUI_layout_toolbox', 'tests' );
            inBaTFolder = strcmp( currentFolder, BaTFolder );
            testCase.assumeFalse( inBaTFolder, ...
                ['This test is not applicable in the BaT ', ...
                'environment. A display is required to run ', ...
                'the mouse tests.'] )

            % Check that the test environment is not Jenkins.
            isJenkins = ~isempty( getenv( 'JENKINS_HOME' ) );
            testCase.assumeFalse( isJenkins, ...
                ['This test is not applicable when running in ', ...
                'the Jenkins environment.'] )

        end % assumeTestEnvironmentHasDisplay

    end % methods ( Sealed )

    methods ( Sealed, Access = protected )

        function assumeComponentIsFromNamespace( testCase, ...
                ConstructorName, namespace )

            % Check whether the given container, specified by
            % ConstructorName, belongs to the given namespace.
            condition = strncmp( ConstructorName, namespace, ...
                length( namespace ) );
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

    end % methods ( Sealed, Access = protected )

end % class

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