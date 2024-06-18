classdef tSetPosition < glttestutilities.TestInfrastructure
    %TSETPOSITION Tests for uix.setPosition.

    methods ( Test, Sealed )

        function tSetPositionErrorsWithIncorrectInputArguments( testCase )

            % Not enough.
            f = @() uix.setPosition();
            testCase.verifyError( f, 'MATLAB:minrhs', ...
                ['uix.setPosition has accepted less ', ...
                'than three input arguments.'] )

            % Too many.
            f = @() uix.setPosition( 0, 0, 0, 0 );
            testCase.verifyError( f, 'MATLAB:TooManyInputs', ...
                ['uix.setPosition has accepted more ', ...
                'than 3 input arguments.'] )

        end % tSetPositionErrorsWithIncorrectInputArguments

        function tSetPositionErrorsWithNonPixelUnitsForObjectWithoutUnits( testCase )

            % Create a dummy object (which has no 'Units' property).
            dummy = glttestutilities.ActivePositionPropertyDummy();
            % Invoke uix.setPosition with the dummy and non-pixel units.
            f = @() uix.setPosition( dummy, zeros( 1, 4 ), 'inches' );
            testCase.verifyError( f, 'uix:InvalidOperation', ...
                ['uix.setPosition has not errored when called with ', ...
                'an object with no ''Units'' property and non-pixel ', ...
                'units.'] )

        end % tSetPositionErrorsWithNonPixelUnitsForObjectWithoutUnits

        function tFigurePositionIsSetCorrectly( testCase )

            % Assume that the figure is non-empty.
            testCase.assumeGraphicsAreRooted()

            % Attempt to reposition the figure.
            requiredPosition = [0.25, 0.25, 0.50, 0.50];
            fig = testCase.ParentFixture.Parent;
            uix.setPosition( fig, requiredPosition, 'normalized' )
            testCase.verifyEqual( fig.Position, requiredPosition, ...
                ['uix.setPosition has not set the ', ...
                'required position of the figure correctly.'] )

        end % tFigurePositionIsSetCorrectly

        function tSetPositionRespectsAxesActivePositionProperty( testCase )

            % Create an axes with 'ActivePositionProperty' set to
            % 'position'.
            fig = testCase.ParentFixture.Parent;
            ax = axes( 'Parent', fig, ...
                'ActivePositionProperty', 'position' );
            testCase.addTeardown( @() delete( ax ) )

            % Verify that uix.setPosition sets the axes' 'Position'
            % property.
            requiredPosition = [0.25, 0.25, 0.50, 0.50];
            uix.setPosition( ax, requiredPosition, 'normalized' );
            testCase.verifyEqual( ax.Position, requiredPosition, ...
                ['uix.setPosition has incorrectly set the ', ...
                'axes position when ''ActivePositionProperty'' was ', ...
                'set to ''position''.'] )

            % Repeat the test when the 'ActivePositionProperty' is set to
            % 'outerposition'.
            ax.ActivePositionProperty = 'outerposition';
            uix.setPosition( ax, requiredPosition, 'normalized' );
            testCase.verifyEqual( ax.OuterPosition, requiredPosition, ...
                ['uix.setPosition has incorrectly set the ', ...
                'axes position when ''ActivePositionProperty'' was ', ...
                'set to ''outerposition''.'] )

        end % tSetPositionRespectsAxesActivePositionProperty

        function tSetPositionErrorsForUnknownActivePositionPropertyValue( testCase )

            % Create a test dummy.
            dummy = glttestutilities...
                .ActivePositionPropertyDummy( 'dummy' );
            % Verify that with an unknown 'ActivePositionProperty', an
            % error is thrown.
            f = @() uix.setPosition( dummy, zeros( 1, 4 ), 'pixels' );
            testCase.verifyError( f, 'uix:InvalidState', ...
                ['uix.setPosition has not thrown an error with ', ...
                ' ID ''uix:InvalidState'' when passed an object ', ...
                ' whose ''ActivePositionProperty'' is not ', ...
                '''position'' or ''outerposition''.'] )

        end % tSetPositionErrorsForUnknownActivePositionPropertyValue

    end % methods ( Test, Sealed )

end % classdef