classdef tUnset < glttestutilities.TestInfrastructure
    %TUNSET Tests for uiextras.unset.

    methods ( Test, Sealed )

        function tUnsetErrorsWithNotExactlyTwoInputs( testCase )

            % Test that fewer than two input arguments causes an error.
            f = @() uiextras.unset();
            testCase.verifyError( f, ...
                'MATLAB:narginchk:notEnoughInputs', ...
                ['uiextras.unset has accepted fewer ', ...
                'than two input arguments.'] )

            % Test that more than two input arguments causes an error.
            f = @() uiextras.unset( 0, 0, 0 );
            testCase.verifyError( f, ...
                'MATLAB:narginchk:tooManyInputs', ...
                ['uiextras.unset has accepted more ', ...
                'than two input arguments.'] )

        end % tUnsetErrorsWithNotExactlyTwoInputs

        function tGetIssuesDeprecationErrorWithTwoInputs( testCase )

            % Test that the function throws a warning when called with two
            % inputs.
            f = @() uiextras.unset( 0, 0 );
            testCase.verifyWarning( f, ...
                'uiextras:Deprecated', ...
                'uiextras.unset has not thrown a deprecation error.' )

        end % tGetIssuesDeprecationErrorWithTwoInputs

    end % methods ( Test, Sealed )

end % class