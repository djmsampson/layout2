classdef ContainerSharedTests < matlab.unittest.TestCase
    %CONTAINERSHAREDTESTS Tests common to all GUI Layout Toolbox
    %containers, including both the +uiextras and +uix packages.

    properties ( ClassSetupParameter )
        % Graphics parent type.
        ParentType = parentTypes()
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
        % the tests run. Tracking is disabled whilst the tests run.
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
            assumeMATLABVersionIsAtLeast( testCase, 'R2014b' )

        end % assumeMinimumMATLABVersion

        function setupToolboxPath( testCase )

            % Apply a path fixture for the GUI Layout Toolbox main folder.
            applyGLTFolderFixture( testCase )

        end % setupToolboxPath

        function setupFigureFixture( testCase, ParentType )

            % Apply a custom fixture to provide the top-level parent
            % graphics object for the GUI Layout Toolbox components during
            % the test procedures.
            applyFigureFixture( testCase, ParentType )

        end % setupFigureFixture

        function disableTrackingDuringTests( testCase )

            % Disable GUI Layout Toolbox tracking during the test
            % procedures. Restore the previous tracking state when the
            % tests are complete.
            disableTracking( testCase )

        end % disableTracking

    end % methods ( TestClassSetup )

    methods ( Test )

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

        %
        %         function testRepeatedConstructorArguments(testcase, ConstructorName)
        %             obj = testcase.constructComponent(ConstructorName, 'Tag', '1', 'Tag', '2', 'Tag', '3');
        %             testcase.verifyEqual(obj.Tag, '3');
        %         end
        %
        %         function testBadConstructorArguments(testcase, ConstructorName)
        %             badargs1 = 'BackgroundColor';
        %             badargs2 = 200;
        %             %badargs3 = {'Parent', 3}; % throws same error identifier as axes('Parent', 3)
        %             testcase.verifyError(@()testcase.constructComponent(ConstructorName, badargs1), 'uix:InvalidArgument');
        %             testcase.verifyError(@()testcase.constructComponent(ConstructorName, badargs2), 'uix:InvalidArgument');
        %         end
        %
        %         function testGetSet(testcase, ConstructorName, GetSetNameValuePairs)
        %             % Test the get/set functions for each class.
        %             % Class specific parameters/values should be specified in the
        %             % test parameter GetSetPVArgs
        %
        %             obj = testcase.hBuildRGBBox(ConstructorName);
        %
        %             % test get/set parameter value pairs in testcase.GetSetPVArgs
        %             for i = 1:2:(numel(GetSetNameValuePairs))
        %                 param    = GetSetNameValuePairs{i};
        %                 expected = GetSetNameValuePairs{i+1};
        %
        %                 set(obj, param, expected);
        %                 actual = get(obj, param);
        %
        %                 testcase.verifyEqual(actual, expected, ['testGetSet failed for ', param]);
        %             end
        %         end
        %
        %         function testChildObserverDoesNotIncorrectlyAddElements(testcase, ConstructorName)
        %             % test to cover g1148914:
        %             % "Setting child property Internal to its existing value causes
        %             % invalid ChildAdded or ChildRemoved events"
        %             obj = testcase.constructComponent(ConstructorName);
        %             el = uicontrol( 'Parent', obj);
        %             el.Internal = false;
        %             testcase.verifyNumElements(obj.Contents, 1);
        %         end
        %
        %         function testContents(testcase, ConstructorName)
        %             [obj, actualContents] = testcase.hBuildRGBBox(ConstructorName);
        %             testcase.assertEqual( obj.Contents, actualContents );
        %
        %             % Delete a child
        %             delete( actualContents(2) )
        %             testcase.verifyEqual( obj.Contents, actualContents([1 3 4]) );
        %
        %             % Reparent a child
        %             %fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
        %             %set( actualContents(3), 'Parent', fx.FigureHandle);
        %             set( actualContents(3), 'Parent', testcase.FigureFixture.Figure )
        %             testcase.verifyEqual( obj.Contents, actualContents([1 4]) );
        %         end
        %
        %         function testContentsAfterReorderingChildren(testcase, ConstructorName)
        %
        %             obj = testcase.constructComponent(ConstructorName);
        %             b1 = uicontrol('Parent', obj); %#ok<NASGU>
        %             c1 = uicontainer('Parent', obj); %#ok<NASGU>
        %             b2 = uicontrol('Parent', obj); %#ok<NASGU>
        %             c2 = uicontainer('Parent', obj); %#ok<NASGU>
        %             testcase.verifyLength(obj.Contents, 4)
        %             obj.Contents = flipud(obj.Contents);
        %             testcase.verifyLength(obj.Contents, 4)
        %             obj.Children = flipud(obj.Children);
        %             testcase.verifyLength(obj.Contents, 4)
        %
        %         end
        %
        %         function testAddingAxesToContainer(testcase, ConstructorName)
        %             testcase.assumeRooted() % TODO review
        %             testcase.assumeNotWeb() % TODO review
        %             % tests that sizing is retained when adding new data to
        %             % existing axis.
        %             obj = testcase.constructComponent(ConstructorName);
        %             ax1 = axes('Parent', obj);
        %             plot(ax1, rand(10,2));
        %             ax2 = axes('Parent', obj);
        %             plot(ax2, rand(10,2));
        %             testcase.assertNumElements(obj.Contents, 2);
        %             testcase.verifyClass(obj.Contents(1), 'matlab.graphics.axis.Axes');
        %             testcase.verifyClass(obj.Contents(2), 'matlab.graphics.axis.Axes');
        %             testcase.verifySameHandle(obj.Contents(1), ax1);
        %             testcase.verifySameHandle(obj.Contents(2), ax2);
        %         end
        %
        %         function testAxesStillVisibleAfterRotate3d(testcase, ConstructorName)
        %             % test for g1129721 where rotating an axis in a panel causes
        %             % the axis to lose visibility.
        %             testcase.assumeRooted() % TODO review
        %             testcase.assumeNotWeb() % TODO review
        %             obj = testcase.constructComponent(ConstructorName);
        %             con = uicontainer('Parent', obj);
        %             ax = axes('Parent', con, 'Visible', 'on');
        %             testcase.verifyEqual(char(ax.Visible), 'on');
        %             % equivalent of selecting the rotate button on figure window:
        %             rotate3d(obj.Parent);
        %             testcase.verifyEqual(char(ax.Visible), 'on');
        %         end
        %
        %         function testCheckDataCursorCanBeUsed(testcase, ConstructorName)
        %             testcase.assumeRooted()
        %             testcase.assumeNotWeb()
        %             obj = testcase.constructComponent(ConstructorName);
        %             if isprop( obj, 'ButtonSize' )
        %                 % Ensure that axes aren't tiny
        %                 obj.ButtonSize = [200 200];
        %             end
        %             ax = axes( 'Parent', obj );
        %             h = plot( ax, 1:10, rand(1,10) );
        %             dcm = datacursormode( obj.Parent );
        %             dcm.Enable = 'on';
        %
        %             drawnow
        %             positionBefore = ax.Position;
        %             drawnow
        %             dcm.createDatatip( h );
        %             drawnow
        %             positionAfter = ax.Position;
        %
        %             testcase.verifyEqual( positionBefore, positionAfter,...
        %                 'Data cursor messed the layout' )
        %         end
        %
        %         function testAxesToolbarReordering( testcase, ConstructorName )
        %             % test for g1911845 where axes toolbar causes axes to be
        %             % removed and readded, leading to unexpected reordering of
        %             % contents
        %             testcase.assumeRooted()
        %             obj = testcase.constructComponent(ConstructorName);
        %             ax = axes( 'Parent', obj );
        %             c = uicontrol( 'Parent', obj );
        %             testcase.verifyEqual( obj.Contents, [ax; c] ); % initially
        %             pause( 0.1 )
        %             testcase.verifyEqual( obj.Contents, [ax; c] ); % finally
        %         end

        function tContainerEnableGetMethod( testCase, ConstructorName )

            % Filter the test if the container does not have get and set 
            % methods for the 'Enable' property.
            testCase.assumeComponentHasEnableGetSetMethods( ...
                ConstructorName )

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = feval( ConstructorName, 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Verify that the 'Enable' property is set to 'on'.
            testCase.verifyEqual( container.Enable, 'on', ...
                ['The ''Enable'' property of the ', ConstructorName, ...
                'container is not set to ''on''.'] )

        end % tContainerEnableGetMethod

        function tContainerEnableSetMethod( testCase, ConstructorName )

            % Filter the test if the container does not have get and set 
            % methods for the 'Enable' property.
            testCase.assumeComponentHasEnableGetSetMethods( ...
                ConstructorName )

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = feval( ConstructorName, 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Check that setting 'on' or 'off' is accepted.
            for enable = {'on', 'off'}
                enableSetter = ...
                    @() set( container, 'Enable', enable{1} );
                testCase.verifyWarningFree( enableSetter, ...
                    [ConstructorName, ' has not accepted a value ', ...
                    'of ''', enable{1}, ...
                    ''' for the ''Enable'' property.'] )
            end % for

            % Check that setting an invalid value causes an error.
            errorID = 'uiextras:InvalidPropertyValue';
            invalidSetter = @() set( container, 'Enable', {} );
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

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = feval( ConstructorName, 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Verify that the 'Enable' property exists and is set to
            % 'on'.
            testCase.assertTrue( isprop( container, 'Enable' ), ...
                [ConstructorName, ' does not ', ...
                'have the ''Enable'' property.'] )
            testCase.verifyTrue( strcmp( container.Enable, 'on' ), ...
                ['The ''Enable'' property of the ', ...
                ConstructorName, ' is not set to ''on''.'] )

        end % tContainerDynamicEnableGetMethod

        function tContainerDynamicEnableSetMethod( ...
                testCase, ConstructorName )

            % Filter the test if the component does not have a dynamic
            % 'Enable' property.
            testCase.assumeComponentHasDynamicEnableProperty( ...
                ConstructorName )

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = uiextras.BoxPanel( 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Check that setting 'on' or 'off' is accepted.
            for enable = {'on', 'off'}
                enableSetter = ...
                    @() set( container, 'Enable', enable{1} );
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
            invalidSetter = @() set( container, 'Enable', {} );
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

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = feval( ConstructorName, 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Verify that the 'SelectedChild' property is equal to [].
            testCase.verifyEqual( container.SelectedChild, [], ...
                ['The ''SelectedChild'' property of ', ...
                ConstructorName, ' is not equal to [].'] )

            % Add a child to the box panel.
            uicontrol( container )

            % Verify that the 'SelectedChild' property is equal to 1.
            testCase.verifyEqual( container.SelectedChild, 1, ...
                ['The ''SelectedChild'' property of ', ...
                ConstructorName, ' is not equal to 1.'] )

        end % tGetSelectedChild

        function tSetSelectedChild( testCase, ConstructorName )

            % Filter the test if the component does not have the
            % 'SelectedChild' property.
            testCase.assumeComponentHasSelectedChildProperty( ...
                ConstructorName )

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = feval( ConstructorName, 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Verify that setting the 'SelectedChild' property is
            % warning-free.
            setter = @() set( container, 'SelectedChild', 1 );
            testCase.verifyWarningFree( setter, ...
                [ConstructorName, ' did not accept setting the ', ...
                '''SelectedChild'' property.'] )

        end % tSetSelectedChild

    end % methods ( Test )

    methods

        function component = constructComponent( ...
                testCase, constructorName, varargin )

            % Construct the component under test, using the figure fixture,
            % and passing through any arguments for the component
            % constructor.
            component = feval( constructorName, ...
                'Parent', testCase.FigureFixture.Figure, varargin{:} );
            testCase.addTeardown( @() delete( component ) )

        end % constructComponent

        function [obj, rgb] = hBuildRGBBox(testcase, type)
            % creates a Box of requested type and adds 3 uicontrols with
            % red, green, and blue background colours, with an empty space
            % between green and blue.
            obj = testcase.constructComponent( type );
            rgb = [
                uicontrol('Parent', obj, 'BackgroundColor', 'r')
                uicontrol('Parent', obj, 'BackgroundColor', 'g')
                uiextras.Empty('Parent', obj)
                uicontrol('Parent', obj, 'BackgroundColor', 'b') ];
        end

        function assumeRooted( testcase )
            %check that container is rooted
            testcase.assumeFalse( ...
                strcmp( testcase.FigureFixture.Type, testcase.ParentType.Unrooted ), ...
                'Not applicable to unrooted graphics.' );
        end % assumeRooted

        function assumeNotWeb( testcase )
            %check that container is not Web graphics
            testcase.assumeFalse( ...
                isfield( testcase.ParentType, 'WebFigure' ) && ...
                strcmp( testcase.FigureFixture.Type, testcase.ParentType.WebFigure ) , ...
                'Not applicable to Web graphics.' );
        end % assumeNotWeb

        function assumeDisplay( testcase )
            %check that environment has a display, for mouse tests
            thisFolder = fileparts( mfilename( 'fullpath' ) );
            batFolder = fullfile( matlabroot, 'test', 'fileexchangeapps', 'GUI_layout_toolbox', 'tests' );
            testcase.assumeFalse( ...
                strcmp( thisFolder, batFolder ), ...
                'Not applicable to headless BaT environment.');
            testcase.assumeTrue( ...
                isempty( getenv( 'JENKINS_HOME' ) ), ...
                'Not applicable to headless Jenkins environment.');
        end % assumeDisplay

    end % methods

    methods ( Access = protected )

        function assumeComponentIsFromNamespace( testCase, ...
                ConstructorName, namespace )

            % Check whether the given container, specified by
            % ConstructorName, belongs to the given namespace.
            condition = strncmp( ConstructorName, namespace, ...
                length( namespace ) );
            testCase.assumeTrue( condition, ...
                ['The component ', ConstructorName, ' is not from the ', ...
                namespace, ' namespace.'] )

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

    end % methods ( Access = protected )

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