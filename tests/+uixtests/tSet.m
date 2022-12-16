classdef tSet < matlab.unittest.TestCase
    %TSET Tests for uix.set.

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

        function tSetErrorsWithIncorrectInputArguments( testCase )

            % Not enough input arguments.
            f = @() uix.set();
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                'uix.set has accepted zero input arguments.' )

            % A positive even number of input arguments.
            f = @() uix.set( [], [] );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['uix.set has accepted a positive even ', ...
                'number of input arguments.'] )

        end % tSetErrorsWithIncorrectInputArguments

        function tSetWithOneArgumentIsWarningFree( testCase )

            % Call uix.set with one input argument.
            f = @() uix.set( testCase.Fixture.Figure );
            testCase.verifyWarningFree( f, ...
                ['uix.set has issued a warning when called ', ...
                'with one input argument.'] )

        end % tSetWithOneArgumentIsWarningFree

        function tSetLeavesInputUnchangedWhenNoOtherArgumentsAreGiven( testCase )

            % Make a copy of the figure from the fixture.
            fig1 = testCase.Fixture.Figure;
            fig2 = copyobj( fig1, groot() );
            testCase.addTeardown( @() delete( fig2 ) );
            % Invoke uix.set on the figure from the fixture.
            uix.set( fig1 )
            % Verify that some figure properties are unchanged.
            for prop = {'Name', 'Units', 'Position', 'Visible'}
                testCase.verifyEqual( fig1.(prop{1}), fig2.(prop{1}), ...
                    ['uix.set has incorrectly modified the input ', ...
                    'when no other input arguments were specified.'] )
            end % for

        end % tSetLeavesInputUnchangedWhenNoOtherArgumentsAreGiven

        function tSetAssignsPropertyValuesCorrectly( testCase )

            % Set some figure properties using uix.set.
            pairs = {'Color', [1, 0, 0], ...
                'Name', 'Test Figure', ...
                'Units', 'normalized', ...
                'Position', [0.25, 0.25, 0.50, 0.50]};
            fig = testCase.Fixture.Figure;
            uix.set( fig, pairs{:} )

            % Verify that the figure properties were assigned correctly.
            for k = 1:length( pairs )/2
                name = pairs{2*k-1};
                value = pairs{2*k};
                testCase.verifyEqual( fig.(name), value, ...
                    ['uix.set has not assigned the figure''s ''', name, ...
                    'property correctly.'] )
            end % for

        end % tSetAssignsPropertyValuesCorrectly

    end % methods ( Test )

end % class

