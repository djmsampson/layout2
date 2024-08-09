classdef tFunctionSignatures < glttestutilities.TestInfrastructure
    %TFUNCTIONSIGNATURES Verify that functionSignatures.json is free of
    %syntax errors.
    
    methods ( Test )

        function tFunctionSignaturesAreFreeOfSyntaxErrors( testCase )

            % Only run this test once.
            testCase.assumeComponentHasEmptyParent()

            % validateFunctionSignaturesJSON was introduced in R2018b.
            testCase.assumeMATLABVersionIsAtLeast( 'R2018b' )

            % Define the full path to the function signatures file.
            testsFolder = fileparts( mfilename( 'fullpath' ) );
            projectRoot = fileparts( testsFolder );
            layoutFolder = fullfile( projectRoot, 'tbx', 'layout' );
            signaturesFile = fullfile( layoutFolder, 'resources', ...
                'functionSignatures.json' );
            
            % Perform the validation.
            syntaxErrors = validateFunctionSignaturesJSON( ...
                signaturesFile );
            testCase.verifyEmpty( syntaxErrors, ['At least one ', ...
                'syntax error was detected in ', ...
                'functionSignatures.json. The detected error(s) were ', ...
                'as follows: ', evalc( 'disp( syntaxErrors )' )] )

        end % tFunctionSignaturesAreFreeOfSyntaxErrors

    end % methods ( Test )

end % classdef