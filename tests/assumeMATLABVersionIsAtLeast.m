function assumeMATLABVersionIsAtLeast( testCase, versionString )
%ASSUMEMATLABVERSIONISATLEAST Assume that the MATLAB version is at least
%the version specified by versionString. This assumption is used in 
%different locations across the test suite.

% Determine the version number and diagnostic text depending
% the version specified.
switch versionString
    case 'R2014b'
        versionNumber = '8.4';
        diagnosticText = 'prior to MATLAB ';
    case 'R2022a'
        versionNumber = '9.12';
        diagnosticText = 'to web graphics prior to MATLAB ';
    otherwise
        error( 'ContainerSharedTests:UnsupportedVersion', ...
            'Unsupported version: %s.', versionString )
end % switch/case

% Enforce that a minimum MATLAB version is required.
testCase.assumeFalse( ...
    verLessThan( 'matlab', versionNumber ), ...
    ['Test not applicable ', diagnosticText, ...
    versionString, '.'] )

end % assumeMATLABVersionIsAtLeast