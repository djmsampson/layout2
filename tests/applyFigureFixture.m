function applyFigureFixture( testCase, ParentType )
%APPLYFIGUREFIXTURE Apply a custom fixture to provide the top-level parent
%graphics object for the GUI Layout Toolbox components during the test
%procedures.
%
% See also parentTypes, matlab.unittest.fixtures.FigureFixture

% Error-checking.
assert( isa( testCase, 'matlab.unittest.TestCase' ) && ...
    isscalar( testCase ) && isvalid( testCase ), ...
    'ApplyFigureFixture:InvalidTestCase', ...
    'First input must be a valid scalar TestCase instance.' )

if strcmp( ParentType, 'web' )
    % Filter all tests using a web figure graphics parent,
    % unless the MATLAB version supports the creation of
    % uicontrol objects in web figures.
    assumeMATLABVersionIsAtLeast( testCase, 'R2022a' )
end % if

% Create the figure fixture using the corresponding parent
% type.
figureFixture = matlab.unittest.fixtures.FigureFixture( ParentType );
testCase.FigureFixture = testCase.applyFixture( figureFixture );

end % applyFigureFixture