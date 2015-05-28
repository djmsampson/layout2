classdef VBoxTests < matlab.unittest.TestCase
%VBOXTESTS Extra tests for VBox and VBoxFlex.

    properties (Abstract, TestParameter)
        ContainerType;
    end
    
    methods (Test)       
        function testResizeFigureRetainsElementSizesInVBoxes(testcase, ContainerType)
            % create RGB box and resize the whole figure
            [obj, expectedSizes] = testcase.hCreateAxesAndResizeFigure(ContainerType, 'Heights');
            
            actualSizes(1) = obj.Contents(1).Position(4);
            actualSizes(2) = obj.Contents(2).Position(4);
            actualSizes(3) = obj.Contents(3).Position(4);
            actualSizes(4) = obj.Contents(4).Position(4);
            
            testcase.verifyEqual(actualSizes, expectedSizes);
        end
           
        function testAxesPositionInVBoxes(testcase, ContainerType)
            %testAxesPosition  Test that axes get positioned properly
            obj = testcase.hCreateObj(ContainerType, ...
                {'Parent', figure, 'Units', 'Pixels', 'Position', [1 1 500 500]});
            ax1 = axes( 'Parent', obj, 'ActivePositionProperty', 'OuterPosition', 'Units', 'Pixels');
            ax2 = axes( 'Parent', obj, 'ActivePositionProperty', 'Position', 'Units', 'Pixels');
            
            % Check that the axes sizes are correct.
            testcase.verifyEqual( get( ax1, 'OuterPosition' ), [1 251 500 250] );
            testcase.verifyEqual( get( ax2, 'Position' ), [1 1 500 250] );
        end
    end
    
    methods      
        function [obj, expectedSizes] = hCreateAxesAndResizeFigure(testcase, type, resizedParameter)
            % create RGB box and set sizes to something relative and
            % absolute
            fig = figure('Position', [400 400 750 750]);
            [obj, ~] = testcase.hBuildRGBBox(type);
            set(obj, 'Padding', 10, 'Spacing', 10, 'Parent', fig);
            set(obj, resizedParameter, [-3, -1, -1, 50]);
            
            % resize figure
            fig.Position = [600, 600, 200, 200];            
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

