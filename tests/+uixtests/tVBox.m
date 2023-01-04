classdef tVBox < utilities.mixin.SharedBoxTests
    %TVBOX Tests for uix.VBox.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uix.VBox'}
        % Name-value pair arguments to use when testing the component's
        % constructor and get/set methods.
        NameValuePairs = {{
            'BackgroundColor', [0, 0, 1], ...
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Padding', 5, ...
            'Spacing', 5, ...
            'Tag', 'test', ...
            'Visible', 'on', ...
            'Heights', double.empty( 0, 1 ), ...
            'MinimumHeights', double.empty( 0, 1 )
            }}
    end % properties ( TestParameter )

    properties ( Constant )
        % Box dimension name-value pairs used when testing the component's
        % get/set methods.
        BoxDimensionNameValuePairs = {
            'Heights', [-1, -2, 100, -1], ...
            'MinimumHeights', [0, 1, 2, 0]
            }
    end % properties ( Constant )

end % class

