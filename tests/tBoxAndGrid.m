classdef tBoxAndGrid < ContainerSharedTests
    %TBOXANDGRID Runs parameterised tests for HBox, VBox, Grid, HBoxFlex,
    %VBoxFlex, GridFlex.
    
    properties (TestParameter)
        ContainerType = {
            'uiextras.HBox'
            'uiextras.VBox'
            'uiextras.HBoxFlex'
            'uiextras.VBoxFlex'
            'uiextras.Grid'
            'uiextras.GridFlex'
            };
        HBoxes = {
            'uiextras.HBox'
            'uiextras.HBoxFlex'
            };
        VBoxes = {
            'uiextras.VBox'
            'uiextras.VBoxFlex'
            };
        GridType = {
            'uiextras.Grid'
            'uiextras.GridFlex'
            };
        SpecialConstructionArgs = {
            {'uiextras.HBox'}
            {'uiextras.HBoxFlex', 'ShowMarkings', 'on'}
            {'uiextras.VBox'}
            {'uiextras.VBoxFlex', 'ShowMarkings', 'on'}
            {'uiextras.Grid'}
            {'uiextras.GridFlex', 'ShowMarkings','on'}
            };
        GetSetPVArgs  = {
            {'uiextras.HBox', 'Sizes', [-1 -2 100], 'MinimumSizes', [0 1 2]}
            {'uiextras.HBoxFlex', 'Sizes', [-1 -2 100], 'MinimumSizes', [0 1 2], 'ShowMarkings', 'off'}
            {'uiextras.VBox', 'Sizes', [-1 -2 100], 'MinimumSizes', [0 1 2]}
            {'uiextras.VBoxFlex', 'Sizes', [-1 -2 100], 'MinimumSizes', [0 1 2], 'ShowMarkings', 'off'}
            {'uiextras.Grid', 'RowSizes', [-0.5, 50], 'ColumnSizes', [-10, -1, 20], ...
            'MinimumWidths', [1; 1; 1], 'MinimumHeights', 2}
            {'uiextras.GridFlex', 'RowSizes', [-0.5, 50], 'ColumnSizes', [-10, -1, 20], ...
            'MinimumWidths', [1; 1; 1], 'MinimumHeights', 2, 'ShowMarkings', 'off'}
            };
        ResizeTestArgs = {
            {'uiextras.HBox', 'Width'}
            {'uiextras.HBoxFlex', 'Width'}
            {'uiextras.VBox', 'Height'}
            {'uiextras.VBoxFlex', 'Height'}
            };
    end
    
    properties
        DefaultConstructionArgs = {
            'BackgroundColor', [0 0 1], ...
            'Units',           'pixels', ...
            'Position',        [10 10 400 400], ...
            'Padding',         5, ...
            'Spacing',         5, ...
            'Tag',             'test', ...
            'Visible',         'on', ...
            };
    end
    
    methods (Test)
        function testGridContents(testcase, GridType)
            %testContents  Test adding and removing children
            obj = testcase.hCreateObj(GridType);
            u = [
                uicontrol( 'Parent', obj, 'BackgroundColor', 'r' )
                uicontrol( 'Parent', obj, 'BackgroundColor', 'g' )
                uicontrol( 'Parent', obj, 'BackgroundColor', 'b' )
                uicontrol( 'Parent', obj, 'BackgroundColor', 'y' )
                uicontrol( 'Parent', obj, 'BackgroundColor', 'm' )
                uicontrol( 'Parent', obj, 'BackgroundColor', 'c' )
                ];
            testcase.assertEqual( obj.Contents, u );
            
            % Reshape
            set(obj, 'RowSizes', [-1 200], 'ColumnSizes', [-1 100 -1] );
            
            delete( u(5) );
            testcase.verifyEqual(obj.Contents, u([1:4,6]) );
            
            % Reparent a child
            set( u(1), 'Parent', gcf )
            testcase.verifyEqual( obj.Contents, u([2 3 4 6]) );
        end
        
        function testAddingAxesToBox(testcase, ContainerType)
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
        end
        
        function testResizeFigureRetainsElementSizesInHBoxes(testcase, HBoxes)
            % create RGB box and resize the whole figure
            [obj, expectedSizes] = testcase.hCreateAxesAndResizeFigure(HBoxes, 'Width');
            
            actualSizes(1) = obj.Contents(1).Position(3);
            actualSizes(2) = obj.Contents(2).Position(3);
            actualSizes(3) = obj.Contents(3).Position(3);
            
            testcase.verifyEqual(actualSizes, expectedSizes);
        end     
        
        function testResizeFigureRetainsElementSizesInVBoxes(testcase, VBoxes)
            % create RGB box and resize the whole figure
            [obj, expectedSizes] = testcase.hCreateAxesAndResizeFigure(VBoxes, 'Heights');
            
            actualSizes(1) = obj.Contents(1).Position(4);
            actualSizes(2) = obj.Contents(2).Position(4);
            actualSizes(3) = obj.Contents(3).Position(4);
            
            testcase.verifyEqual(actualSizes, expectedSizes);
        end
        
        function testAxesPositionInHBoxes(testcase, HBoxes)
            %testAxesPosition  Test that axes get positioned properly
            [~, ax1, ax2] = testcase.hPositionAxesInBox(HBoxes);
            
            % Check that the axes sizes are correct.
            testcase.verifyEqual( get( ax1, 'OuterPosition' ), [1 1 250 500] );
            testcase.verifyEqual( get( ax2, 'Position' ), [251 1 250 500] );
        end
        
        function testAxesPositionInVBoxes(testcase, VBoxes)
            %testAxesPosition  Test that axes get positioned properly
            [~, ax1, ax2] = testcase.hPositionAxesInBox(VBoxes);
            
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

