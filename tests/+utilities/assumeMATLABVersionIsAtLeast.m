function assumeMATLABVersionIsAtLeast( testCase, versionString )
%ASSUMEMATLABVERSIONISATLEAST Assume that the MATLAB version is at least
%the version specified by versionString. This assumption is used in
%different locations across the test suite.

% Error-checking.
assert( isa( testCase, 'matlab.unittest.TestCase' ) && ...
    isscalar( testCase ) && isvalid( testCase ), ...
    'AssumeMATLABVersionIsAtLeast:InvalidTestCase', ...
    'First input must be a valid scalar TestCase instance.' )
assert( ischar( versionString ) && ...
    ismember( versionString, {'R2014b', 'R2022a'} ), ...
    'AssumeMATLABVersionIsAtLeast:InvalidVersionString', ...
    'Unsupported version string %s.', versionString )

% Determine the version number corresponding to the version specified.
switch versionString
    case 'R2014b'
        versionNumber = '8.4';
    case 'R2022a'
        versionNumber = '9.12';
end % switch/case

% Enforce that a minimum MATLAB version is required.
testCase.assumeFalse( ...
    verLessThan( 'matlab', versionNumber ), ...
    ['This test is not applicable prior to MATLAB ', versionString, '.'] )

end % assumeMATLABVersionIsAtLeast