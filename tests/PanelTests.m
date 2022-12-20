classdef PanelTests < matlab.unittest.TestCase
    %PANELTESTS Extra tests for panels
    
    properties (Abstract, TestParameter)
        ConstructorName
    end
    
    properties (TestParameter)
        failingSelection = {2.4, int32(2), [2 3 4], 5}
    end
    
    properties
        G1218142
    end
    
    methods(TestClassSetup)
        function suppressWarnings(testcase)
            testcase.G1218142 = warning('off','uix:G1218142');
        end
    end
    
    methods(TestClassTeardown)
        function restoreWarnings(testcase)
            warning(testcase.G1218142)
        end
    end

    methods (Test)
        
        function testLayoutInPanel(testcase, ConstructorName)
            %testLayoutInTab  Test layout in panel
            obj = testcase.constructComponent(ConstructorName);
            
            b = uiextras.HBox( 'Parent', obj );
            testcase.verifyEqual( obj.Contents, b );
        end
        
        function testSelectablePanelContents(testcase, ConstructorName)
            %testChildren  Test adding and removing children
            [obj, actualContents] = testcase.hBuildRGBBox(ConstructorName);
            testcase.assertEqual( obj.Contents, actualContents );
            
            obj.Selection = 2;
            
            % if the panel is unparented all children are automatically
            % visible, but on reparenting we need to make sure the
            % visibility is correctly set. So reparent obj at this point.
            % Make a copy of the obj to test with both figure and uifigure
            
            if strcmp(testcase.ParentType, 'unrooted')
                fxFig = testcase.applyFixture(FigureFixture('figure'));
                obj.Parent = fxFig.FigureHandle;
            end
            
            % Make sure the "selected" child is visible
            testcase.verifyEqual(char(obj.Contents(2).Visible), 'on');
            % Make sure the "hidden" children are invisible
            testcase.verifyEqual(char(obj.Contents(1).Visible), 'off');
            testcase.verifyEqual(char(obj.Contents(3).Visible), 'off');
            
        end
        
        function testSelectableEmptyPanelSetSelectionErrors(testcase, ConstructorName, failingSelection)
            objEmpty = testcase.constructComponent(ConstructorName);
            
            testcase.verifyError(@()set(objEmpty, 'Selection', failingSelection), 'uix:InvalidPropertyValue');
        end
        
        function testSelectableRGBPanelSetSelectionErrors(testcase, ConstructorName, failingSelection)
            [obj4Children, ~] = testcase.hBuildRGBBox(ConstructorName);
            
            testcase.verifyError(@()set(obj4Children, 'Selection', failingSelection), 'uix:InvalidPropertyValue');
        end
        
        function testSelectablePanelSetSelectionSucceeds(testcase, ConstructorName)
            objEmpty = testcase.constructComponent(ConstructorName);
            [obj4Children, ~] = testcase.hBuildRGBBox(ConstructorName);
            set(objEmpty, 'Selection', 0);
            set(obj4Children, 'Selection', 2);
            
            testcase.verifyEqual(get(objEmpty, 'Selection'), 0);
            testcase.verifyEqual(get(obj4Children, 'Selection'), 2);
        end
        
        function testAddInvisibleUicontrolToPanel(testcase, ConstructorName)
            % test for g1129721 where adding an invisible uicontrol to a
            % panel causes a segv.
            obj = testcase.constructComponent(ConstructorName);
            f = ancestor(obj, 'figure');
            % b1 = uicontrol('Parent', f, 'Visible', 'off');
            b1 = uicontainer('Parent', f, 'Visible', 'off');
            b1.Parent = obj; % used to crash
            testcase.verifyLength(obj.Contents, 1)
            b2 = uicontrol('Parent', f, 'Internal', true, 'Visible', 'off');
            b2.Parent = obj; % used to crash
            testcase.verifyLength(obj.Contents, 1)
            b2.Internal = false;
            testcase.verifyLength(obj.Contents, 2)
        end
        
    end
    
end