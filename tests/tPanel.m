classdef tPanel < sharedtests.SharedContainerTests
    %TPANEL Tests for uiextras.Panel and uix.Panel.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uiextras.Panel', 'uix.Panel'}
        % Name-value pair arguments to use when testing the component's
        % constructor and get/set methods.
        NameValuePairs = panelNameValuePairs()
    end % properties ( TestParameter )    

end % classdef

function nvp = panelNameValuePairs()
%PANELNAMEVALUEPAIRS Define name-value pairs common to both uiextras.Panel
%and uix.Panel.

commonNameValuePairs = {
    'BackgroundColor', [1, 1, 0], ...
    'BorderType', 'line', ...
    'ButtonDownFcn', @glttestutilities.noop, ...
    'CreateFcn', @glttestutilities.noop, ...
    'DeleteFcn', @glttestutilities.noop, ...
    'FontAngle', 'normal', ...
    'FontName', 'Monospaced', ...
    'FontUnits', 'pixels', ...
    'FontSize', 20, ...
    'FontWeight', 'bold', ...
    'ForegroundColor', [0, 0, 0], ...
    'HighlightColor', [1, 1, 1], ...
    'HandleVisibility', 'on', ...
    'Padding', 5, ...
    'Tag', 'Test', ...
    'Units', 'pixels', ...
    'Position', [10, 10, 400, 400], ...
    'Visible', 'on'
    };
nvp = {commonNameValuePairs, commonNameValuePairs};

end % panelNameValuePairs