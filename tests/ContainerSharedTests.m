classdef ContainerSharedTests < matlab.unittest.TestCase
    %CONTAINERSHAREDTESTS Contains tests that are common to all uiextras container objects.
    
    properties (TestParameter, Abstract)
%         DefaultConstructionArgs;
        ContainerType;
        ConstructorArgs;
        GetSetArgs;
    end
    
    properties(Constant)
        % tells testrunner whether to run testAxesLegend and testAxesColorbar
        runAxesLegendAndColorbarTests = false;
    end
    
    methods(TestMethodTeardown)
        function closeAllOpenFigures(~)
            close all force;
        end
    end
    
    
    methods (Test)
        
        function testEmptyConstructor(testcase, ContainerType)
            % Test constructing the widget with no arguments
            obj = testcase.hCreateObj(ContainerType);
            testcase.assertClass(obj, ContainerType);
        end
        
        function testConstructorParentOnly(testcase, ContainerType)
            f = figure;
            obj = testcase.hCreateObj(ContainerType, {'Parent', f});
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
            badargs1 = {'Parent', gcf(), 'BackgroundColor'};
            badargs2 = {'Parent', gcf(), 200};
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
            testcase.verifyEqual( obj.Contents, actualContents([1,3]) );
            
            % Reparent a child
            set( actualContents(3), 'Parent', figure )
            testcase.verifyEqual( obj.Contents, actualContents(1) );
        end
        
        function testAddingAxesToContainer(testcase, ContainerType)
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
              
        function testAxesLegend(testcase, ContainerType)
            %testAxesLegend  Test that axes legends are ignored properly
            % This is test for g1019459.
            
            testcase.assumeTrue(testcase.runAxesLegendAndColorbarTests, ...
                'ignoring test for legends being added correctly');
            
            obj = testcase.hCreateObj(ContainerType, ...
                {'Parent', figure, 'Units', 'Pixels', 'Position', [1 1 500 500]}); 
            ax1 = axes( 'Parent', obj, 'ActivePositionProperty', 'OuterPosition', 'Units', 'Pixels' );
            plot( ax1, peaks(7) )
            legend( 'line 1', 'line 2', 'line 3', 'line 4', 'line 5', 'line 6', 'line 7' );            
            ax2 = axes( 'Parent', obj, 'ActivePositionProperty', 'Position', 'Units', 'Pixels' );
            imagesc( peaks(7), 'Parent', ax2 );
            
            % Check that the legend does not appear as a child
            testcase.verifyEqual( obj.Contents, [ax1;ax2] );
        end

        function testAxesColorbar(testcase, ContainerType)
            % testAxesColorbar  Test that axes colorbars are ignored properly
            % This is test for g1019459.
            testcase.assumeTrue(testcase.runAxesLegendAndColorbarTests, ...
                'ignoring test for colorbar being added correctly');
            
            obj = testcase.hCreateObj(ContainerType, ...
                {'Parent', figure, 'Units', 'Pixels', 'Position', [1 1 500 500]}); 
            ax1 = axes( 'Parent', obj, 'ActivePositionProperty', 'OuterPosition', 'Units', 'Pixels' );
            contourf( ax1, peaks(30) );
            colorbar( 'peer', ax1, 'location', 'EastOutside' )            
            ax2 = axes( 'Parent', obj, 'ActivePositionProperty', 'Position', 'Units', 'Pixels' );
            imagesc( peaks(7), 'Parent', ax2 );
            
            % Check that the legend doesn't appear as a child
            testcase.verifyEqual( obj.Contents, [ax1;ax2] );
        end
                
        function testAxesStillVisibleAfterRotate3d(testcase, ContainerType)
            % test for g1129721 where rotating an axis in a panel causes
            % the axis to lose visibility.
            obj = testcase.hCreateObj(ContainerType);
            con = uicontainer('Parent', obj);
            ax = axes('Parent', con, 'Visible', 'on');
            testcase.verifyEqual(ax.Visible, 'on');
            % equivalent of selecting the rotate button on figure window:
            rotate3d;
            testcase.verifyEqual(ax.Visible, 'on');
        end
    end
    
    methods
        function obj = hCreateObj(testcase, type, varargin)
            if(nargin > 2)
                obj = eval([type, '( varargin{1}{:} );']);
            else
                obj = eval(type);
            end
            testcase.assertClass(obj, type);
        end
        
        function [obj, rgb] = hBuildRGBBox(testcase, type)
            % creates a Box of requested type and adds 3 uicontrols with
            % red, green, and blue background colours.
            obj = testcase.hCreateObj(type);
            rgb = [
                uicontrol('Parent', obj, 'BackgroundColor', 'r')
                uicontrol('Parent', obj, 'BackgroundColor', 'g')
                uicontrol('Parent', obj, 'BackgroundColor', 'b') ];
        end
        
        function hVerifyHandleContainsParameterValuePairs(testcase, obj, args)
            % check that instance has correctly assigned parameter/value
            % pairs
            for i = 1:2:numel(args)
                param    = args{i};
                expected = args{i+1};
                actual   = get(obj, param);
                testcase.verifyEqual(actual, expected);
            end
        end
    end
    
end

