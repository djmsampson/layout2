% automatically runs all MATLABUnit tests in this folder
% import matlab.unittest.TestSuite
% import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

% add Layouts2/code/layout to path
addpath( layoutRoot() );

% build test suite and test runner
ts = matlab.unittest.TestSuite.fromFolder(pwd);
runner = matlab.unittest.TestRunner.withNoPlugins; %withTextOutput

% Tell the test runner to report code coverage for the code/layout folder
runner.addPlugin(CodeCoveragePlugin.forFolder(fullfile(layoutRoot, '+uiextras')));
runner.addPlugin(CodeCoveragePlugin.forFolder(fullfile(layoutRoot, '+uix')));

results             = runner.run(ts);
resultsTable        = table(results);
failedResultsTable  = resultsTable(~resultsTable.Passed,:);

numTests            = size(resultsTable, 1);
numFails            = size(failedResultsTable, 1);

% disp(sprintf('%d tests passed out of %d\n', numTests-numFails, numTests));
% disp(sprintf('Of %d tests, %d failed.\n', numTests, numFails));
% if numFails > 0
%     disp('Tests that didn''t pass:')
%     disp(failedResultsTable);
% end