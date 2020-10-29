classdef HBoxTests < matlab.unittest.TestCase
    %HBOXTESTS Extra tests for HBox and HBoxFlex.
    
    properties (Abstract, TestParameter)
        ContainerType;
    end
    
    methods (Test) 
        function testResizeFigureRetainsElementSizesInHBoxes(testcase, ContainerType)
            % filter if unparented
            testcase.assumeFalse(strcmp(testcase.parentStr,'[]'),...
                'Not applicable for unparented');
            % create RGB box and resize the whole figure
            [obj, expectedSizes] = testcase.hCreateAxesAndResizeFigure(ContainerType, 'Width');
            
            actualSizes(1) = obj.Contents(1).Position(3);
            actualSizes(2) = obj.Contents(2).Position(3);
            actualSizes(3) = obj.Contents(3).Position(3);
            actualSizes(4) = obj.Contents(4).Position(3);
            
            testcase.verifyEqual(actualSizes, expectedSizes);
        end      
       
        function testAxesPositionInHBoxes(testcase, ContainerType)
            %testAxesPosition  Test that axes get positioned properly
            obj = testcase.hCreateObj(ContainerType, ...
                {'Units', 'Pixels', 'Position', [1 1 500 500], 'Spacing', 0}); %'Parent', figure, 
            ax1 = axes( 'Parent', obj, 'ActivePositionProperty', 'OuterPosition', 'Units', 'Pixels');
            ax2 = axes( 'Parent', obj, 'ActivePositionProperty', 'Position', 'Units', 'Pixels');            
            % If unparented, reparent to a figure
            if strcmp(testcase.parentStr,'[]')
                fx = testcase.applyFixture(FigureFixture('figure'));
                obj.Parent = fx.FigureHandle;
            end
            % Check that the axes sizes are correct.
            testcase.verifyEqual( get( ax1, 'OuterPosition' ), [1 1 250 500] );
            testcase.verifyEqual( get( ax2, 'Position' ), [251 1 250 500] );
        end
        
        function testMinimumSizes(testcase, ContainerType)
            %testMinimumSizes Test that minimum size is honored (g1329485)
            
            obj = testcase.hCreateObj(ContainerType, ...
                {'Units', 'Pixels', 'Position', [1 1 1000 500]});  
            
            for ii = 1:5 
                ui(ii) = uicontrol( 'Parent', obj, 'String', num2str( ii ) );  %#ok<AGROW>
            end
            
            obj.Widths = [100 100 -1 -1 -2]; 
            obj.MinimumWidths(:) = 100;

            % Squeeze right, verify that all elements obey their MinimumWidth setting                
            obj.Position(3) = 400; 
            
            % If unparented, reparent to a figure
            if strcmp(testcase.parentStr,'[]')
                fx = testcase.applyFixture(FigureFixture('figure'));
                obj.Parent = fx.FigureHandle;
            end
            
            for ii = 1:5
                testcase.verifyEqual(ui(ii).Position(3), 100);
            end
        end

    end
    
    methods        
        function [obj, expectedSizes] = hCreateAxesAndResizeFigure(testcase, type, resizedParameter)
            % create RGB box and set sizes to something relative and
            % absolute
            [obj, ~] = testcase.hBuildRGBBox(type);
            testcase.figfx.FigureHandle.Position = [400 400 750 750];
            
            set(obj, 'Padding', 10, 'Spacing', 10);
            set(obj, resizedParameter, [-3, -1, -1, 50]);
            
            % resize figure
            testcase.figfx.FigureHandle.Position = [600, 600, 200, 200];            
            testcase.assertNumElements(obj.Contents, 4, ...
                sprintf('created box with %d elements instead of 4\n', numel(obj.Contents)) );
            
            % test rgb ui elements have correct sizes.
            
            % After the absolute sized element (50), the padding (2x10) and
            % the spacing (3x10), remaining space is divided between three
            % elements.
            relativePartPxSize = (200 - 50 - 30 - 20)/5;
            expectedSizes = [relativePartPxSize*3, relativePartPxSize, relativePartPxSize, 50];
        end
    end
    
end

