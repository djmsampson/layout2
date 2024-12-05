function plan = buildfile()
%BUILDFILE Build file for managing GUI Layout Toolbox packaging tasks.

% Copyright 2024 The MathWorks, Inc.

% Define the build plan.
plan = buildplan( localfunctions() );

% Add a test task to run the unit tests for the project. Generate and save
% a coverage report. This build task is optional.
projectRoot = plan.RootFolder;
testFolder = fullfile( projectRoot, "tests" );
codeFolder = fullfile( projectRoot, "tbx", "layout"  );
plan("test") = matlab.buildtool.tasks.TestTask( testFolder, ...
    "Strict", true, ...
    "Description", "Assert that all tests across the project pass.", ...
    "SourceFiles", codeFolder, ...
    "CodeCoverageResults", "reports/Coverage.html", ...
    "OutputDetail", "none" );

% Set the package toolbox task to run by default.
plan.DefaultTasks = "package";

% Define the task dependencies and inputs.
plan("doc").Dependencies = "check";
plan("doc").Inputs = fullfile( projectRoot, "tbx", "layoutdoc" );
plan("package").Dependencies = "doc";

end % buildfile

function checkTask( context )
% Check the source code and project for any issues.

% Set the project root as the folder in which to check for any static code
% issues.
projectRoot = context.Plan.RootFolder;
codeIssuesTask = matlab.buildtool.tasks.CodeIssuesTask( projectRoot, ...
     "IncludeSubfolders", true, ...
     "Configuration", "factory", ...
     "Description", ...
     "Assert that there are no code issues in the project.", ...
     "WarningThreshold", 0 );
codeIssuesTask.analyze( context )

% Update the project dependencies.
prj = currentProject();
prj.updateDependencies()

% Run the checks.
checkResults = table( prj.runChecks() );

% Log any failed checks.
passed = checkResults.Passed;
notPassed = ~passed;
if any( notPassed )
    disp( checkResults(notPassed, :) )
else
    fprintf( "** All project checks passed.\n\n" )    
end % if

% Check that all checks have passed.
assert( all( passed ), "buildfile:ProjectIssue", ...
    "At least one project check has failed. " + ...
    "Resolve the failures shown above to continue." )

end % checkTask

function docTask( context )
% Generate the GUI Layout Toolbox documentation.

% Check that Doc_er is installed.
v = ver( "docer" );
assert( ~isempty( v ), "buildfile:NoDocer", ...
    "Building GUI Layout Toolbox documentation requires Doc_er." )
fprintf( "** Using " + v.Name + " version " + v.Version + " " + ...
    v.Release + ", " + v.Date + ", for this build.\n\n" )

% Delete the old documentation files.
docFolder = context.Task.Inputs.Path;
docerdelete( docFolder )
fprintf( "** Deleted the old documentation files.\n\n" )

% Use Doc_er to convert the markdown (.md) files to HTML.
allMDFiles = fullfile( docFolder, "**", "*.md" );
docerconvert( allMDFiles )
fprintf( "** Converted markdown files to HTML.\n\n" )

% Use Doc_er to evaluate and capture the code within the doc pages.
allHTMLFiles = fullfile( docFolder, "**", "*.html" );
docerrun( allHTMLFiles )
fprintf( "** Evaluated and captured documentation example code.\n\n" )

% Use Doc_er to create the documentation index files and search database.
docerindex( docFolder )
fprintf( "** Created the index and search database files.\n\n" )

end % docTask

function packageTask( context )
% Package the GUI Layout Toolbox.

% Toolbox short name.
toolboxShortName = "layout";

% Project root directory.
projectRoot = context.Plan.RootFolder;

% Import and tweak the toolbox metadata.
toolboxJSON = fullfile( projectRoot, toolboxShortName + ".json" );
meta = jsondecode( fileread( toolboxJSON ) );
meta.ToolboxMatlabPath = fullfile( projectRoot, meta.ToolboxMatlabPath );
meta.ToolboxFolder = fullfile( projectRoot, meta.ToolboxFolder );
meta.ToolboxImageFile = fullfile( projectRoot, meta.ToolboxImageFile );
versionString = feval( @(s) s(1).Version, ver( toolboxShortName ) ); %#ok<FVAL>
meta.ToolboxVersion = versionString;
toolboxMLTBX = meta.ToolboxName + " " + versionString + ".mltbx";
% toolboxMLTBX = fullfile( projectRoot, "releases", ...
%     meta.ToolboxName + " " + versionString + ".mltbx" );
meta.OutputFile = toolboxMLTBX; 

% Define the toolbox packaging options.
toolboxFolder = meta.ToolboxFolder;
toolboxID = meta.Identifier;
meta = rmfield( meta, ["Identifier", "ToolboxFolder"] );
opts = matlab.addons.toolbox.ToolboxOptions( ...
    toolboxFolder, toolboxID, meta );

% Remove the markdown (.md) files.
markdownFilesIdx = endsWith( opts.ToolboxFiles, ".md" );
opts.ToolboxFiles(markdownFilesIdx) = [];

% Package the toolbox.
matlab.addons.toolbox.packageToolbox( opts )
fprintf( 1, "[+] %s\n", opts.OutputFile )

end % packageTask