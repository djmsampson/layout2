function prepareBaTSubmission
    %TODO All TEST_REQUIREMENTS.xml should be removed from the release
    % process
    BaTElements = {...
        fullfile( 'tbx', 'layout' );...
        fullfile( 'docsrc', 'Examples' );...
        fullfile( 'docsrc', 'layoutDocRoot.m' );...
        'tests'};
    
    % Prepare a temp folder for submission
    tempDir = fullfile( tempname, 'BaT' );
    mkdir( tempDir );
    
    % Copy all BaTElements
    for i = 1:numel( BaTElements )
        copyfile( BaTElements{i}, fullfile( tempDir, BaTElements{i} ) );
    end
    
    % Create the zip file for submission
    zip( 'forSubmissionInBaT.zip', tempDir )
    
    % Clean
    rmdir( tempDir , 's' )
end