classdef tButtonBox < ContainerSharedTests
    %THBUTTONBOX Unit tests for uiextras.HButtonBox and uiextras.VButtonBox.
    % sets ButtonBox specific parameters for ContainerSharedTests. 
    % No extra tests are added.
    
     properties (TestParameter)
        ContainerType = {
            'uiextras.HButtonBox'
            'uiextras.VButtonBox'
            };
        SpecialConstructionArgs = {
            {'uiextras.HButtonBox'}
            {'uiextras.VButtonBox'}
            };
        GetSetPVArgs  = {
            {'uiextras.HButtonBox', 'BackgroundColor', [0 1 0], 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top'}
            {'uiextras.VButtonBox', 'BackgroundColor', [0 1 0], 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top'}
            };
    end
    
    properties
        DefaultConstructionArgs = {
            'BackgroundColor', [0 0 1], ...
            'Units',           'pixels', ...
            'Position',        [10 10 400 400], ...
            'Padding',         5, ...
            'Spacing',         5, ...
            'Tag',             'test', ...
            'Visible',         'on', ...
            'ButtonSize', [200 25] ...
            };
    end
    

end

