function errorLevel = testsandbox()
    
    %  Copyright 2020 The MathWorks, Inc.
    
    import matlab.unittest.*
    import matlab.unittest.plugins.*
    
    % Create test results XML report per MATLAB release
    releaseString = ver('MATLAB').Release;
    % Remove parentheses
    releaseString = replace(replace(releaseString,'(',''),')','');
    resultsFile = "testResults" + releaseString + ".xml";
    
    
    try
        openProject(pwd)
        suite = TestSuite.fromFolder("tests", 'IncludingSubfolders', true);
        runner = TestRunner.withTextOutput;
        runner.addPlugin(XMLPlugin.producingJUnitFormat(resultsFile))
        runner.run(suite);
        errorLevel = 0;
    catch ex
        ex.getReport
        errorLevel = 1;
    end
    
end