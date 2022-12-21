function applyGLTFolderFixture( testCase )
%APPLYGLTFOLDERFIXTURE Apply a path fixture for the GUI Layout Toolbox main
%folder. This folder (and its subfolders) needs to be on the MATLAB path
%for the duration of the test procedure.

% Error-checking.
assert( isa( testCase, 'matlab.unittest.TestCase' ) && ...
    isscalar( testCase ) && isvalid( testCase ), ...
    'ApplyGLTFolderFixture:InvalidTestCase', ...
    'First input must be a valid scalar TestCase instance.' )

% Locate the GLT folder based on the current location.
testsFolder = fileparts( fileparts( mfilename( 'fullpath' ) ) );
projectFolder = fileparts( testsFolder );
toolboxFolder = fullfile( projectFolder, 'tbx', 'layout' );

% Ensure that 'layout' folder is added to the path during the test
% procedure, and removed/restored when the tests complete.
testCase.applyFixture( matlab.unittest.fixtures...
    .PathFixture( toolboxFolder ) );

end % applyGLTFolderFixture