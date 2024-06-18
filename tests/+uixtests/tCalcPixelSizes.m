classdef tCalcPixelSizes < glttestutilities.TestInfrastructure
    %TCALCPIXELSIZES Tests for uix.calcPixelSizes.

    methods ( Test, Sealed )

        function tOutputHasCorrectForm( testCase )

            % Call the function with some specific inputs.
            total = 0;
            mSizes = -1;
            pMinima = 1;
            pPadding = 0;
            pSpacing = 0;
            pSizes = uix.calcPixelSizes( total, mSizes, ...
                pMinima, pPadding, pSpacing );

            % Verify that the output is as expected.
            testCase.verifyClass( pSizes, 'double', ...
                ['uix.calcPixelSizes did not return an output of ', ...
                'type double.'] )
            testCase.verifySize( pSizes, [1, 1], ...
                'uix.calcPixelSizes did not return a scalar output.' )
            testCase.verifyGreaterThanOrEqual( pSizes, 0, ...
                ['uix.calcPixelSizes did not return a nonnegative ', ...
                'value.'] )

        end % tOutputHasCorrectForm

    end % methods ( Test, Sealed )

end % classdef