classdef ContainerSharedTests < matlab.unittest.TestCase
    %BOXSHAREDTESTS Contains tests that are common to all Box objects.
    
    properties (Abstract)
        DefaultConstructionArgs;
    end
    
    properties(Abstract, TestParameter)
        % list of all containers being tested by a subclass
        ContainerType;
        SpecialConstructionArgs;
        GetSetPVArgs;
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
        
        function testConstructionArguments(testcase, SpecialConstructionArgs)
            %testConstructionArguments  Test constructing the widget with optional arguments
            
            % first element in ConstructionArgs is the container type
            type = SpecialConstructionArgs{1};
            % adding parent gcf pair because gcf() is not executed when a
            % class parameter in DefaultConstructionArgs
            args = [{'Parent', gcf()}, testcase.DefaultConstructionArgs];
            
            if numel(SpecialConstructionArgs) > 1
                % if more constructor arguments are specified, append to
                % defaults.
                args = [args, SpecialConstructionArgs{2:end}];
            end
            % create Box of specified type
            obj = testcase.hCreateObj(type, args);
            
            testcase.assertClass(obj, type);
            testcase.hVerifyHandleContainsParameterValuePairs(obj, args);
        end
        
        function testRepeatedConstructorArgument(testcase, ContainerType)
            obj = testcase.hCreateObj(ContainerType, {'Tag', '1', 'Tag', '2', 'Tag', '3'});
            testcase.verifyEqual(obj.Tag, '3');
        end
        
        function testBadConstructionArguments(testcase, ContainerType)
            badargs1 = {'Parent', gcf(), 'BackgroundColor'};
            badargs2 = {'Parent', gcf(), 200};
            %badargs3 = {'Parent', 3}; % throws same error identifier as axes('Parent', 3)
            testcase.verifyError(@()testcase.hCreateObj(ContainerType, badargs1), 'uix:InvalidArgument');
            testcase.verifyError(@()testcase.hCreateObj(ContainerType, badargs2), 'uix:InvalidArgument');
        end
        
        function testGetSet(testcase, GetSetPVArgs)
            % Test the get/set functions for each class.
            % Class specific parameters/values should be specified in the
            % test parameter GetSetPVArgs
            
            % first element in GetSetPVArgs is the type
            type = GetSetPVArgs{1};
            obj = testcase.hBuildRGBBox(type);
            
            % test get/set parameter value pairs in testcase.GetSetPVArgs
            for i = 2:2:(numel(GetSetPVArgs)-1)
                param    = GetSetPVArgs{i};
                expected = GetSetPVArgs{i+1};
                
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
              
        function testAxesLegend(testcase, ContainerType)
            %testAxesLegend  Test that axes legends are ignored properly
            % This is test for g1019459.
            
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
            ax = axes('Parent', obj, 'Visible', 'on');
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

