close all
clear
clc

% Prepare package

tempDir = 'BaT';
testDir = 'tests';
copyfile( testDir , fullfile( tempDir, testDir ) );
layoutDir = fullfile( 'tbx', 'layout' );
copyfile( layoutDir, fullfile( tempDir, layoutDir ) );
docDir = fullfile( 'docsrc', 'Examples' );
copyfile( docDir, fullfile( tempDir, docDir ) );
file = fullfile( 'docsrc', 'layoutDocRoot.m' );
copyfile( file, fullfile( tempDir, file ) );

% ZIP

cd BaT
zip('../ForSubmissionInBaT.zip',{'tests' 'tbx' 'docsrc'})
cd ../

% Clean

rmdir('BaT','s')