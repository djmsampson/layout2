classdef tPanels < ContainerSharedTests
    %TPANELS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (TestParameter)
        ContainerType   = {'uiextras.Panel', 'uiextras.CardPanel', 'uiextras.TabPanel', 'uiextras.BoxPanel'};
        SelectablePanel = {'uiextras.Panel', 'uiextras.CardPanel', 'uiextras.TabPanel'};
        GetSetPVArgs = {
            {'uiextras.Panel', 'BackgroundColor', [1 1 0]}
            {'uiextras.CardPanel', 'BackgroundColor', [1 1 0], 'SelectedChild', 2}
            {'uiextras.TabPanel', ...
             'BackgroundColor',     [1 1 0], ...
             'SelectedChild',       2, ...
             'TabNames',            {'Tab 1', 'Tab 2', 'Tab 3'}, ...
             'TabEnable',           {'on', 'off', 'on'}, ...
             'TabPosition',         'bottom', ...
             'TabSize',             10, ...
             'ForegroundColor',     [1 1 1], ...
             'HighlightColor',      [1 0 1], ...
             'ShadowColor',         [0 0 0]
             }
            {'uiextras.BoxPanel', ...
            'BackgroundColor',  [1 1 0], ...
            'IsMinimized',      false, ...
             'IsDocked',        true, ...
             'BorderType',      'etchedout', ...
             'BorderWidth',     10, ...
             'Title',           'box panel test', ...
             'TitleColor',      [1 0 0], ...
             'ForegroundColor', [1 1 1], ...
             'HighlightColor',  [1 0 1], ...
             'ShadowColor',     [0 0 0]
             }
            };
        SpecialConstructionArgs = {
            {'uiextras.Panel', ...
             'FontAngle',   'normal', ...
             'FontName',    'Arial', ...
             'FontSize',    20, ...
             'FontUnits',   'points', ...
             'FontWeight',  'bold'
             }
            {'uiextras.CardPanel'}
            {'uiextras.TabPanel', ...
             'FontAngle',   'normal', ...
             'FontName',    'Arial', ...
             'FontSize',    20, ...
             'FontUnits',   'points', ...
             'FontWeight',  'bold'
             }
            {'uiextras.BoxPanel', ...
             'BorderType', 'etchedout', ...
             'FontAngle',   'normal', ...
             'FontName',    'Arial', ...
             'FontSize',    20, ...
             'FontUnits',   'points', ...
             'FontWeight',  'bold'
             }
            };
    end
    
    properties
        DefaultConstructionArgs = {
            'Units',           'pixels', ...
            'Position',        [10 10 400 400], ...
            'Padding',         5, ...
            'Tag',             'Test', ...
            'Visible',         'on', ...
            };
    end
    
    methods (Test)
        function testSelectablePanelContents(testcase, SelectablePanel)
            %testChildren  Test adding and removing children
            [obj, actualContents] = testcase.hBuildRGBBox(SelectablePanel);
            testcase.assertEqual( obj.Contents, actualContents );
            
            obj.Selection = 2;            
            % Make sure the "selected" child is visible
            testcase.verifyEqual(obj.Contents(2).Visible, 'on' );            
            % Make sure the "hidden" children are invisible
            testcase.verifyEqual(obj.Contents(1).Visible, 'off' );
            testcase.verifyEqual(obj.Contents(3).Visible, 'off' );
        end
        
        function testSelectablePanelGetSetSelection(testcase, SelectablePanel)
            objEmpty = testcase.hCreateObj(SelectablePanel);
            [obj3Children, ~] = testcase.hBuildRGBBox(SelectablePanel);
            prop = 'Selection';
            failSelectValues{1} = 2.4;
            failSelectValues{2} = int32(2);
            failSelectValues{3} = [2 3 4];
            
            for val = failSelectValues
                testcase.verifyError(@()set(objEmpty, prop, val), 'uix:InvalidPropertyValue');
                testcase.verifyError(@()set(obj3Children, prop, val), 'uix:InvalidPropertyValue');
            end
            set(objEmpty, prop, 0);
            testcase.verifyEqual(get(objEmpty, prop), 0);
            testcase.verifyError(@()set(objEmpty, prop, 3), 'uix:InvalidPropertyValue');
            
            set(obj3Children, prop, 3);
            testcase.verifyEqual(get(obj3Children, prop), 3);
        end
        
        function testLayoutInPanel(testcase, ContainerType)
            %testLayoutInTab  Test layout in panel
            obj = testcase.hCreateObj(ContainerType, {'Parent', gcf()});
            
            b = uiextras.HBox( 'Parent', obj );
            testcase.verifyEqual( obj.Contents, b );
        end
        
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

    end
    
end

