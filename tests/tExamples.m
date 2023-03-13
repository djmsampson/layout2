classdef tExamples < glttestutilities.TestInfrastructure
    %tExamples Tests for the layout documentation examples.

    properties ( TestParameter )
        % Example script names.
        ScriptFile = {'axesexample', ...
            'colorbarexample', ...
            'gridflexpositioning', ...
            'hierarchyexample', ...
            'paneltabexample', ...
            'visibleexample'}
        % Variables representing the main figure/app window in each
        % example.
        FigureVariable = {'window', 'window', 'f', ...
            'window', 'window', 'fig'}
    end % properties ( TestParameter )

    properties ( TestParameter )
        % Example function names.
        FunctionFile = {'callbackexample', ...
            'demoBrowser', ...
            'dockexample', ...            
            'minimizeexample'}
        % Variables representing the main figure/app window in each
        % example.
        OutputVariable = {'f', 'gui', 'fig', 'fig'}
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

        function tRunningExampleScriptIsWarningFree( ...
                testCase, ScriptFile, FigureVariable )

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
            exampleContent = fileread( [ScriptFile, '.m'] );

            % Write a wrapper function to the temporary file, providing an
            % output using the output variable name.
            fprintf( fileID, 'function %s = %s()\n\n', ...
                FigureVariable, tempFilename );
            fprintf( fileID, '%s', exampleContent );

            % Verify that running the wrapper function is warning-free.
            runner = @() exampleRunner( tempFilename );
            testCase.verifyWarningFree( runner, ['Running the ', ...
                ScriptFile, ' example was not warning-free.'] )

            function exampleRunner( file )

                fig = feval( file );
                testCase.addTeardown( @() delete( fig ) )

            end % exampleRunner

        end % tRunningExampleScriptIsWarningFree

        function tGuideAppIsWarningFree( testCase )

            testCase.verifyWarningFree( @guideAppRunner, ...
                ['Running the guideApp documentation example ', ...
                'was not warning-free.'] )

            function guideAppRunner()

                f = guideApp();
                testCase.addTeardown( @() delete( f ) )

            end % guideAppRunner

        end % tGuideAppIsWarningFree

        function tRunningExampleFunctionIsWarningFree( ...
                testCase, FunctionFile, OutputVariable )

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
            exampleContent = fileread( [FunctionFile, '.m'] );

            % Remove the function definition line.
            exampleContent = strsplit( exampleContent, '\n' );
            exampleContent = [exampleContent{2:end}];

            % Write a wrapper function to the temporary file, providing an
            % output using the output variable name.
            fprintf( fileID, 'function %s = %s()\n\n', ...
                OutputVariable, tempFilename );
            fprintf( fileID, '%s', exampleContent );            

            % Verify that running the wrapper function is warning-free.
            runner = @() exampleRunner( tempFilename );
            testCase.verifyWarningFree( runner, ['Running the ', ...
                FunctionFile, ' example was not warning-free.'] )

            function exampleRunner( file )

                fig = feval( file );
                if strcmp( FunctionFile, 'demoBrowser' )
                    testCase.addTeardown( @() delete( fig.Window ) )
                else
                    testCase.addTeardown( @() delete( fig ) )
                end % if

            end % exampleRunner

        end % tRunningExampleFunctionIsWarningFree

    end % methods ( Test, Sealed )

end % class