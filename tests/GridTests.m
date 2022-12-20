classdef GridTests < matlab.unittest.TestCase 
    %GRIDTESTS Extra tests for Grid and GridFlex.
    
    properties (Abstract, TestParameter)
        ConstructorName;
    end
    
    methods (Test)
        function testGridContents(testcase, ConstructorName)
            %testContents  Test adding and removing children
            obj = testcase.hCreateObj(ConstructorName);
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
            
            % Reparent a child when not unparented
            if ~strcmp(testcase.parentStr,'[]')
                fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
                set(u(1), 'Parent', fx.FigureHandle)
           
                testcase.verifyEqual(obj.Contents, u([2 3 4 6]));
            end
        end
    end
end

