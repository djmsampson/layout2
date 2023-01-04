classdef tChildEvent < utilities.mixin.TestInfrastructure
    %TCHILDEVENT Tests for uix.ChildEvent.

    methods ( Test, Sealed )

        function tConstructorErrorsWithNoInputs( testCase )

            f = @() uix.ChildEvent();
            testCase.verifyError( f, 'MATLAB:minrhs', ...
                ['The uix.ChildEvent constructor did not error ', ...
                'when passed zero input arguments.'] )

        end % tConstructorErrorsWithNoInputs

        function tConstructorStoresInput( testCase )

            fig = testCase.FigureFixture.Figure;
            CE = uix.ChildEvent( fig );
            diagnostic = ['The uix.ChildEvent constructor did not ', ...
                'store the given input in its ''Child'' property.'];
            if isempty( fig )
                testCase.verifyEmpty( CE.Child, diagnostic )
            else
                testCase.verifySameHandle( CE.Child, fig, diagnostic )
            end % if

        end % tConstructorStoresInput

    end % methods ( Test, Sealed )

end % class