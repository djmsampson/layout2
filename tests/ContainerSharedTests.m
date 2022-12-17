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

    properties
        oldTracking = 'unset'
    end

    properties ( GetAccess = protected, SetAccess = private )
        % Figure fixture, providing the top-level parent
        % graphics object for the containers during the test procedures.
        % See also the ParentType class setup parameter and
        % matlab.unittest.fixtures.FigureFixture.
        FigureFixture
    end % properties ( GetAccess = protected, SetAccess = private )

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

        function enableUicontrol(testcase,ParentType)
            if strcmp(ParentType,'web')
                testcase.applyFixture(EnableUicontrolFixture);
            end
        end
        function setupPath(testcase)
            import matlab.unittest.fixtures.PathFixture
            testsFolder = fileparts( mfilename( 'fullpath' ) );
            projectFolder = fileparts( testsFolder );
            toolboxFolder = fullfile( projectFolder, 'tbx', 'layout' );
            testcase.applyFixture( PathFixture( toolboxFolder ) );
        end
        function disableTracking(testcase)
            testcase.oldTracking = uix.tracking( 'query' );
            uix.tracking( 'off' )
        end
    end

    methods(TestClassTeardown)
        function resetTracking(testcase)
            uix.tracking(testcase.oldTracking)
            testcase.oldTracking = 'unset';
        end
    end

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

    end % methods ( Test )

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