function disableTracking( testCase )
%DISABLETRACKING Disable GUI Layout Toolbox tracking during the test
%procedures. Restore the previous tracking state when the tests are 
%complete.

% Error-checking.
assert( isa( testCase, 'matlab.unittest.TestCase' ) && ...
    isscalar( testCase ) && isvalid( testCase ), ...
    'DisableTracking:InvalidTestCase', ...
    'First input must be a valid scalar TestCase instance.' )

% Store the current tracking status.
testCase.CurrentTrackingStatus = uix.tracking( 'query' );

% Disable tracking for the duration of the tests.
uix.tracking( 'off' )
testCase.addTeardown( @restoreTrackingStatus )

    function restoreTrackingStatus()

        uix.tracking( testCase.CurrentTrackingStatus )
        testCase.CurrentTrackingStatus = 'unset';

    end % restoreTrackingStatus

end % disableTracking