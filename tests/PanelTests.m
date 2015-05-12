classdef PanelTests < matlab.unittest.TestCase
%PANELTESTS Extra tests for panels
    
    properties (Abstract, TestParameter)
        ContainerType;
    end    

    methods (Test)
        
        function testLayoutInPanel(testcase, ContainerType)
            %testLayoutInTab  Test layout in panel
            obj = testcase.hCreateObj(ContainerType, {'Parent', gcf()});
            
            b = uiextras.HBox( 'Parent', obj );
            testcase.verifyEqual( obj.Contents, b );
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

