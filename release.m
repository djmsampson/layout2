function release( mode )
%release  Build, test and package GUI Layout Toolbox
%
%  release builds, tests and packages.
%
%  release -verbose displays detailed information.

%  Copyright 2009-2016 The MathWorks, Inc.
%  $Revision: 921 $ $Date: 2014-06-03 11:11:36 +0100 (Tue, 03 Jun 2014) $

%% Check inputs
switch nargin
    case 0
        verbose = false;
    case 1
        if ischar( mode ) && strcmp( mode, '-verbose' )
            verbose = true;
        else
            error( 'Invalid mode.' )
        end
    otherwise
        narginchk( 0, 1 )
end

%% Grab this directory and the current directory
prjDir = fileparts( mfilename( 'fullpath' ) );
tbxDir = fullfile( prjDir, 'tbx' );
currentDir = pwd;

%% Check MATLAB and related tools
assert( ~verLessThan( 'MATLAB', '8.4' ), 'MATLAB R2014b or higher is required.' )
assert( ~isempty( ver( 'DocToolsHelp' ) ), 'DocTools is required.' )

%% Check installation
fprintf( 1, 'Checking installation...' );
v = ver( 'layout' );
switch numel( v )
    case 0
        fprintf( 1, ' failed.\n' );
        error( 'GUI Layout Toolbox not found.' )
    case 1
        % OK so far
    otherwise
        fprintf( 1, ' failed.\n' );
        error( 'There are multiple copies of GUI Layout Toolbox on the MATLAB path.' )
end
if strncmp( which( 'layoutRoot' ), tbxDir, numel( tbxDir ) )
    fprintf( 1, ' OK.\n' );
else
    fprintf( 1, ' failed.\n' );
    error( 'GUI Layout Toolbox code at %s is not on the MATLAB path.', prjDir )
end

%% Build documentation
fprintf( 1, 'Generating documentation...' );
try
    cd( fullfile( prjDir, 'docsrc' ) )
    log = evalc( 'buildDoc' );
    close( 'all', 'force' )
    drawnow()
    cd( prjDir )
    fprintf( 1, ' OK.\n' );
    if verbose
        fprintf( 1, '%s', log );
    end
catch e
    cd( prjDir )
    fprintf( 1, ' failed.\n' );
    e.rethrow()
end

%% Build examples
fprintf( 1, 'Generating examples...' );
try
    cd( fullfile( prjDir, 'docsrc' ) )
    buildDocExamples()
    close all force
    drawnow
    cd( prjDir )
    fprintf( 1, ' OK.\n' );
catch e
    cd( prjDir )
    fprintf( 1, ' OK.\n' );
    e.rethrow()
end

%% Run tests
fprintf( 1, 'Running tests...' );
cd( fullfile( prjDir, 'tests' ) )
[log, results] = evalc( 'runtests' );
cd( currentDir )
if ~any( [results.Failed] )
    fprintf( 1, ' OK.\n' );
else
    fprintf( 1, ' failed.\n' );
    error( '%s', log )
end

%% Check version
fprintf( 1, 'Checking version...' );
prj = fullfile( prjDir, 'GUI Layout Toolbox.prj' );
w = matlab.addons.toolbox.toolboxVersion( prj );
if strcmp( w, v.Version )
    fprintf( 1, ' OK.\n' );
else
    fprintf( 1, ' failed.\n' );
    error( 'Package version %s does not match code version %s.', w, v.Version )
end

%% Package and rename
fprintf( 1, 'Packaging...' );
try
    mltbx = fullfile( prjDir, 'releases', ['GUI Layout Toolbox ' v.Version '.mltbx'] );
    matlab.addons.toolbox.packageToolbox( prj, mltbx )
    fprintf( 1, ' OK.\n' );
catch e
    fprintf( 1, ' failed.\n' );
    e.rethrow()
end

%% Show message
fprintf( 1, 'Created package %s\n', mltbx );

end % release