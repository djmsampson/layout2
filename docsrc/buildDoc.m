function buildDoc()
%buildDoc  Build documentation for GUI Layout Toolbox
%
%   buildDoc() uses DocTools to create toolbox documentation for GUI Layout
%   Toolbox.

%  Copyright 2009-2016 The MathWorks, Inc.
%  $Revision: 155 $ $Date: 2010-05-27 08:40:03 +0100 (Thu, 27 May 2010) $

% Set the type ('toolbox', 'blockset', 'link' or 'other')
type = 'toolbox';

% Get the version information
v_All = ver('layout');
if isempty(v_All)
    error('layout:buildDoc:noVersion', ...
        'Could not find an installed version of layout toolbox. Please run ''install'' and try again.');
end

% If more than one version is found, use the highest path
if size(v_All, 2) > 1
    v = v_All(1);
else
    v = v_All;
end


verStr = v.Version;

% Create a short name without the toolbox suffix
name = v.Name(1:end-8);

fprintf('Building documentation for %s v%s...\n', name, verStr)

% Work out where to put it
srcDir = fileparts( mfilename( 'fullpath' ) );
layoutDir = layoutRoot();
tbxDir = fileparts( layoutDir );
dstDir = fullfile( tbxDir, 'layoutdoc' );

% Now build the doc
docBuild( name, verStr, srcDir, dstDir, type );

% Copy some extra bits
copyfile( fullfile( srcDir, 'layoutDocRoot.m' ), dstDir );

% Delete some files
delete( fullfile( dstDir, 'doc.m' ) )

end % buildDoc