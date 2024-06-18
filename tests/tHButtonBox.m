classdef tHButtonBox < sharedtests.SharedButtonBoxTests
    %THBUTTONBOX Tests for uiextras.HButtonBox and uix.HButtonBox.
    
    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uiextras.HButtonBox', 'uix.HButtonBox'}
        % Name-value pair arguments to use when testing the component's
        % constructor and get/set methods.
        NameValuePairs = hButtonBoxNameValuePairs()
    end % properties ( TestParameter )
    
end % classdef

function nvp = hButtonBoxNameValuePairs()
%HBUTTONBOXNAMEVALUEPAIRS Define name-value pairs common to both
%uiextras.HButtonBox and uix.HButtonBox.

commonNameValuePairs = {
    'BackgroundColor', [0, 0, 1], ...
    'Units', 'pixels', ...
    'Position', [10, 10, 400, 400], ...
    'Padding', 5, ...
    'Spacing', 5, ...
    'Tag', 'test', ...
    'Visible', 'on', ...
    'ButtonSize', [200, 25], ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top'
    };
nvp = {commonNameValuePairs, commonNameValuePairs};

end % hButtonBoxNameValuePairs