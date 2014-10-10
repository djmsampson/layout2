classdef tExamples <  matlab.unittest.TestCase
    %tExamples  Unit tests for the layout example applications
    
    properties
        oldDir;
    end
    
    methods(TestMethodSetup)
        function changeDirToDemoRoot(testcase)
            testcase.oldDir = pwd();
            cd( testcase.demoroot() );
        end
    end
    
    methods(TestMethodTeardown)
        function closeAllOpenFigures(~)
            close all force;
        end
        function changeDirToOriginalLocation(testcase)
            cd( testcase.oldDir );
        end
    end
    
    methods (Test)
        
        
        function testAxesExample(testcase)
            try                
                axesexample;
            catch e
                errstr = ['the "axesexample" demo threw error ', e.message, ...
                    ' with the identifier: ', e.identifier];
                testcase.verifyFail(errstr);
                e.rethrow()
            end
        end % testaxesexample
        
        function testCallbackExample(testcase)
            try                
                callbackexample;
            catch e
                errstr = ['the "callbackexample" demo threw error ', e.message, ...
                    ' with the identifier: ', e.identifier];
                testcase.verifyFail(errstr);
                e.rethrow()
            end
        end % testcallbackexample
        
        function testDemoBrowser(testcase)
            try                
                demoBrowser;
            catch e
                errstr = ['"demoBrowser" threw error ', e.message, ...
                    ' with the identifier: ', e.identifier];
                testcase.verifyFail(errstr);
                e.rethrow()
            end
        end % testdemoBrowser
        
        function testDockExample(testcase)
            try                
                dockexample;
            catch e
                errstr = ['the "dockexample" demo threw error ', e.message, ...
                    ' with the identifier: ', e.identifier];
                testcase.verifyFail(errstr);
                e.rethrow()
            end
        end % testdockexample
        
        function testEnableExample(testcase)
            try                
                enableexample;          
            catch e
                errstr = ['the "enableexample" demo threw error ', e.message, ...
                    ' with the identifier: ', e.identifier];
                testcase.verifyFail(errstr);
                e.rethrow()
            end
        end % testenableexample
        
        function testGridFlexPositioning(testcase)
            try                
                gridflexpositioning;
            catch e
                errstr = ['the "gridflexpositioning" demo threw error ', e.message, ...
                    ' with the identifier: ', e.identifier];
                testcase.verifyFail(errstr);
                e.rethrow()
            end
        end % testgridflexpositioning
        
        function testHeirarchyExample(testcase)
            try                
                heirarchyexample;
            catch e
                errstr = ['the "hierarchyexample" demo threw error ', e.message, ...
                    ' with the identifier: ', e.identifier];
                testcase.verifyFail(errstr);
                e.rethrow()
            end
        end % testheirarchyexample
        
        function testMinimizeExample(testcase)
            try
                minimizeexample;
            catch e
                errstr = ['the "minimizeexample" demo threw error ', e.message, ...
                    ' with the identifier: ', e.identifier];
                testcase.verifyFail(errstr);
                e.rethrow()
            end
        end % testminimizeexample
        
        function testTabPanelExample(testcase)
            try                
                tabpanelexample;
            catch e
                errstr = ['the "tabpanelexample" demo threw error ', e.message, ...
                    ' with the identifier: ', e.identifier];
                testcase.verifyFail(errstr);
                e.rethrow()
            end
        end % testtabpanelexample
        
        function testVisibleExample(testcase)
            try
                visibleexample;
            catch e
                errstr = ['the "visibleexample" demo threw error ', e.message, ...
                    ' with the identifier: ', e.identifier];
                testcase.verifyFail(errstr);
                e.rethrow()
            end
        end % testvisibleexample
    end
    
    
    methods
        function d = demoroot(~)            
            d = fullfile( fileparts( 'fullpath' ), 'demos' );            
        end % helper function
    end
end