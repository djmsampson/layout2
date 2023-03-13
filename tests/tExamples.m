classdef tExamples < glttestutilities.TestInfrastructure
    %tExamples Tests for the layout documentation examples.

    properties ( TestParameter )
        % Example file names.
        CodeFile = {'axesexample', ...
            'colorbarexample', ...
            'gridflexpositioning', ...
            'hierarchyexample', ...
            'paneltabexample', ...
            'visibleexample'}
        % Variables representing the main figure/app window in each
        % example.
        OutputVariable = {'window', 'window', 'f', ...
            'window', 'window', 'fig'}
    end % properties ( TestParameter )

    methods ( TestClassSetup )

        function addDocumentationFoldersToPath( testCase )

            % Write down the documentation folders.
            testsFolder = fileparts( mfilename( 'fullpath' ) );
            projectFolder = fileparts( testsFolder );
            foldersToAdd = {fullfile( projectFolder, 'docsrc' ), ...
                fullfile( projectFolder, 'docsrc', 'Examples' )};

            % Apply a path fixture for these folders.
            pathFixture = matlab.unittest.fixtures...
                .PathFixture( foldersToAdd );
            testCase.applyFixture( pathFixture )

        end % addDocumentationFoldersToPath

    end % methods ( TestClassSetup )

    methods ( Test, Sealed, ParameterCombination = 'sequential' )

        function tRunningExampleIsWarningFree( ...
                testCase, CodeFile, OutputVariable )

            % Do not repeat this test for each parent type.
            testCase.assumeComponentHasEmptyParent()

            % Assume that we are in MATLAB R2016a or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2016a' )

            % Create a working folder fixture.
            tempFolderFixture = matlab.unittest.fixtures...
                .WorkingFolderFixture();
            testCase.applyFixture( tempFolderFixture )

            % Create a temporary file.
            [~, tempFilename] = fileparts( tempname );
            tempFullFilename = fullfile( ...
                tempFolderFixture.Folder, [tempFilename, '.m'] );
            fileID = fopen( tempFullFilename, 'w' );
            testCase.addTeardown( @() fclose( fileID ) );

            % Read the example contents.
            exampleContent = fileread( [CodeFile, '.m'] );

            % Write a wrapper function to the temporary file, providing an
            % output using the output variable name.
            fprintf( fileID, 'function %s = %s()\n\n', ...
                OutputVariable, tempFilename );
            fprintf( fileID, '%s', exampleContent );

            % Verify that running the wrapper function is warning-free.
            runner = @() exampleRunner( tempFilename );
            testCase.verifyWarningFree( runner, ['Running the ', ...
                CodeFile, ' example was not warning-free.'] )

            function exampleRunner( file )

                fig = feval( file );
                testCase.addTeardown( @() delete( fig ) )

            end % exampleRunner

        end % tRunningExampleIsWarningFree

    end % methods ( Test, Sealed )

end % class