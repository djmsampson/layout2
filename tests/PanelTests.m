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

    end
    
end

