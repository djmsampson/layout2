classdef tTracking < glttestutilities.TestInfrastructure
    %TTRACKING Tests for uix.Tracking.

    methods ( TestMethodSetup )

        function clearTracking( ~ )

            % Clear the uix.tracking function.
            clear( 'tracking' )

        end % clearTracking

    end % methods ( TestMethodSetup )

    methods ( Test, Sealed )

        function tTrackingSnoozeIsConvertedToOn( testCase )

            % Record the current tracking state and add a suitable
            % teardown.
            trackingState = {'Tracking', 'State'};
            if ispref( trackingState{:} )
                currentState = getpref( trackingState{:} );
                restorer = @() setpref( trackingState{:}, currentState );
                testCase.addTeardown( restorer )
            else
                remover = @() rmpref( trackingState{:} );
                testCase.addTeardown( remover )
            end % if

            % Set the initial preference value to 'snooze'.
            setpref( trackingState{:}, 'snooze' )

            % Call the tracking function.
            state = uix.tracking( 'query' );

            % Verify that 'snooze' has been converted to 'on'.
            testCase.verifyEqual( state, 'on', ...
                ['uix.tracking has not converted the ''Tracking''', ...
                '''State'' preference from ''snooze'' to ''on''.'] )

        end % tTrackingSnoozeIsConvertedToOn

        function tTrackingDatePreferenceIsRemoved( testCase )

            % Record the current tracking date and add a suitable
            % teardown.
            trackingDate = {'Tracking', 'Date'};
            if ispref( trackingDate{:} )
                currentDate = getpref( trackingDate{:} );
                restorer = @() setpref( trackingDate{:}, currentDate );
                testCase.addTeardown( restorer )
            end % if

            % Set the initial preference value.
            setpref( trackingDate{:}, '2023-01-01' )

            % Call the tracking function.
            uix.tracking( 'query' );

            % Verify that the preference has been removed.
            testCase.verifyFalse( ispref( trackingDate{:} ), ...
                ['uix.tracking did not remove the ''Tracking''', ...
                ' ''Date'' preference.'] )

        end % tTrackingDatePreferenceIsRemoved

        function tTrackingSpoofIsWarningFree( testCase )

            % Capture the current RNG state and restore it after the test
            % completes.
            rngState = rng();
            testCase.addTeardown( @() rng( rngState ) )
            rng( 'default' )
            testCase.addTeardown( @() uix.tracking( 'reset' ) );
            spoofer = @() uix.tracking( 'spoof' );

            % Repeat to cover the various random number generation cases.
            for k = 1 : 7
                testCase.verifyWarningFree( spoofer, ...
                    ['uix.tracking with the ''spoof'' argument ', ...
                    'was not warning-free.'] )
            end % for

        end % tTrackingSpoofIsWarningFree

        function tTrackingErrorsWithInvalidArgument( testCase )

            f = @() uix.tracking( 'fake' );
            testCase.verifyError( f, 'tracking:InvalidArgument', ...
                'uix.tracking did not error with an invalid argument.' )

        end % tTrackingErrorsWithInvalidArgument

        function tTrackingErrorsForTooManyInputs( testCase )

            f = @() uix.tracking( 0, 0, 0, 0 );
            testCase.verifyError( f, 'MATLAB:narginchk:tooManyInputs', ...
                ['uix.tracking did not error when called with ', ...
                'too many inputs.'] )

        end % tTrackingErrorsForTooManyInputs

        function tTrackingIsWarningFreeWithThreeInputs( testCase )

            % Call uix.tracking with three inputs.
            f = @() uix.tracking( 'a', 'b', 'c' );
            diagnostic = ['uix.tracking was not warning-free when ', ...
                'called with three inputs.'];
            testCase.verifyWarningFree( f, diagnostic )

            % Repeat with tracking enabled.
            state = uix.tracking( 'query' );
            testCase.addTeardown( @() uix.tracking( state ) );
            uix.tracking( 'on' )
            testCase.verifyWarningFree( f, diagnostic )

            % Repeat with one output.
            testCase.verifyWarningFree( @trackingWrapper, diagnostic )

            function s = trackingWrapper()

                s = uix.tracking( 'a', 'b', 'c' );

            end % trackingWrapper

        end % tTrackingIsWarningFreeWithThreeInputs

        function tTrackingIsWarningFreeWhenDeployed( testCase )

            % Assume we are not in deployed mode.
            testCase.assumeNotDeployed()            

            % Set up a path fixture for isdeployed(). Disable the name 
            % conflict warning for the duration of the test.
            ID = 'MATLAB:dispatcher:nameConflict';
            w = warning( 'query', ID );
            testCase.addTeardown( @() warning( w ) )
            warning( 'off', ID )
            currentFolder = fileparts( mfilename( 'fullpath' ) );
            testsFolder = fileparts( currentFolder );
            targetFolder = fullfile( testsFolder, ...
                '+glttestutilities', 'Shadows', 'isdeployed' );
            fixture = matlab.unittest.fixtures.PathFixture( targetFolder );
            testCase.applyFixture( fixture );

            % Call uix.tracking with three inputs.
            state = uix.tracking( 'query' );
            testCase.addTeardown( @() uix.tracking( state ) );
            uix.tracking( 'on' )
            f = @() uix.tracking( 'a', 'b', 'c' );
            diagnostic = ['uix.tracking was not warning-free when ', ...
                'called with three inputs.'];
            testCase.verifyWarningFree( f, diagnostic )

        end % tTrackingIsWarningFreeWhenDeployed

        function tResettingTrackingIsWarningFreeOnMac( testCase )

            % Assume we are not on a Mac.
            testCase.assumeNotMac()           

            % Set up path fixtures for ispc() and ismac(). Disable the 
            % name conflict warning for the duration of the test.
            ID = 'MATLAB:dispatcher:nameConflict';
            w = warning( 'query', ID );
            testCase.addTeardown( @() warning( w ) )
            warning( 'off', ID )
            currentFolder = fileparts( mfilename( 'fullpath' ) );
            testsFolder = fileparts( currentFolder );
            targetFolder1 = fullfile( testsFolder, ...
                '+glttestutilities', 'Shadows', 'ismac' );
            targetFolder2 = fullfile( testsFolder, ...
                '+glttestutilities', 'Shadows', 'ispc' );
            targetFolders = {targetFolder1, targetFolder2};
            fixture = ...
                matlab.unittest.fixtures.PathFixture( targetFolders );
            testCase.applyFixture( fixture );

            % Call uix.tracking with the 'reset' option.
            f = @() uix.tracking( 'reset' );
            testCase.verifyWarningFree( f, ...
                ['uix.tracking was not warning-free when called ', ...
                'with the ''reset'' option on a Mac.'] )

        end % tResettingTrackingIsWarningFreeOnMac

        function tResettingTrackingIsWarningFreeOnUnix( testCase )

            % Assume we are not on Unix.
            testCase.assumeNotUnix()           

            % Set up path fixtures for ispc() and isunix(). Disable the 
            % name conflict warning for the duration of the test.
            ID = 'MATLAB:dispatcher:nameConflict';
            w = warning( 'query', ID );
            testCase.addTeardown( @() warning( w ) )
            warning( 'off', ID )
            currentFolder = fileparts( mfilename( 'fullpath' ) );
            testsFolder = fileparts( currentFolder );
            targetFolder1 = fullfile( testsFolder, ...
                '+glttestutilities', 'Shadows', 'isunix_true' );
            targetFolder2 = fullfile( testsFolder, ...
                '+glttestutilities', 'Shadows', 'ispc' );
            targetFolders = {targetFolder1, targetFolder2};
            fixture = ...
                matlab.unittest.fixtures.PathFixture( targetFolders );
            testCase.applyFixture( fixture );

            % Call uix.tracking with the 'reset' option.
            f = @() uix.tracking( 'reset' );
            testCase.verifyWarningFree( f, ...
                ['uix.tracking was not warning-free when called ', ...
                'with the ''reset'' option on Unix.'] )

        end % tResettingTrackingIsWarningFreeOnUnix

        function tTrackingErrorsWithTooManyOutputs( testCase )

            function [a, b] = trackingWrapper()

                [a, b] = uix.tracking( 'a', 'b', 'c' );

            end % trackingWrapper

            testCase.verifyError( @trackingWrapper, ...
                'MATLAB:nargoutchk:tooManyOutputs', ...
                ['uix.tracking did not error when called with ', ...
                '3 inputs and too many outputs.'] )

        end % tTrackingErrorsWithTooManyOutputs

    end % methods ( Test, Sealed )

end % class