classdef tExamples < glttestutilities.TestInfrastructure
    %tExamples Tests for the layout documentation examples.

    properties ( Access = private )
        % Documentation examples folder.
        ExamplesFolder
    end % properties ( Access = private )

    methods ( TestClassSetup )

        function addDocumentationFolderToPath( testCase )

            % Write down the documentation folders.
            testsFolder = fileparts( mfilename( 'fullpath' ) );
            projectFolder = fileparts( testsFolder );
            testCase.ExamplesFolder = fullfile( projectFolder, 'tbx', ...
                'layoutdoc', 'Examples' );

            % Apply path fixtures for this folder.
            pathFixture = matlab.unittest.fixtures...
                .PathFixture( testCase.ExamplesFolder );
            testCase.applyFixture( pathFixture )
            
        end % addDocumentationFolderToPath

    end % methods ( TestClassSetup )

    methods ( Test, Sealed )

        function tExampleFunctionsAreWarningFree( testCase )            

            % Do not repeat this test for each parent type.
            testCase.assumeComponentHasEmptyParent()

            % List the functions.
            examplesFolder = testCase.ExamplesFolder;
            functionList = cellstr( char( ...
                ls( fullfile( examplesFolder, '*.m' ) ) ) );
            
            % Add the App Designer example if we are in R2022a or later 
            % (this example requires support for uix.BoxPanel).
            if ~verLessThan( 'matlab', '9.12' ) %#ok<*VERLESSMATLAB>
                functionList = [functionList;
                    cellstr( ...
                    ls( fullfile( examplesFolder, '*.mlapp' ) ) )];
            end % if            

            % Remove the extensions (.m, .mlapp).
            for k = 1 : numel( functionList )
                [~, functionList{k}] = fileparts( functionList{k} );                
            end % for

            % Remove the 'randomPlotter' quick start example if we are in
            % R2020a or earlier.
            if verLessThan( 'matlab', '9.9' ) % R2020b is 9.9
                toRemove = strcmp( functionList, 'randomPlotter' );
                functionList(toRemove) = [];
            end % if

            % Verify that launching the examples are warning-free.
            for k = 1 : numel( functionList )
                currentExample = functionList{k};
                exampleRunner = @() runner( currentExample );
                testCase.verifyWarningFree( exampleRunner, ...
                    ['Running the ', currentExample, ...
                    ' example was not warning-free.'] )
            end % for

            function runner( example )

                fig = feval( example );
                testCase.addTeardown( @() delete( fig ) )

            end % runner

        end % tExampleFunctionsAreWarningFree

    end % methods ( Test, Sealed )

end % classdef