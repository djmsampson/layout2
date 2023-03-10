classdef tSet < glttestutilities.TestInfrastructure
    %TSET Tests for uix.set.

    methods ( Test, Sealed )

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
            f = @() uix.set( testCase.ParentFixture.Parent );
            testCase.verifyWarningFree( f, ...
                ['uix.set has issued a warning when called ', ...
                'with one input argument.'] )

        end % tSetWithOneArgumentIsWarningFree

        function tSetLeavesInputUnchangedWhenNoOtherArgumentsAreGiven( testCase )

            % This test only applies to Java figures.
            testCase.assumeGraphicsAreRooted()
            testCase.assumeGraphicsAreNotWebBased()

            % Make a copy of the figure from the fixture.
            fig1 = testCase.ParentFixture.Parent;
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

            % Assume that the figure is non-empty.
            testCase.assumeGraphicsAreRooted()

            % Set some figure properties using uix.set.
            pairs = {'Color', [1, 0, 0], ...
                'Name', 'Test Figure', ...
                'Units', 'normalized', ...
                'Position', [0.25, 0.25, 0.50, 0.50]};
            fig = testCase.ParentFixture.Parent;
            uix.set( fig, pairs{:} )

            % Verify that the figure properties were assigned correctly.
            for k = 1 : 2 : length( pairs )-1
                name = pairs{k};
                value = pairs{k+1};
                testCase.verifyEqual( fig.(name), value, ...
                    ['uix.set has not assigned the figure''s ''', ...
                    name, ''' property correctly.'] )
            end % for

        end % tSetAssignsPropertyValuesCorrectly

    end % methods ( Test, Sealed )

end % class