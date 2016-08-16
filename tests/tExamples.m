classdef tExamples <  matlab.unittest.TestCase
    %tExamples  Unit tests for the layout example applications
    
    methods(TestMethodSetup)
        function addInitialTestPaths(testcase)
            import matlab.unittest.fixtures.PathFixture;
            
             addFolder1 = fullfile('..', 'tbx', 'layout');
             addFolder2 = fullfile('..', 'docsrc');
             
             testcase.applyFixture(PathFixture(addFolder1));
             testcase.applyFixture(PathFixture(addFolder2));
             
             addFolder3 = testcase.demoroot();
             
             testcase.applyFixture(PathFixture(addFolder3));
        end
    end
    
    methods(TestMethodTeardown)
        function closeAllOpenFigures(~)
            close all force;
        end
    end
    
    methods(TestClassTeardown)
        function cleanWorkspace(testcase)
            evalin('base','clear all');
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
        
        function testHierarchyExample(testcase)
            try
                hierarchyexample;
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
                paneltabexample;
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
            d = fullfile( layoutDocRoot(), 'Examples' );
        end % helper function
    end
end