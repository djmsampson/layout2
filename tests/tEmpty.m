classdef tEmpty < matlab.unittest.TestCase
    %testEmpty  Unit tests for uiextras.Empty.
    % Empty is not a container so does not inherit ContainerSharedTests
    
    methods(TestClassSetup)
        function setupPath(testcase)
            import matlab.unittest.fixtures.PathFixture
            testsFolder = fileparts( mfilename( 'fullpath' ) );
            projectFolder = fileparts( testsFolder );
            toolboxFolder = fullfile( projectFolder, 'tbx', 'layout' );
            testcase.applyFixture( PathFixture( toolboxFolder ) )
        end
    end
    
    properties
        figFx
    end
    
    methods(TestMethodSetup)
        function figFixture(testcase)
            testcase.figFx = testcase.applyFixture(FigureFixture('figure'));
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
            h = uiextras.HBox( 'Parent', testcase.figFx.FigureHandle, 'Units', 'pixels', 'Position', [1 1 500 500] );
            testcase.assertEqual( isa( h, 'uiextras.HBox' ), true );
            
            e = uiextras.Empty( 'Parent', h );
            uicontrol( 'Parent', h, 'BackgroundColor', 'b' )
            
            testcase.verifyEqual( e.Position, [1 1 250 500] );
        end
        
        function testInitialColor(testcase)
            %testColor  Test background color
            c = rand( [1 3] ); % random color
            h = uiextras.HBox( 'Parent', testcase.figFx.FigureHandle, 'BackgroundColor', c );
            
            uicontrol( 'Parent', h );
            e = uiextras.Empty( 'Parent', h );
            uicontrol( 'Parent', h );
            
            testcase.verifyEqual( e.BackgroundColor, c );
        end
        
        function testParentColorChanged(testcase)
            %testParentColorChanged  Test color when Parent color changes
            h = uiextras.HBox( 'Parent', testcase.figFx.FigureHandle);
            uicontrol( 'Parent', h );
            e = uiextras.Empty( 'Parent', h );
            uicontrol( 'Parent', h );
            
            c = rand( [1 3] ); % random color
            h.BackgroundColor = c;
            
            testcase.verifyEqual( e.BackgroundColor, c );
        end
        
        function testColorOnReparent(testcase)
            %testColor  Test color when reparenting
            c = rand( [1 3] ); % random color
            h = uiextras.HBox( 'Parent', testcase.figFx.FigureHandle, 'BackgroundColor', c );
            uicontrol( 'Parent', h );
            
            e = uiextras.Empty(); % unparented
            e.Parent = h; % parent
            
            testcase.verifyEqual( e.BackgroundColor, c );
        end
    end
end