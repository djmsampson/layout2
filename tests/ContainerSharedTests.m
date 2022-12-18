classdef ContainerSharedTests < matlab.unittest.TestCase
    %CONTAINERSHAREDTESTS Tests common to all GUI Layout Toolbox
    %containers, including both the +uiextras and +uix packages.

    properties ( ClassSetupParameter )
        % Graphics parent type.
        ParentType = parentTypes()
    end % properties ( ClassSetupParameter )

    properties ( TestParameter, Abstract )
        % The container type (constructor name).
        ContainerType
        % Name-value pairs to use when testing the constructor.
        ConstructorArgs
        % Name-value pairs to use when testing the get/set methods.
        GetSetArgs
    end % properties ( TestParameter, Abstract )

    properties ( GetAccess = protected, SetAccess = private )
        % Figure fixture, providing the top-level parent
        % graphics object for the containers during the test procedures.
        % See also the ParentType class setup parameter and
        % matlab.unittest.fixtures.FigureFixture.
        FigureFixture
    end % properties ( GetAccess = protected, SetAccess = private )

    properties ( Access = private )
        % Current GUI Layout Toolbox tracking status, to be restored after
        % the tests run. Tracking is disabled whilst the tests run.
        CurrentTrackingStatus = 'unset'
    end % properties ( Access = private )

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

        function applyFigureFixture( testCase, ParentType )

            if strcmp( ParentType, 'web' )
                % Filter all tests using a web figure graphics parent,
                % unless the MATLAB version supports the creation of
                % uicontrol objects in web figures.
                assumeMATLABVersionIsAtLeast( testCase, 'R2022a' )
            end % if

            % Create the figure fixture using the corresponding parent
            % type.
            figureFixture = matlab.unittest.fixtures.FigureFixture( ...
                ParentType );
            testCase.FigureFixture = ...
                testCase.applyFixture( figureFixture );

        end % applyFigureFixture

        function disableTracking(testCase)

            % Store the current tracking status.
            testCase.CurrentTrackingStatus = uix.tracking( 'query' );

            % Disable tracking for the duration of the tests.
            uix.tracking( 'off' )
            testCase.addTeardown( @restoreTrackingStatus )

            function restoreTrackingStatus()

                uix.tracking( testCase.CurrentTrackingStatus )
                testCase.CurrentTrackingStatus = 'unset';

            end % restoreTrackingStatus

        end % disableTracking

        function enableUicontrol( testCase, ParentType )
            if strcmp(ParentType,'web')
                testCase.applyFixture(EnableUicontrolFixture);
            end
        end

        function setupPath( testCase )
            import matlab.unittest.fixtures.PathFixture
            testsFolder = fileparts( mfilename( 'fullpath' ) );
            projectFolder = fileparts( testsFolder );
            toolboxFolder = fullfile( projectFolder, 'tbx', 'layout' );
            testCase.applyFixture( PathFixture( toolboxFolder ) );
        end

    end % methods ( TestClassSetup )

    methods ( Test )

        function testEmptyConstructor(testcase, ContainerType)
            % Test constructing the widget with no arguments
            obj = testcase.hCreateObj(ContainerType);
            testcase.assertClass(obj, ContainerType);
        end

        function testConstructorParentOnly(testcase, ContainerType)
            obj = testcase.hCreateObj(ContainerType);
            testcase.assertClass(obj, ContainerType);
        end

        function testConstructorArguments(testcase, ContainerType, ConstructorArgs)
            %testConstructionArguments  Test constructing the widget with optional arguments

            % create Box of specified type
            obj = testcase.hCreateObj(ContainerType, ConstructorArgs);

            testcase.assertClass(obj, ContainerType);
            testcase.hVerifyHandleContainsParameterValuePairs(obj, ConstructorArgs);
        end

        function testRepeatedConstructorArguments(testcase, ContainerType)
            obj = testcase.hCreateObj(ContainerType, {'Tag', '1', 'Tag', '2', 'Tag', '3'});
            testcase.verifyEqual(obj.Tag, '3');
        end

        function testBadConstructorArguments(testcase, ContainerType)
            badargs1 = {'BackgroundColor'};
            badargs2 = {200};
            %badargs3 = {'Parent', 3}; % throws same error identifier as axes('Parent', 3)
            testcase.verifyError(@()testcase.hCreateObj(ContainerType, badargs1), 'uix:InvalidArgument');
            testcase.verifyError(@()testcase.hCreateObj(ContainerType, badargs2), 'uix:InvalidArgument');
        end

        function testGetSet(testcase, ContainerType, GetSetArgs)
            % Test the get/set functions for each class.
            % Class specific parameters/values should be specified in the
            % test parameter GetSetPVArgs

            obj = testcase.hBuildRGBBox(ContainerType);

            % test get/set parameter value pairs in testcase.GetSetPVArgs
            for i = 1:2:(numel(GetSetArgs))
                param    = GetSetArgs{i};
                expected = GetSetArgs{i+1};

                set(obj, param, expected);
                actual = get(obj, param);

                testcase.verifyEqual(actual, expected, ['testGetSet failed for ', param]);
            end
        end

        function testChildObserverDoesNotIncorrectlyAddElements(testcase, ContainerType)
            % test to cover g1148914:
            % "Setting child property Internal to its existing value causes
            % invalid ChildAdded or ChildRemoved events"
            obj = testcase.hCreateObj(ContainerType);
            el = uicontrol( 'Parent', obj);
            el.Internal = false;
            testcase.verifyNumElements(obj.Contents, 1);
        end

        function testContents(testcase, ContainerType)
            [obj, actualContents] = testcase.hBuildRGBBox(ContainerType);
            testcase.assertEqual( obj.Contents, actualContents );

            % Delete a child
            delete( actualContents(2) )
            testcase.verifyEqual( obj.Contents, actualContents([1 3 4]) );

            % Reparent a child
            %fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            %set( actualContents(3), 'Parent', fx.FigureHandle);
            set( actualContents(3), 'Parent', testcase.FigureFixture.Figure )
            testcase.verifyEqual( obj.Contents, actualContents([1 4]) );
        end

        function testContentsAfterReorderingChildren(testcase, ContainerType)

            obj = testcase.hCreateObj(ContainerType);
            b1 = uicontrol('Parent', obj); %#ok<NASGU>
            c1 = uicontainer('Parent', obj); %#ok<NASGU>
            b2 = uicontrol('Parent', obj); %#ok<NASGU>
            c2 = uicontainer('Parent', obj); %#ok<NASGU>
            testcase.verifyLength(obj.Contents, 4)
            obj.Contents = flipud(obj.Contents);
            testcase.verifyLength(obj.Contents, 4)
            obj.Children = flipud(obj.Children);
            testcase.verifyLength(obj.Contents, 4)

        end

        function testAddingAxesToContainer(testcase, ContainerType)
            testcase.assumeRooted() % TODO review
            testcase.assumeNotWeb() % TODO review
            % tests that sizing is retained when adding new data to
            % existing axis.
            obj = testcase.hCreateObj(ContainerType);
            ax1 = axes('Parent', obj);
            plot(ax1, rand(10,2));
            ax2 = axes('Parent', obj);
            plot(ax2, rand(10,2));
            testcase.assertNumElements(obj.Contents, 2);
            testcase.verifyClass(obj.Contents(1), 'matlab.graphics.axis.Axes');
            testcase.verifyClass(obj.Contents(2), 'matlab.graphics.axis.Axes');
            testcase.verifySameHandle(obj.Contents(1), ax1);
            testcase.verifySameHandle(obj.Contents(2), ax2);
        end

        function testAxesStillVisibleAfterRotate3d(testcase, ContainerType)
            % test for g1129721 where rotating an axis in a panel causes
            % the axis to lose visibility.
            testcase.assumeRooted() % TODO review
            testcase.assumeNotWeb() % TODO review
            obj = testcase.hCreateObj(ContainerType);
            con = uicontainer('Parent', obj);
            ax = axes('Parent', con, 'Visible', 'on');
            testcase.verifyEqual(char(ax.Visible), 'on');
            % equivalent of selecting the rotate button on figure window:
            rotate3d(obj.Parent);
            testcase.verifyEqual(char(ax.Visible), 'on');
        end

        function testCheckDataCursorCanBeUsed(testcase, ContainerType)
            testcase.assumeRooted()
            testcase.assumeNotWeb()
            obj = testcase.hCreateObj(ContainerType);
            if isprop( obj, 'ButtonSize' )
                % Ensure that axes aren't tiny
                obj.ButtonSize = [200 200];
            end
            ax = axes( 'Parent', obj );
            h = plot( ax, 1:10, rand(1,10) );
            dcm = datacursormode( obj.Parent );
            dcm.Enable = 'on';

            drawnow
            positionBefore = ax.Position;
            drawnow
            dcm.createDatatip( h );
            drawnow
            positionAfter = ax.Position;

            testcase.verifyEqual( positionBefore, positionAfter,...
                'Data cursor messed the layout' )
        end

        function testAxesToolbarReordering( testcase, ContainerType )
            % test for g1911845 where axes toolbar causes axes to be
            % removed and readded, leading to unexpected reordering of
            % contents
            testcase.assumeRooted()
            obj = testcase.hCreateObj(ContainerType);
            ax = axes( 'Parent', obj );
            c = uicontrol( 'Parent', obj );
            testcase.verifyEqual( obj.Contents, [ax; c] ); % initially
            pause( 0.1 )
            testcase.verifyEqual( obj.Contents, [ax; c] ); % finally
        end

        function tAutoParentBehaviorIsCorrect( testCase, ContainerType )

            % Testing auto-parenting behavior only applies to containers in
            % the uiextras namespace. Containers in the uix namespace do
            % not exhibit auto-parenting behavior.
            testCase.assumeComponentIsFromUiextrasNamespace( ...
                ContainerType )

            % Create a new figure.
            newFig = figure();
            testCase.addTeardown( @() delete( newFig ) )

            % Instantiate the component, without specifying the parent.
            component = feval( ContainerType );
            testCase.addTeardown( @() delete( component ) )

            % Verify that the parent of the component is the new figure we
            % created above.
            testCase.verifySameHandle( component.Parent, newFig, ...
                [ContainerType, ' has not auto-parented correctly.'] )

        end % tAutoParentBehaviorIsCorrect

        function tContainerEnableGetMethod( testCase, ContainerType )

            % Filter the test if the container does not get and set methods
            % for the 'Enable' property.
            testCase.assumeComponentHasEnableGetSetMethods( ContainerType )

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = feval( ContainerType, 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Verify that the 'Enable' property is set to 'on'.
            testCase.verifyEqual( container.Enable, 'on', ...
                ['The ''Enable'' property of the ', ContainerType, ...
                'container is not set to ''on''.'] )

        end % tContainerEnableGetMethod

        function tContainerEnableSetMethod( testCase, ContainerType )

            % Filter the test if the container does not get and set methods
            % for the 'Enable' property.
            testCase.assumeComponentHasEnableGetSetMethods( ContainerType )

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = feval( ContainerType, 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Check that setting 'on' or 'off' is accepted.
            for enable = {'on', 'off'}
                enableSetter = ...
                    @() set( container, 'Enable', enable{1} );
                testCase.verifyWarningFree( enableSetter, ...
                    [ContainerType, ' has not accepted a value ', ...
                    'of ''', enable{1}, ...
                    ''' for the ''Enable'' property.'] )
            end % for

            % Check that setting an invalid value causes an error.
            errorID = 'uiextras:InvalidPropertyValue';
            invalidSetter = @() set( container, 'Enable', {} );
            testCase.verifyError( invalidSetter, errorID, ...
                [ContainerType, ' has not produced an ', ...
                'error with the expected ID when the ''Enable'' ', ...
                'property was set to an invalid value.'] )

        end % tContainerEnableSetMethod

        function tContainerDynamicEnableGetMethod( ...
                testCase, ContainerType )

            % Filter the test if the component does not have a dynamic
            % 'Enable' property.
            testCase.assumeComponentHasDynamicEnableProperty( ...
                ContainerType )

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = feval( ContainerType, 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Verify that the 'Enable' property exists and is set to
            % 'on'.
            testCase.assertTrue( isprop( container, 'Enable' ), ...
                [ContainerType, ' does not ', ...
                'have the ''Enable'' property.'] )
            testCase.verifyTrue( strcmp( container.Enable, 'on' ), ...
                ['The ''Enable'' property of the ', ...
                ContainerType, ' is not set to ''on''.'] )

        end % tContainerDynamicEnableGetMethod

        function tContainerDynamicEnableSetMethod( ...
                testCase, ContainerType )

            % Filter the test if the component does not have a dynamic
            % 'Enable' property.
            testCase.assumeComponentHasDynamicEnableProperty( ...
                ContainerType )

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = uiextras.BoxPanel( 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Check that setting 'on' or 'off' is accepted.
            for enable = {'on', 'off'}
                enableSetter = ...
                    @() set( container, 'Enable', enable{1} );
                testCase.verifyWarningFree( enableSetter, ...
                    [ContainerType, ' has not accepted a value ', ...
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
                [ContainerType, ' has not produced an ', ...
                'error with the expected ID when the ''Enable'' ', ...
                'property was set to an invalid value.'] )

        end % tContainerDynamicEnableSetMethod

        function tGetSelectedChild( testCase, ContainerType )

            % Filter the test if the component does not have the
            % 'SelectedChild' property.
            testCase.assumeComponentHasSelectedChildProperty( ...
                ContainerType )

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = feval( ContainerType, 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Verify that the 'SelectedChild' property is equal to [].
            testCase.verifyEqual( container.SelectedChild, [], ...
                ['The ''SelectedChild'' property of ', ...
                ContainerType, ' is not equal to [].'] )

            % Add a child to the box panel.
            uicontrol( container )

            % Verify that the 'SelectedChild' property is equal to 1.
            testCase.verifyEqual( container.SelectedChild, 1, ...
                ['The ''SelectedChild'' property of ', ...
                ContainerType, ' is not equal to 1.'] )

        end % tGetSelectedChild

        function tSetSelectedChild( testCase, ContainerType )

            % Filter the test if the component does not have the
            % 'SelectedChild' property.
            testCase.assumeComponentHasSelectedChildProperty( ...
                ContainerType )

            % Create a container.
            fig = testCase.FigureFixture.Figure;
            container = feval( ContainerType, 'Parent', fig );
            testCase.addTeardown( @() delete( container ) )

            % Verify that setting the 'SelectedChild' property is
            % warning-free.
            setter = @() set( container, 'SelectedChild', 1 );
            testCase.verifyWarningFree( setter, ...
                [ContainerType, ' did not accept setting the ', ...
                '''SelectedChild'' property.'] )

        end % tSetSelectedChild

    end % methods ( Test )

    methods ( Access = protected )

        function assumeComponentIsFromUiextrasNamespace( ...
                testCase, ContainerType )

            % Assume that the component, specified by ContainerType, is
            % from the uiextras namespace.
            namespace = 'uiextras';
            condition = strncmp( ContainerType, namespace, ...
                length( namespace ) );
            testCase.assumeTrue( condition, ...
                ['The component ', ContainerType, ' is not from the ', ...
                'uiextras namespace.'] )

        end % assumeComponentIsFromUiextrasNamespace

        function assumeComponentHasDynamicEnableProperty( ...
                testCase, ContainerType )

            % Assume that the component, specified by ContainerType, has a
            % dynamic 'Enable' property.
            testCase.assumeTrue( ismember( ContainerType, ...
                testCase.ContainersWithDynamicEnableProperty ), ...
                ['The component ', ContainerType, ' does not have ', ...
                'a dynamic ''Enable'' property.'] )

        end % assumeComponentHasDynamicEnableProperty

        function assumeComponentHasEnableGetSetMethods( ...
                testCase, ContainerType )

            % Assume that the component, specified by ContainerType, has
            % get and set methods defined for its 'Enable' property.
            testCase.assumeTrue( ismember( ContainerType, ...
                testCase.ContainersWithEnableGetAndSetMethods ), ...
                ['The component ', ContainerType, ' does not have ', ...
                'get and set methods defined for its ', ...
                '''Enable'' property.'] )

        end % assumeContainerHasEnableGetSetMethods

        function assumeComponentHasSelectedChildProperty( ...
                testCase, ContainerType )

            % Assume that the component, specified by ContainerType, has
            % the 'SelectedChild' property.
            testCase.assumeTrue( ismember( ContainerType, ...
                testCase.ContainersWithSelectedChildProperty ), ...
                ['The component ', ContainerType, ' does not have ', ...
                'the ''SelectedChild'' property.'] )

        end % assumeComponentHasSelectedChildProperty

    end % methods ( Access = protected )

    methods

        function obj = hCreateObj(testcase,type,varargin)
            if ~strcmp(testcase.FigureFixture.Type,'unrooted')
                % Create required figure
                %testcase.FigureFixture = testcase.applyFixture(FigureFixture(testcase.parentStr));
                if(nargin > 2)
                    %obj = feval(type,'Parent',testcase.FigureFixture.FigureHandle,varargin{1}{:});
                    obj = feval(type, 'Parent', testcase.FigureFixture.Figure, varargin{1}{:});
                else
                    %obj = feval(type,'Parent',testcase.FigureFixture.FigureHandle);
                    obj = feval(type, 'Parent', testcase.FigureFixture.Figure);
                end
            else % unparented
                if(nargin > 2)
                    %obj = eval([type, '(''Parent'', ', testcase.parentStr, ', varargin{1}{:});']);
                    obj = eval([type, '(''Parent'', ', '[]', ', varargin{1}{:});']);
                else
                    %obj = eval([type, '(''Parent'', ', testcase.parentStr, ')']);
                    obj = eval([type, '(''Parent'', ', '[]', ')']);
                end
            end

        end

        function [obj, rgb] = hBuildRGBBox(testcase, type)
            % creates a Box of requested type and adds 3 uicontrols with
            % red, green, and blue background colours, with an empty space
            % between green and blue.
            obj = testcase.hCreateObj(type);
            rgb = [
                uicontrol('Parent', obj, 'BackgroundColor', 'r')
                uicontrol('Parent', obj, 'BackgroundColor', 'g')
                uiextras.Empty('Parent', obj)
                uicontrol('Parent', obj, 'BackgroundColor', 'b') ];
        end

        function hVerifyHandleContainsParameterValuePairs(testcase, obj, args)
            % check that instance has correctly assigned parameter/value
            % pairs
            for i = 1:2:numel(args)
                param    = args{i};
                expected = args{i+1};
                actual   = get(obj, param);
                convert = str2func( class( expected ) );
                testcase.assertWarningFree(@()convert(actual));
                actual = convert( actual ); % cast
                testcase.verifyEqual(actual, expected);
            end
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

end % class