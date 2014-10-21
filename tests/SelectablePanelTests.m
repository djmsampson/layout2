classdef SelectablePanelTests < matlab.unittest.TestCase
    %SelectablePanelTests Tests for the "Selection" property of selectable Panels.
    
    properties (TestParameter, Abstract)
        ContainerType;
    end
    
    methods (Test)
        function testSelectablePanelContents(testcase, ContainerType)
            %testChildren  Test adding and removing children
            [obj, actualContents] = testcase.hBuildRGBBox(ContainerType);
            testcase.assertEqual( obj.Contents, actualContents );
            
            obj.Selection = 2;            
            % Make sure the "selected" child is visible
            testcase.verifyEqual(obj.Contents(2).Visible, 'on' );            
            % Make sure the "hidden" children are invisible
            testcase.verifyEqual(obj.Contents(1).Visible, 'off' );
            testcase.verifyEqual(obj.Contents(3).Visible, 'off' );
        end
        
        function testSelectablePanelGetSetSelection(testcase, ContainerType)
            objEmpty = testcase.hCreateObj(ContainerType);
            [obj3Children, ~] = testcase.hBuildRGBBox(ContainerType);
            prop = 'Selection';
            failSelectValues{1} = 2.4;
            failSelectValues{2} = int32(2);
            failSelectValues{3} = [2 3 4];
            
            for val = failSelectValues
                testcase.verifyError(@()set(objEmpty, prop, val), 'uix:InvalidPropertyValue');
                testcase.verifyError(@()set(obj3Children, prop, val), 'uix:InvalidPropertyValue');
            end
            set(objEmpty, prop, 0);
            testcase.verifyEqual(get(objEmpty, prop), 0);
            testcase.verifyError(@()set(objEmpty, prop, 3), 'uix:InvalidPropertyValue');
            
            set(obj3Children, prop, 3);
            testcase.verifyEqual(get(obj3Children, prop), 3);
        end

    end
    
end

