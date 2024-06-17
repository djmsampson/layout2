classdef tVButtonBox < sharedtests.SharedButtonBoxTests
    %TVBUTTONBOX Tests for uiextras.VButtonBox and uix.VButtonBox.
    
    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uiextras.VButtonBox', 'uix.VButtonBox'}
        % Name-value pair arguments to use when testing the component's
        % constructor and get/set methods.
        NameValuePairs = vButtonBoxNameValuePairs()
    end % properties ( TestParameter )   
   
end % classdef

function nvp = vButtonBoxNameValuePairs()
%VBUTTONBOXNAMEVALUEPAIRS Define name-value pairs common to both
%uiextras.VButtonBox and uix.VButtonBox.

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

end % vButtonBoxNameValuePairs