function plan = buildfile()
%buildfile  GUI Layout Toolbox buildfile

%  Copyright 2024 The MathWorks, Inc.

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

function checkTask( c )
% Identify code and project issues

% Check code
t = matlab.buildtool.tasks.CodeIssuesTask( c.Plan.RootFolder, ...
    "Configuration", "factory", ...
    "IncludeSubfolders", true, ...
    "WarningThreshold", 0 );
t.analyze( c )
fprintf( 1, "** Code checks passed\n" )

% Check project
p = currentProject();
p.updateDependencies()
t = table( p.runChecks() );
ok = t.Passed;
if any( ~ok )
    disp( t(~ok,:) )
    error( "build:Project", "Project check(s) failed." )
else
    fprintf( 1, "** Project checks passed\n" )
end

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

% Control the default figure size and window style for generating doc
% snapshots.
gr = groot();
style = get( gr, "defaultFigureWindowStyle" );
position = get( gr, "defaultFigurePosition" );
rootCleanup = onCleanup( @() set( gr, ...
    "defaultFigureWindowStyle", style, ...
    "defaultFigurePosition", position ) );
set( gr, "defaultFigureWindowStyle", "normal", ...
    "defaultFigurePosition", [100, 100, 400, 300] )

% Use Doc_er to evaluate and capture the code within the doc pages.
allHTMLFiles = fullfile( docFolder, "**", "*.html" );
docerrun( allHTMLFiles )
fprintf( "** Evaluated and captured documentation example code.\n\n" )

% Use Doc_er to create the documentation index files and search database.
docerindex( docFolder )
fprintf( "** Created the index and search database files.\n\n" )

end % docTask

function packageTask( c )
% Package the GUI Layout Toolbox.

% Toolbox short name
n = "layout";

% Environment
d = c.Plan.RootFolder;

% Load and tweak metadata
s = jsondecode( fileread( fullfile( d, n + ".json" ) ) );
s.ToolboxMatlabPath = fullfile( d, s.ToolboxMatlabPath );
s.ToolboxFolder = fullfile( d, s.ToolboxFolder );
s.ToolboxImageFile = fullfile( d, s.ToolboxImageFile );
v = feval( @(s) s(1).Version, ver( n ) ); %#ok<FVAL>
s.ToolboxVersion = v;
s.OutputFile = fullfile( d, "releases", s.ToolboxName + " " + v + ".mltbx" );

% Create options object
f = s.ToolboxFolder;
id = s.Identifier;
s = rmfield( s, ["Identifier", "ToolboxFolder"] ); % mandatory
pv = [fieldnames( s ), struct2cell( s )]'; % optional
o = matlab.addons.toolbox.ToolboxOptions( f, id, pv{:} );
o.ToolboxVersion = string( o.ToolboxVersion ); % g3079185

% Remove documentation source
tf = endsWith( o.ToolboxFiles, ".md" );
o.ToolboxFiles(tf) = [];

% Package
matlab.addons.toolbox.packageToolbox( o )
fprintf( 1, "[+] %s\n", o.OutputFile )

% Add license
lic = fileread( fullfile( d, "LICENSE" ) );
mlAddonSetLicense( char( o.OutputFile ), struct( "type", 'BSD', "text", lic ) );

end % packageTask