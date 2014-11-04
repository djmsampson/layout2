classdef SelectablePanelTests < matlab.unittest.TestCase
    %SelectablePanelTests Tests for the "Selection" property of selectable Panels.
    
    properties (TestParameter, Abstract)
        ContainerType;
    end
    
    properties (TestParameter)
        failingSelection = {2.4, int32(2), [2 3 4], 4};
    end
    
    
    methods (Test)
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
            [obj3Children, ~] = testcase.hBuildRGBBox(ContainerType);

            testcase.verifyError(@()set(obj3Children, 'Selection', failingSelection), 'uix:InvalidPropertyValue');
        end
        
        function testSelectablePanelSetSelectionSucceeds(testcase, ContainerType)
            objEmpty = testcase.hCreateObj(ContainerType);
            [obj3Children, ~] = testcase.hBuildRGBBox(ContainerType);
            set(objEmpty, 'Selection', 0);
            set(obj3Children, 'Selection', 2);
            
            testcase.verifyEqual(get(objEmpty, 'Selection'), 0);
            testcase.verifyEqual(get(obj3Children, 'Selection'), 2);
        end

    end
    
end

