classdef tGrid < utilities.mixin.SharedGridTests
    %TGRID Tests for uiextras.Grid.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uiextras.Grid'}
        % Name-value pair arguments to use when testing the component's
        % constructor and get/set methods.
        NameValuePairs = {{
            'BackgroundColor', [0, 0, 1], ...
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Padding', 5, ...
            'Spacing', 5, ...
            'Tag', 'test' ...
            'Visible', 'on', ...
            'RowSizes', double.empty( 0, 1 ), ...
            'ColumnSizes', double.empty( 0, 1 ), ...
            'MinimumRowSizes', double.empty( 0, 1 ), ...
            'MinimumColumnSizes', double.empty( 0, 1 ), ...
            'Widths', double.empty( 0, 1 ), ...
            'Heights', double.empty( 0, 1 ), ...
            'MinimumWidths', double.empty( 0, 1 ), ...
            'MinimumHeights', double.empty( 0, 1 )
            }}
    end % properties ( TestParameter )

    properties ( Constant )
        % Grid dimension name-value pairs used when testing the component's
        % get/set methods.
        GridDimensionNameValuePairs = {{
            'RowSizes', [-10, -1, 20], ...
            'ColumnSizes', [-0.5, 50], ...
            'MinimumRowSizes', [2, 2, 2], ...
            'MinimumColumnSizes', [2, 2], ...
            'Heights', [-10, -1, 20], ...
            'Widths', [-0.5, 50], ...
            'MinimumHeights', [2, 2, 2], ...
            'MinimumWidths', [2, 2]
            }}
    end % properties ( Constant )

end % class