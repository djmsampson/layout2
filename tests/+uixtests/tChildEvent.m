classdef tChildEvent < glttestutilities.TestInfrastructure
    %TCHILDEVENT Tests for uix.ChildEvent.

    methods ( Test, Sealed )

        function tConstructorErrorsWithNoInputs( testCase )

            f = @() uix.ChildEvent();
            testCase.verifyError( f, 'MATLAB:minrhs', ...
                ['The uix.ChildEvent constructor did not error ', ...
                'when passed zero input arguments.'] )

        end % tConstructorErrorsWithNoInputs

        function tConstructorStoresInput( testCase )

            parent = testCase.ParentFixture.Parent;
            CE = uix.ChildEvent( parent );
            diagnostic = ['The uix.ChildEvent constructor did not ', ...
                'store the given input in its ''Child'' property.'];
            if isempty( parent )
                testCase.verifyEmpty( CE.Child, diagnostic )
            else
                testCase.verifySameHandle( CE.Child, parent, diagnostic )
            end % if

        end % tConstructorStoresInput

    end % methods ( Test, Sealed )

end % class