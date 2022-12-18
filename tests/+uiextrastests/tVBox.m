classdef tVBox < VBoxTests & ContainerSharedTests
    %TVBOX Tests for uiextras.VBox.

    properties ( TestParameter )
        % The container type (constructor name).
        ContainerType = {'uiextras.VBox'}
        % Name-value pairs to use when testing the get/set methods.
        GetSetArgs = {{
            'Sizes', [-1, -2, 100, -1], ...
            'MinimumSizes', [0, 1, 2, 0]
            }}
        % Name-value pairs to use when testing the constructor.
        ConstructorArgs = {{
            'BackgroundColor', [0, 0, 1], ...
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Padding', 5, ...
            'Spacing', 5, ...
            'Tag', 'test', ...
            'Visible', 'on'
            }}
    end % properties ( TestParameter )

end % class