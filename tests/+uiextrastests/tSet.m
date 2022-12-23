classdef tSet < utilities.mixin.TestInfrastructure
    %TSET Tests for uiextras.set.

    methods ( Test, Sealed )

        function tSetErrorsWithNotExactlyThreeInputs( testCase )

            % Test that fewer than three input arguments causes an error.
            f = @() uiextras.set();
            testCase.verifyError( f, ...
                'MATLAB:narginchk:notEnoughInputs', ...
                ['uiextras.set has accepted fewer ', ...
                'than three input arguments.'] )

            % Test that more than three input arguments causes an error.
            f = @() uiextras.set( 0, 0, 0, 0 );
            testCase.verifyError( f, ...
                'MATLAB:TooManyInputs', ...
                ['uiextras.set has accepted more ', ...
                'than three input arguments.'] )

        end % tSetErrorsWithNotExactlyThreeInputs

        function tSetIssuesDeprecationWarningWithThreeInputs( testCase )

            % Test that the function throws a warning when called with
            % three inputs.
            f = @() uiextras.set( 0, 0, 0 );
            testCase.verifyWarning( f, ...
                'uiextras:Deprecated', ...
                'uiextras.set has not thrown a deprecation warning.' )

        end % tSetIssuesDeprecationWarningWithThreeInputs

    end % methods ( Test, Sealed )

end % class