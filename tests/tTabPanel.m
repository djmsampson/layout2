classdef tTabPanel  < ContainerSharedTests ...
        & PanelTests ...
        & SelectablePanelTests
    %TTABPANEL unit tests for uiextras.TabPanel
    
    properties (TestParameter)
        ContainerType = {'uiextras.TabPanel'};
        GetSetArgs  = {{
            'BackgroundColor',     [1 1 0], ...
            'SelectedChild',       2, ...
            'TabNames',            {'Tab 1', 'Tab 2', 'Tab 3'}, ...
            'TabEnable',           {'on', 'off', 'on'}, ...
            'TabPosition',         'bottom', ...
            'TabSize',             10, ...
            'ForegroundColor',     [1 1 1], ...
            'HighlightColor',      [1 0 1], ...
            'ShadowColor',         [0 0 0]
            }};
        ConstructionArgs = {{
            'Units',           'pixels', ...
            'Position',        [10 10 400 400], ...
            'Padding',         5, ...
            'Tag',             'Test', ...
            'Visible',         'on', ...
            'FontAngle',   'normal', ...
            'FontName',    'Arial', ...
            'FontSize',    20, ...
            'FontUnits',   'points', ...
            'FontWeight',  'bold'
            }};
    end
    
    
    methods (Test)
        
        function testTabPanelCallbacks(testcase)
            [obj, ~] = testcase.hBuildRGBBox('uiextras.TabPanel');
            prop = 'SelectionChangedFcn';
            cb1  = '@()disp(''function as string'');';
            cb2  = @()disp('function as anon handle');
            cb3  = {@()disp, 'function as cell'};
            cb4  = 2; % tests for invalid callback
            % cb5  = 'this should error but doesn''t';
            
            set(obj, prop, cb1);
            testcase.verifyEqual(get(obj, prop), cb1);
            set(obj, prop, cb2);
            testcase.verifyEqual(get(obj, prop), cb2);
            set(obj, prop, cb3);
            testcase.verifyEqual(get(obj, prop), cb3);
            testcase.verifyError(@()set(obj, prop, cb4), 'uix:InvalidPropertyValue');
        end
        
        function testRotate3dDoesNotAddMoreTabs(testcase)
            % test for g1129721 where rotating an axis in a panel causes
            % the axis to lose visibility.
            obj = uiextras.TabPanel();
            con = uicontainer('Parent', obj);
            ax = axes('Parent', con, 'Visible', 'on');
            testcase.verifyNumElements(obj.TabTitles, 1);
            % equivalent of selecting the rotate button on figure window:
            rotate3d;
            testcase.verifyNumElements(obj.TabTitles, 1);
        end
    end
    
end

