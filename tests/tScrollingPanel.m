classdef tScrollingPanel < ContainerSharedTests ...
        & PanelTests
    %TSCROLLINGPANEL unit tests for uix.ScrollingPanel
    
    properties (TestParameter)
        ContainerType   = {'uix.ScrollingPanel'};
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
        
        function testMinimumWidths(testcase, ContainerType)
            
            obj = testcase.hCreateObj(ContainerType, {'Parent', gcf()});
            h = uix.HBoxFlex( 'Parent', obj, 'Padding', 10, 'Spacing', 10 );
            for ii = 1:4
                b(ii) = uicontrol( 'Parent', h, 'String', ii );
            end
            h.MinimumWidths(:) = 100;
            obj.MinimumWidths = 450;
            obj.MinimumHeights = 450;
            set( obj, 'Units', 'pixels', 'Position', [10 10 200 200] );
            
            testcase.verifyEqual( h.Position(3), 450 )
            testcase.verifyEqual( h.Position(4), 450 )
            for ii = 1:4
                testcase.verifyEqual( b(ii).Position(3), 100 )
            end
            
        end
        
        function testMinimumHeights(testcase, ContainerType)
            
            obj = testcase.hCreateObj(ContainerType, {'Parent', gcf()});
            v = uix.VBoxFlex( 'Parent', obj, 'Padding', 10, 'Spacing', 10 );
            for ii = 1:4
                b(ii) = uicontrol( 'Parent', v, 'String', ii );
            end
            v.MinimumHeights(:) = 100;
            obj.MinimumWidths = 450;
            obj.MinimumHeights = 450;
            set( obj, 'Units', 'pixels', 'Position', [10 10 200 200] );
            
            testcase.verifyEqual( v.Position(3), 450 )
            testcase.verifyEqual( v.Position(4), 450 )
            for ii = 1:4
                testcase.verifyEqual( b(ii).Position(4), 100 )
            end
            
        end
        
    end
    
end