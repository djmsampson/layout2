function plan = buildfile()
%BUILDFILE Build file for managing GUI Layout Toolbox packaging tasks.

% Initialize the build plan from the local task functions below.
plan = buildplan( localfunctions() );
projectRoot = plan.RootFolder;

% Set the project root as the folder in which to check for any static code
% issues.
sourceFiles = projectRoot;
plan("assertNoCodeIssues") = matlab.buildtool.tasks...
    .CodeIssuesTask( sourceFiles, ...
    "IncludeSubfolders", true, ...
    "Description", ...
    "Assert that there are no code issues in the project.", ...
    "WarningThreshold", 0 );

% Add a test task to run the unit tests for the project. Generate and save
% a coverage report.
testFolder = fullfile( projectRoot, "tests" );
codeFolder = fullfile( projectRoot, "tbx", "layout"  );
plan("assertTestSuccess") = matlab.buildtool.tasks.TestTask( ...
    testFolder, "Strict", true, ...
    "Description", "Assert that all tests across the project pass.", ...
    "SourceFiles", codeFolder, ...
    "CodeCoverageResults", "reports/Coverage.html", ...
    "OutputDetail", "none" );

% Set all the tasks to run by default.
plan.DefaultTasks = "packageToolbox";

% Define the task dependencies.
plan("deletePreviousDocFiles").Dependencies = "checkDocerInstallation";
plan("convertMarkdownToHTML").Dependencies = "deletePreviousDocFiles";
plan("runDocExamples").Dependencies = "convertMarkdownToHTML";
plan("createDocIndex").Dependencies = "runDocExamples";
plan("packageToolbox").Dependencies = "createDocIndex";

end % buildfile

function checkDocerInstallationTask( ~ )
% Check that the Doc_er toolbox is installed.

v = ver( "docer" );
assert( ~isempty( v ), "buildfile:NoDocer", ...
    "Building GUI Layout Toolbox documentation requires Doc_er." )

end % checkDocerInstallationTask

function deletePreviousDocFilesTask( context )
% Use Doc_er to delete any previous documentation files.

end % deletePreviousDocFilesTask

function convertMarkdownToHTMLTask( context )
% Use Doc_er to convert the markdown (.md) files to HTML.


end % convertMarkdownToHTMLTask

function runDocExamplesTask( context )
% Use Doc_er to evaluate and capture the code within the doc pages.


end % runDocExamplesTask

function createDocIndexTask( context )
% Use Doc_er to create the documentation index files and search database.



end % createDocIndexTask

function packageToolboxTask( context )
% Package the GUI Layout Toolbox.

% Write down the toolbox root directory and ID.
projectRoot = context.Plan.RootFolder;
toolboxRoot = fullfile( projectRoot, "tbx" );
toolboxID = "e5af5a78-4a80-11e4-9553-005056977bd0";

% Create the toolbox packaging options.
opts = matlab.addons.toolbox.ToolboxOptions( toolboxRoot, toolboxID );

% Fill in the options.
opts.AuthorCompany = "MathWorks";
opts.AuthorEmail = "dsampson@mathworks.com";
opts.AuthorName = "David Sampson";
opts.Description = "This toolbox provides tools to create " + ...
    "sophisticated MATLAB graphical user interfaces that resize " + ...
    "gracefully.  The classes supplied can be used in combination" + ...
    " to produce virtually any user interface layout." + newline() + ...
    newline() + ...
    "* Arrange MATLAB user interface components horizontally, " + ...
    "vertically or in grids" + newline() + ...
    "* Mix fixed- and variable-size components" + newline() + ...
    "* Resize components interactively by dragging dividers" + ...
    newline() + ...
    "* Show and hide components using tabs and panels" + newline() + ...
    "* Show part of a large component in a scrollable panel" + ...
    newline() + newline() + ...
    "This toolbox was developed by David Sampson and Ben Tordoff " + ...
    "from the [Consulting Services]" + ...
    "(http://www.mathworks.com/services/consulting/) group at " + ...
    "MathWorks." + newline() + newline() + ...
    "This version is for MATLAB R2014b and later. For R2014a and " + ...
    "earlier, see [version 1](http://www.mathworks.com/" + ...
    "matlabcentral/fileexchange/27758-gui-layout-toolbox).";

% Read the version number from Contents.m.
contentsFile = fullfile( toolboxRoot, "layout", "Contents.m" );
contentsFileText = fileread( contentsFile );
versionNumber = string( extractBetween( ...
    contentsFileText, "Version ", " (" ) );
mltbxName = "GUI Layout Toolbox " + versionNumber + ".mltbx";

% Place the .mltbx file in the releases folder.
opts.OutputFile = fullfile( projectRoot, "releases", mltbxName );

% Continue filling in the options.
opts.Summary = "Layout manager for MATLAB graphical user interfaces";
opts.SupportedPlatforms = struct( "Win64", true, ...
    "Glnxa64", true, ...
    "Maci64", true, ...
    "MatlabOnline", true );
opts.ToolboxGettingStartedGuide = ""; %TODO
opts.ToolboxImageFile = fullfile( projectRoot, "glt.png" );
opts.ToolboxName = "GUI Layout Toolbox";
opts.ToolboxVersion = versionNumber;
opts.MinimumMatlabRelease = "R2014b";
opts.MaximumMatlabRelease = ""; % Current version

% Package the toolbox.
matlab.addons.toolbox.packageToolbox( opts )
disp( mltbxName + " has been placed in the releases folder." )

end % packageToolboxTask