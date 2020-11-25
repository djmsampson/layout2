classdef tExamples <  matlab.unittest.TestCase
    %tExamples  Unit tests for the layout example applications
    
    properties(TestParameter)
        ExampleScript = {'axesexample',...
                         'callbackexample',...
                         'demoBrowser',...
                         'dockexample',...
                         'gridflexpositioning',...
                         'hierarchyexample',...
                         'minimizeexample',...
                         'paneltabexample',...
                         'visibleexample'};
    end
    
    methods(TestMethodSetup)
        function addInitialTestPaths(testcase)
            import matlab.unittest.fixtures.PathFixture;
            thisFolder = fileparts( fileparts( mfilename( 'fullpath' ) ) );
            % Add examples and toolbox to path
            testcase.applyFixture( PathFixture( fullfile( thisFolder, 'docsrc' ) ) );
            testcase.applyFixture( PathFixture( fullfile( thisFolder, 'docsrc', 'Examples' ) ) );
            testcase.applyFixture( PathFixture( fullfile( thisFolder, 'tbx', 'layout' ) ) );
        end
    end
    
    properties
        InitBaseVars % Keep track of vars in base workspace
    end
    
    methods(TestMethodSetup)
        function workspaceVars(testcase)
            % Example scripts create figures and variables
            % in the base workspace which are hard to catch
            % Take a snapshot of the current state of the base workspace
            testcase.InitBaseVars = evalin('base','whos');
        end
    end
    
    methods(TestMethodTeardown)
         function closeFig(~)
           % Find any figures and close them
            fig = findall(groot, 'Type', 'figure');
            for f = 1:numel(fig)
               close(fig(f)); 
            end 
         end
         function cleanWorkspace(testcase)
            % Clear any newly created variables
            newVars = evalin('base','whos');
            newVarsNames = {newVars.name};
            
            % Remove any variables which were in 
            % the workspace at the start of the test
            varsToRemove = setdiff(newVarsNames,{testcase.InitBaseVars.name});
            
            for v = 1:numel(varsToRemove)
               evalin('base',['clear ' varsToRemove{v}]); 
            end
         end
    end
    
    methods (Test)
        
        function testExample(testcase,ExampleScript)
            testcase.verifyWarningFree(@()evalin('base',ExampleScript),...
                sprintf('Running the %s demo in base workspace failed',ExampleScript));
        end % testExample

    end
    
    
    methods
        function d = demoroot(~)
            d = fullfile( layoutDocRoot(), 'Examples' );
        end % helper function
    end
end