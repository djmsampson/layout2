classdef tSetVisible < glttestutilities.TestInfrastructure
    %TSETVISIBLE Tests for uix.setVisible.

    methods ( Test, Sealed )

        function tSetVisibleThrowsErrorWithIncorrectNumInputs( testCase )

            % Zero inputs.
            f = @() uix.setVisible();
            testCase.verifyError( f, ...
                'MATLAB:narginchk:notEnoughInputs', ...
                ['Calling the uix.setVisible function with zero ', ...
                'input arguments did not throw an error.'] )

            % One input.
            f = @() uix.setVisible( 1 );
            testCase.verifyError( f, ...
                'MATLAB:narginchk:notEnoughInputs', ...
                ['Calling the uix.setVisible function with one ', ...
                'input argument did not throw an error.'] )

            % Too many inputs.
            f = @() uix.setVisible( 0, 0, 0, 0 );
            testCase.verifyError( f, ...
                'MATLAB:narginchk:tooManyInputs', ...
                ['Calling the uix.setVisible function with too ', ...
                'many input arguments did not throw an error.'] )

        end % tSetVisibleThrowsErrorWithIncorrectNumInputs

        function tSetVisibleAcceptsLogicalValues( testCase )

            % Run the test for rooted graphics.
            testCase.assumeGraphicsAreRooted()
            testFig = testCase.ParentFixture.Parent;

            % Define a list of possible values.
            possibleValues = {true, false, 'on', 'off'};
            expectedVisibility = {'on', 'off', 'on', 'off'};
            for k = 1 : numel( possibleValues )
                uix.setVisible( testFig, possibleValues{k} )
                testCase.verifyEqual( char( testFig.Visible ), ...
                    expectedVisibility{k}, ['Calling uix.setVisible', ...
                    ' on a figure did not assign the value correctly.'] )
            end % for

        end % tSetVisibleAcceptsLogicalValues

        function tSetVisibleSetsAxesContentsVisible( testCase )

            % Specify the required test combinations.
            positionProperties = {'outerposition', 'position'};
            expected = {'on', 'off'};

            % Iterate.
            for k1 = 1 : numel( positionProperties )

                % Create an axes containing content.
                ax = axes( 'Parent', testCase.ParentFixture.Parent, ...
                    'ActivePositionProperty', positionProperties{k1} );
                surf( ax, membrane() )
                testCase.addTeardown( @() delete( ax ) )

                for k2 = 1 : numel( expected )

                    % Call uix.setVisible.
                    uix.setVisible( ax, expected{k2} )

                    % Check.
                    testCase.verifyEqual( char( ax.ContentsVisible ), ...
                        expected{k2}, ...
                        ['The uix.setVisible function did not set ', ...
                        'the axes property ''ContentsVisible'' ', ...
                        'correctly when the value ''', expected{k2}, ...
                        ' was specified.'] )

                end % for

            end % for

        end % tSetVisibleSetsAxesContentsVisible

        function tSetVisibleAsyncEventuallyUpdatesVisibility( testCase )

            % Assume that we're in the rooted case.
            testCase.assumeGraphicsAreRooted()
            testFig = testCase.ParentFixture.Parent;

            % Set the figure visibility, specifying a delay.
            expected = {'on', 'off'};
            for k = 1 : numel( expected )
                uix.setVisible( testFig, expected{k}, 2 )

                % Verify that the figure visibility eventually becomes the
                % expected value.
                testCase.verifyThat( @getFigureVisibility, ...
                    matlab.unittest.constraints.Eventually( ...
                    matlab.unittest.constraints.IsEqualTo( ...
                    expected{k} ), 'WithTimeoutOf', 5 ) )
            end % for

            function v = getFigureVisibility()

                v = char( testFig.Visible );

            end % getFigureVisibility

        end % tSetVisibleAsyncEventuallyUpdatesVisibility

        function tCallingSetVisibleAsyncTwiceUpdatesVisibility( testCase )

            % Assume that we're in the rooted case.
            testCase.assumeGraphicsAreRooted()
            testFig = testCase.ParentFixture.Parent;

            % Call uix.setVisible twice.
            expected = 'off';
            uix.setVisible( testFig, expected, 2 )
            uix.setVisible( testFig, expected, 2 )

            % Verify that the test figure's visibility eventually gets
            % updated.
            testCase.verifyThat( @getFigureVisibility, ...
                matlab.unittest.constraints.Eventually( ...
                matlab.unittest.constraints.IsEqualTo( ...
                expected ), 'WithTimeoutOf', 10 ) )

            function v = getFigureVisibility()

                v = char( testFig.Visible );

            end % getFigureVisibility

        end % tCallingSetVisibleAsyncTwiceUpdatesVisibility

        function tSetVisibleIssuesWarningForIncorrectAsyncArguments( ...
                testCase )

            % Exit if we're running in CI. Such tests run in strict mode,
            % and this test should result in a warning being issued as the
            % expected behavior.
            testCase.assumeNotRunningOnCI()

            % Assume that we're in the rooted case.
            testCase.assumeGraphicsAreRooted()
            testFig = testCase.ParentFixture.Parent;

            % Preserve the user state.
            [previousMessage, previousID] = lastwarn();
            testCase.addTeardown( ...
                @() lastwarn( previousMessage, previousID ) )

            % Start with a clear warning state.
            lastwarn( '', '' )

            % Execute an erroneous call to uix.setVisible.
            uix.setVisible( testFig, 'badvalue', 0.5 );

            % Verify that a warning is eventually thrown.
            testCase.verifyThat( @lastWarningID, ...
                matlab.unittest.constraints.Eventually( ...
                matlab.unittest.constraints.IsEqualTo( ...
                ['MATLAB:datatypes:', ...
                'onoffboolean:UnknownOnOffBooleanValue'] ), ...
                'WithTimeoutOf', 2 ) )

            function id = lastWarningID()

                [~, id] = lastwarn();

            end % lastWarningID

        end % tSetVisibleIssuesWarningForIncorrectAsyncArguments

    end % methods ( Test, Sealed )

end % classdef