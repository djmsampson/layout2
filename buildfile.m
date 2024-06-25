function plan = buildfile()
%BUILDFILE Build file for the GUI Layout Toolbox.

% Initialize the build plan from the local task functions below.
plan = buildplan( localfunctions() );

% Set the project root as the folder in which to check for any static code
% issues.
% projectRoot = plan.RootFolder;
% sourceFiles = projectRoot;
% plan("assertNoCodeIssues") = matlab.buildtool.tasks...
%     .CodeIssuesTask( sourceFiles, ...
%     "IncludeSubfolders", true, ...
%     "Description", ...
%     "Assert that there are no code issues in the project.", ...
%     "WarningThreshold", 0 );

% % Add a test task to run the unit tests for the project. Generate and save
% % a coverage report.
% testFolder = fullfile( projectRoot, "tests" );
% codeFolder = fullfile( projectRoot, "tbx", "layout"  );
% plan("assertTestSuccess") = matlab.buildtool.tasks.TestTask( ...
%     testFolder, "Strict", true, ...
%     "Description", "Assert that all tests across the project pass.", ...
%     "SourceFiles", codeFolder, ...
%     "CodeCoverageResults", "reports/Coverage.html", ...
%     "OutputDetail", "none" );

% Set all the tasks to run by default.
plan.DefaultTasks = [plan.Tasks.Name];

% Define the task dependencies.
%plan("generateHTMLDocumentation").Dependencies = "assertNoCodeIssues";
plan("buildDocSearchDatabase").Dependencies = "generateHTMLDocumentation";
plan("packageToolbox").Dependencies = "buildDocSearchDatabase";

end % buildfile

function generateHTMLDocumentationTask( context )
% Generate HTML documentation from the Live Script files.

% List the Live Scripts comprising the documentation.
projectRoot = context.Plan.RootFolder;
liveDocFiles = dir( fullfile( projectRoot, "livedocsrc", "*.mlx" ) );
liveDocFiles = struct2table( liveDocFiles );
liveDocFiles = convertvars( liveDocFiles, ["folder", "name"], "string" );

% Listen for figure creation.
childListener = listener( groot(), "ChildAdded", @onFigureCreated );
listenerCleanup = onCleanup( @() delete( childListener ) );
figuresToDelete = gobjects( 0, 1 );

for k = 1 : height( liveDocFiles )

    % Run and export the current Live Script.
    currentFile = fullfile( liveDocFiles.folder(k), liveDocFiles.name(k) );
    [~, liveDocName] = fileparts( liveDocFiles.name(k) );
    targetFile = fullfile( projectRoot, "tbx", "layoutlivedoc", ...
        liveDocName + ".html" );
    export( currentFile, targetFile, "Format", "html", "Run", true );

    % Tidy up.
    delete( figuresToDelete )
    figuresToDelete = gobjects( 0, 1 );

end % for

    function onFigureCreated( ~, e )

        figuresToDelete(end+1, 1) = e.Child;

    end % onFigureCreated

end % generateHTMLDocumentationTask

function buildDocSearchDatabaseTask( ~ )
% Build the documentation search database.

builddocsearchdb( layoutDocRoot() )

end % buildDocSearchDatabaseTask

function packageToolboxTask( context )
% Package the GUI Layout Toolbox.

% toolboxRoot = fullfile( context.Plan.RootFolder );
% id = "299d2567-58cd-4d3d-801c-a14cb7760684";
% opts = matlab.addons.toolbox.ToolboxOptions( toolboxRoot, id );
% opts.OutputFile = "MyToolbox.mltbx";
% opts.ToolboxName = "MyToolbox";
% matlab.addons.toolbox.packageToolbox( opts )

end % packageToolboxTask