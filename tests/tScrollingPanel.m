classdef tScrollingPanel < ContainerSharedTests ...
        & PanelTests
    %TSCROLLINGPANEL unit tests for uix.ScrollingPanel
    
    properties (TestParameter)
        ContainerType   = {'uix.Viewport'};
        GetSetArgs = {
            {'BackgroundColor', [1 1 0] ...
            }};
        ConstructorArgs = {
            {'Units',            'pixels', ...
            'Position',         [10 10 400 400], ...
            'Tag',              'Test', ...
            'Visible',          'on'
            }};
    end
    
    methods (Test)
        
        function testFillingPosition(testcase, ContainerType)
            %testLayoutInTab  Test layout in panel
            obj = testcase.hCreateObj(ContainerType, [{'Parent', gcf()} testcase.ConstructorArgs{:}]);
            c = uicontrol( 'Parent', obj );
            testcase.verifyEqual( c.Position, [1 1 obj.Position(3:4)] )
            p = obj.Position;
            for ii = 1:8
                o = 50 * [sin( pi*ii/8 ) cos( pi*ii/8 )];
                obj.Position = p + [0 0 o];
                drawnow()
                testcase.verifyEqual( c.Position, [1 1 obj.Position(3:4)], 'AbsTol', 1e-10 )
            end
        end
        
        function testHorizontalPosition(testcase, ContainerType)
            
            obj = testcase.hCreateObj(ContainerType, {'Parent', gcf()});
            set( obj, 'Units', 'pixels', 'Position', [10 10 400 400] );
            c = uicontrol( 'Parent', obj );
            obj.Widths = 600;
            obj.Heights = 500;
            testcase.verifyEqual( c.Position, [1 -99 600 500] )
            obj.Position(3) = 420;
            testcase.verifyEqual( c.Position, [1 -99 600 500] )
            obj.Position(3) = 380;
            testcase.verifyEqual( c.Position, [1 -99 600 500] )
            obj.Position(3) = 400;
            testcase.verifyEqual( c.Position, [1 -99 600 500] )
            obj.HorizontalOffsets = 50;
            testcase.verifyEqual( c.Position, [-49 -99 600 500] )
            obj.Position(3) = 420;
            testcase.verifyEqual( c.Position, [-49 -99 600 500] )
            obj.Position(3) = 380;
            testcase.verifyEqual( c.Position, [-49 -99 600 500] )
            obj.Position(3) = 400;
            testcase.verifyEqual( c.Position, [-49 -99 600 500] )
            obj.Position(3) = 490;
            
        end
        
    end
    
end