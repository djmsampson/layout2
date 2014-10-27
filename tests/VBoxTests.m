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
            
            testcase.verifyEqual(actualSizes, expectedSizes);
        end
           
        function testAxesPositionInVBoxes(testcase, ContainerType)
            %testAxesPosition  Test that axes get positioned properly
            [~, ax1, ax2] = testcase.hPositionAxesInBox(ContainerType);
            
            % Check that the axes sizes are correct.
            testcase.verifyEqual( get( ax1, 'OuterPosition' ), [1 251 500 250] );
            testcase.verifyEqual( get( ax2, 'Position' ), [1 1 500 250] );
        end
    end
    
    methods
        function [obj, ax1, ax2] = hPositionAxesInBox(testcase, type)
            obj = testcase.hCreateObj(type, ...
                {'Parent', figure, 'Units', 'Pixels', 'Position', [1 1 500 500]});
            ax1 = axes( 'Parent', obj, 'ActivePositionProperty', 'OuterPosition', 'Units', 'Pixels');
            ax2 = axes( 'Parent', obj, 'ActivePositionProperty', 'Position', 'Units', 'Pixels');
        end
        
        function [obj, expectedSizes] = hCreateAxesAndResizeFigure(testcase, type, resizedParameter)
            % create RGB box and set sizes to something relative and
            % absolute
            fig = figure('Position', [400 400 750 750]);
            [obj, ~] = testcase.hBuildRGBBox(type);
            set(obj, 'Spacing', 10, 'Parent', fig);
            set(obj, resizedParameter, [-3, -1, 50]);
            
            % resize figure
            fig.Position = [600, 600, 200, 200];            
            testcase.assertNumElements(obj.Contents, 3, ...
                sprintf('created box with %d elements instead of 3\n', numel(obj.Contents)) );
            
            % test rgb ui elements have correct sizes.
            
            % After the absolute sized element, remaining space is divided between two elements.
            % fig size is 200 -50 for 3rd block and -20 for 2*10px spacings.
            % this space is split into 4 parts, 1 part to Contents(2)
            % 3 parts to Contents(1)
            relativePartPxSize = (200 - 50 - 20)/4;
            expectedSizes = [relativePartPxSize*3, relativePartPxSize, 50];
        end
    end
    
end

