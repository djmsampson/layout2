classdef tEmpty < matlab.unittest.TestCase
    %testEmpty  Unit tests for uiextras.Empty.
    % Empty is not a container so does not inherit ContainerSharedTests
    
    methods(TestMethodTeardown)
        function closeAllOpenFigures(~)
            close all force;
        end
    end
    
    methods (Test)  
        function testDefaultConstructor(testcase)
            %testDefaultConstructor  Test constructing the widget with no arguments
            testcase.verifyClass(uiextras.Empty(), 'matlab.ui.container.internal.UIContainer');
        end
        
        function testConstructionArguments(testcase)
            %testConstructionArguments  Test constructing the widget with optional arguments
            args = {
                'Parent',   gcf()
                'Tag',     'Test'
                }';
            
            obj = uiextras.Empty( args{:} );
            testcase.verifyClass(obj, 'matlab.ui.container.internal.UIContainer');
            testcase.verifySameHandle(obj.Parent, gcf);
            testcase.verifyEqual(obj.Tag, 'Test');
        end
        
        function testPositioning(testcase)
            %testChildren  Test adding and removing children
            h = uiextras.HBox( 'Parent', figure, 'Units', 'Pixels', 'Position', [1 1 500 500] );
            testcase.assertEqual( isa( h, 'uiextras.HBox' ), true );
            
            e = uiextras.Empty( 'Parent', h );
            uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
            
            testcase.verifyEqual( e.Position, [1 1 250 500] );
        end
    end
end


