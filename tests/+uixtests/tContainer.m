classdef tContainer < glttestutilities.TestInfrastructure
    %TCONTAINER Tests for uix.Container.

    methods ( Test, Sealed )

        function tConstructorReturnsScalarObject( testCase )

            % Call the constructor.
            c = uix.Container();

            % Verify the type and size of the output.
            testCase.verifyClass( c, 'uix.Container', ...
                ['The uix.Container constuctor did not return an ', ...
                'object of type ''uix.Container''.'] )
            testCase.verifySize( c, [1, 1], ...
                ['The uix.Container constructor did not return a ', ...
                'scalar object.'] )

        end % tConstructorReturnsScalarObject

    end % methods ( Test, Sealed )

end % classdef