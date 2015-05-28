classdef PanelTests < matlab.unittest.TestCase
    %PANELTESTS Extra tests for panels
    
    properties (Abstract, TestParameter)
        ContainerType;
    end
    
    properties (TestParameter)
        failingSelection = {2.4, int32(2), [2 3 4], 5};
    end
    
    methods (Test)
        
        function testLayoutInPanel(testcase, ContainerType)
            %testLayoutInTab  Test layout in panel
            obj = testcase.hCreateObj(ContainerType, {'Parent', gcf()});
            
            b = uiextras.HBox( 'Parent', obj );
            testcase.verifyEqual( obj.Contents, b );
        end
        
        function testSelectablePanelContents(testcase, ContainerType)
            %testChildren  Test adding and removing children
            [obj, actualContents] = testcase.hBuildRGBBox(ContainerType);
            testcase.assertEqual( obj.Contents, actualContents );
            
            obj.Selection = 2;
            
            % if the panel is unparented all children are automatically
            % visible, but on reparenting we need to make sure the
            % visibility is correctly set. So reparent obj at this point.
            if ~testcase.isParented
                obj.Parent = figure;
            end
            
            % Make sure the "selected" child is visible
            testcase.verifyEqual(obj.Contents(2).Visible, 'on' );
            % Make sure the "hidden" children are invisible
            testcase.verifyEqual(obj.Contents(1).Visible, 'off' );
            testcase.verifyEqual(obj.Contents(3).Visible, 'off' );
        end
        
        function testSelectableEmptyPanelSetSelectionErrors(testcase, ContainerType, failingSelection)
            objEmpty = testcase.hCreateObj(ContainerType);
            
            testcase.verifyError(@()set(objEmpty, 'Selection', failingSelection), 'uix:InvalidPropertyValue');
        end
        
        function testSelectableRGBPanelSetSelectionErrors(testcase, ContainerType, failingSelection)
            [obj4Children, ~] = testcase.hBuildRGBBox(ContainerType);
            
            testcase.verifyError(@()set(obj4Children, 'Selection', failingSelection), 'uix:InvalidPropertyValue');
        end
        
        function testSelectablePanelSetSelectionSucceeds(testcase, ContainerType)
            objEmpty = testcase.hCreateObj(ContainerType);
            [obj4Children, ~] = testcase.hBuildRGBBox(ContainerType);
            set(objEmpty, 'Selection', 0);
            set(obj4Children, 'Selection', 2);
            
            testcase.verifyEqual(get(objEmpty, 'Selection'), 0);
            testcase.verifyEqual(get(obj4Children, 'Selection'), 2);
        end
        
        function testAddInvisibleUicontrolToPanel(testcase, ContainerType)
            % test for g1129721 where adding an invisible uicontrol to a
            % panel causes a segv.
            obj = testcase.hCreateObj(ContainerType);
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