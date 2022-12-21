classdef tGetPosition < matlab.unittest.TestCase
    %TGETPOSITION Tests for uix.getPosition.

    properties ( Access = private )
        % Figure fixture.
        Fixture
    end % properties ( Access = private )

    methods ( TestClassSetup )

        function applyFigureFixture( testCase )

            % Create and store the legacy figure fixture.
            figFix = matlab.unittest.fixtures.FigureFixture( 'legacy' );
            testCase.Fixture = testCase.applyFixture( figFix );

        end % applyFigureFixture

    end % methods ( TestClassSetup )

    methods ( Test )

        function tGetPositionReturnsExpectedDataType( testCase )

            % Verify that the output of uix.getPosition is of type double.
            p = uix.getPosition( testCase.Fixture.Figure, 'pixels' );
            testCase.verifyClass( p, 'double', ...
                ['uix.getPosition has returned an ', ...
                'output not of type double.'] )

        end % tGetPositionReturnsExpectedDataType

        function tGetPositionReturnsExpectedSize( testCase )

            % Verify that the output of uix.getPosition is of size 1-by-4.
            p = uix.getPosition( testCase.Fixture.Figure, 'pixels' );
            testCase.verifySize( p, [1, 4], ...
                ['uix.getPosition has returned an ', ...
                'output with size not equal to [1, 4].'] )

        end % tGetPositionReturnsExpectedSize

        function tGetPositionRespectsAxesActivePositionProperty( testCase )

            % Create an axes with 'ActivePositionProperty' set to
            % 'position'.
            fig = testCase.Fixture.Figure;
            ax = axes( 'Parent', fig, ...
                'ActivePositionProperty', 'position' );
            testCase.addTeardown( @() delete( ax ) )

            % Verify that uix.getPosition returns the axes' 'Position'
            % property.
            p = uix.getPosition( ax, 'normalized' );
            testCase.verifyEqual( p, ax.Position, ...
                ['uix.getPosition has incorrectly computed the ', ...
                'axes position when ''ActivePositionProperty'' was ', ...
                'set to ''position''.'] )

            % Repeat the test when the 'ActivePositionProperty' is set to
            % 'outerposition'.
            ax.ActivePositionProperty = 'outerposition';
            p = uix.getPosition( ax, 'normalized' );
            testCase.verifyEqual( p, ax.OuterPosition, ...
                ['uix.getPosition has incorrectly computed the ', ...
                'axes position when ''ActivePositionProperty'' was ', ...
                'set to ''outerposition''.'] )

        end % tGetPositionRespectsAxesActivePositionProperty

        function tGetPositionErrorsForUnknownActivePositionPropertyValue( testCase )

            % Create a test dummy.
            dummy = utilities.ActivePositionPropertyTestDummy( 'dummy' );
            % Verify that with an unknown 'ActivePositionProperty', an
            % error is thrown.
            f = @() uix.getPosition( dummy, 'pixels' );
            testCase.verifyError( f, 'uix:InvalidState', ...
                ['uix.getPosition has not thrown an error with ', ...
                ' ID ''uix:InvalidState'' when passed an object ', ...
                ' whose ''ActivePositionProperty'' is not ', ...
                '''position'' or ''outerposition''.'] )

        end % tGetPositionErrorsForUnknownActivePositionPropertyValue

        function tGetPositionAssumesPixelsWhenUnitsAreNotPresent( testCase )

            % Create a test dummy (with no 'Units' property).
            dummy = utilities.ActivePositionPropertyTestDummy( 'position' );
            p = uix.getPosition( dummy, 'pixels' );
            % Verify that the position is returned correctly.
            testCase.verifyEqual( p, dummy.Position, ...
                ['uix.getPosition has computed an incorrect ', ...
                'position when the input object does not have ', ...
                'a ''Units'' property.'] )

        end % tGetPositionAssumesPixelsWhenUnitsAreNotPresent

        function tGetPositionConvertsUnitsCorrectly( testCase )

            % Create a figure with normalized units.
            fig = testCase.Fixture.Figure;
            fig.Units = 'normalized';
            % Compute the figure's position in pixels.
            p = uix.getPosition( fig, 'pixels' );
            % Compare this to the figure's actual position in pixels.
            fig.Units = 'pixels';
            testCase.verifyEqual( p, fig.Position, ...
                ['uix.getPosition has computed an incorrect ', ...
                'position when the input units differ from the ', ...
                'object''s units.'] )

        end % tGetPositionConvertsUnitsCorrectly

    end % methods ( Test )

end % class