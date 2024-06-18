classdef tGet < glttestutilities.TestInfrastructure
    %TGET Tests for uiextras.get.

    methods ( Test, Sealed )

        function tGetErrorsWithNotExactlyTwoInputs( testCase )

            % Test that fewer than two input arguments causes an error.
            f = @() uiextras.get();
            testCase.verifyError( f, ...
                'MATLAB:narginchk:notEnoughInputs', ...
                ['uiextras.get has accepted fewer ', ...
                'than two input arguments.'] )

            % Test that more than two input arguments causes an error.
            f = @() uiextras.get( 0, 0, 0 );
            testCase.verifyError( f, ...
                'MATLAB:TooManyInputs', ...
                ['uiextras.get has accepted more ', ...
                'than two input arguments.'] )

        end % tGetErrorsWithNotExactlyTwoInputs

        function tGetIssuesDeprecationErrorWithTwoInputs( testCase )

            % Test that the function throws an error when called with two
            % inputs.
            f = @() uiextras.get( 0, 0 );
            testCase.verifyError( f, ...
                'uiextras:Deprecated', ...
                'uiextras.get has not thrown a deprecation error.' )

        end % tGetIssuesDeprecationErrorWithTwoInputs

    end % methods ( Test, Sealed )

end % classdef