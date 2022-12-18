classdef tTabPanel < PanelTests & ContainerSharedTests
    %TTABPANEL Tests for uiextras.TabPanel.

    properties ( TestParameter )
        % The container type (constructor name).
        ContainerType = {'uiextras.TabPanel'}
        % Name-value pairs to use when testing the get/set methods.
        GetSetArgs  = {{
            'BackgroundColor', [1, 1, 0], ...
            'SelectedChild', 2, ...
            'TabNames', {'Tab 1', 'Tab 2', 'Empty', 'Tab 3'}, ...
            'TabEnable', {'on', 'off', 'on', 'on'}, ...
            'TabPosition', 'bottom', ...
            'TabSize', 10, ...
            'ForegroundColor', [1, 1, 1], ...
            'HighlightColor', [1, 0, 1], ...
            'ShadowColor', [0, 0, 0], ...
            'FontAngle', 'normal', ...
            'FontName', 'SansSerif', ...
            'FontSize', 20, ...
            'FontUnits', 'points', ...
            'FontWeight', 'bold'
            }}
        % Name-value pairs to use when testing the constructor.
        ConstructorArgs = {{
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Padding', 5, ...
            'Tag', 'Test', ...
            'Visible', 'on', ...
            'FontAngle', 'normal', ...
            'FontName', 'SansSerif', ...
            'FontSize', 20, ...
            'FontUnits', 'points', ...
            'FontWeight', 'bold'
            }}
        % Different ways to specify callbacks.
        ValidCallbacks = struct( ...
            'fcnString', '@()disp(''function as string'');', ...
            'fcnAnonHandle', @()disp('function as anon handle'), ...
            'fcnHandle', @tTabPanel.selectionChangedCallback, ...
            'fcnCell', {{@()disp, 'function as cell'}} )
    end % properties ( TestParameter )

    properties
        selectionChangedCallbackCalled = false;
    end

    methods (Test)

        function testTabPanelCallbacks(testcase, ContainerType, ValidCallbacks)
            [obj, ~] = testcase.hBuildRGBBox(ContainerType);
            set(obj, 'Callback', ValidCallbacks);

            testcase.verifyEqual(get(obj, 'Callback'), ValidCallbacks);
        end

        function testTabPanelGetSetOnSelectionChanged(testcase, ContainerType, ValidCallbacks)
            [obj, ~] = testcase.hBuildRGBBox(ContainerType);
            set(obj, 'SelectionChangedFcn', ValidCallbacks);

            testcase.verifyEqual(get(obj, 'SelectionChangedFcn'), ValidCallbacks);
        end

        function testTabPanelOnSelectionChangedCallbackExecutes(testcase, ContainerType)
            [obj, ~] = testcase.hBuildRGBBox(ContainerType);

            % MATLAB did not correctly set callbacks when defined as a test
            % parameter.
            callbackCell = {...
                @(varargin)testcase.selectionChangedCallback, ...
                @testcase.selectionChangedCallback, ...
                {@testcase.selectionChangedCallback, 2, 3 ,4} ...
                };

            for i = 1:numel(callbackCell)
                % set new callback
                set(obj, 'SelectionChangedFcn', callbackCell{i});
                % change selection
                obj.Selection = 3;
                % check callback executed
                testcase.verifyTrue(testcase.selectionChangedCallbackCalled);
                % reset selection and successflag
                obj.Selection = 1;
                testcase.selectionChangedCallbackCalled = false;
            end
        end

        function testContextMenuReparents(testcase)
            % test for g1250808 where reparenting a tab panel to a
            % different figure causes the context menus to be orphaned.
            testcase.assumeRooted()

            fx1 = testcase.applyFixture(FigureFixture(testcase.parentStr));
            f = fx1.FigureHandle;

            obj = uix.TabPanel( 'Parent', f );
            obj.Position = [0.1 0.1 0.8 0.8];
            for ii = 1:3
                uicontrol( 'Parent', obj );
            end
            % Create a context menu
            contextMenu = uicontextmenu( 'Parent', f );
            uimenu( 'Parent', contextMenu, 'Label', 'Red' );
            uimenu( 'Parent', contextMenu, 'Label', 'Green' );
            uimenu( 'Parent', contextMenu, 'Label', 'Blue' );
            obj.TabContextMenus{2} = contextMenu;
            % Reparent to a new figure
            fx2 = testcase.applyFixture(FigureFixture(testcase.parentStr));
            g = fx2.FigureHandle;

            obj.Parent = g;
            testcase.verifyEqual( contextMenu.Parent, g );
            % Unparent
            obj.Parent = [];
            testcase.verifyEmpty( contextMenu.Parent );
            % Reparent within the current figure
            u = uix.TabPanel( 'Parent', g, 'TabLocation', 'bottom' );
            obj.Parent = u;
            testcase.verifyEqual( contextMenu.Parent, g );

        end

        function testRotate3dDoesNotAddMoreTabs(testcase)
            % test for g1129721 where rotating an axis in a panel causes
            % the axis to lose visibility.
            testcase.assumeRooted()
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            obj = uiextras.TabPanel('Parent',fx.FigureHandle);
            con = uicontainer('Parent', obj);
            axes('Parent', con, 'Visible', 'on');
            testcase.verifyNumElements(obj.TabTitles, 1);
            % equivalent of selecting the rotate button on figure window:
            rotate3d;
            testcase.verifyNumElements(obj.TabTitles, 1);
        end

        function testSelectionBehaviourNewChild(testcase)
            % g1342432 Tests that adding a new child doesn't change current selection
            testcase.assumeRooted() % TODO review
            % Create a TabPanel with two tabs
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            tp = uix.TabPanel('Parent',fx.FigureHandle);
            c1 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'r' );
            c2 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'g' );
            % Store the selection
            oldSelection = tp.Selection;
            % Add new tab
            c3 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'b' );

            testcase.verifyEqual(oldSelection, tp.Selection);
        end

        function testSelectionBehaviourDeleteLowerChild(testcase)
            % g1342432 Tests that deleting a child with a lower index than the
            % current selection causes the selection index to decrease by 1
            testcase.assumeRooted() % TODO review
            % Create a TabPanel with three tabs
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            tp = uix.TabPanel('Parent',fx.FigureHandle);
            c1 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'r' );
            c2 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'g' );
            c3 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'b' );
            % Select the 2nd child, then delete the first
            tp.Selection = 2;
            oldSelection = tp.Selection;
            delete(c1)

            testcase.verifyEqual(oldSelection - 1, tp.Selection);
        end

        function testSelectionBehaviourDeleteSelectedChild(testcase)
            % g1342432 Tests that deleting the currently selected child
            % causes the selection index to stay the same.
            testcase.assumeRooted() % TODO review
            % Create a TabPanel with three tabs
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            tp = uix.TabPanel('Parent',fx.FigureHandle);
            c1 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'r' );
            c2 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'g' );
            c3 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'b' );
            % Select the 2nd child, then delete the 1st
            tp.Selection = 2;
            oldSelection = tp.Selection;
            delete(c2)

            testcase.verifyEqual(oldSelection, tp.Selection);
        end

        function testSelectionBehaviourDeleteOnlyChild(testcase)
            % g1342432 Tests that deleting the only child
            % causes the selection index to go to 0.
            testcase.assumeRooted() % TODO review
            % Create a TabPanel with a signel tab
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            tp = uix.TabPanel('Parent',fx.FigureHandle);
            c1 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'r' );
            % Ensure that the 1st child is selected.
            tp.Selection = 1;
            delete(c1)

            testcase.verifyEqual(0, tp.Selection);
        end

        function testSelectionBehaviourDeleteHigherChild(testcase)
            % g1342432 Tests that deleting a child with a higher index than the
            % current selection causes the selection index remain same.

            testcase.assumeRooted() % TODO review

            % Create a TabPanel with three tabs
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            tp = uix.TabPanel('Parent',fx.FigureHandle);
            c1 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'r' );
            c2 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'g' );
            c3 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'b' );
            % Select the 2nd child, then delete the 3rd
            tp.Selection = 2;
            oldSelection = tp.Selection;
            delete(c3)

            testcase.verifyEqual(oldSelection, tp.Selection);
        end

        function testSelectionBehaviourDisableSelectedChild(testcase)
            % g1342432 Tests that disabling a child which is selected won't stop it
            % being selected.

            testcase.assumeRooted() % TODO review
            % Create a TabPanel with three tabs
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            tp = uix.TabPanel('Parent',fx.FigureHandle);

            c1 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'r' );
            c2 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'g' );
            c3 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'b' );
            % Select the 2nd child, then disable it
            tp.Selection = 2;
            oldSelection = tp.Selection;
            tp.TabEnables{2}='off';

            testcase.verifyEqual(oldSelection, tp.Selection);
        end

        function testSelectionBehaviourDisableNonSelectedChild(testcase)
            % g1342432 Tests that disabling a non-selected child doesn't change
            % selection
            testcase.assumeRooted() % TODO review
            % Create a TabPanel with three tabs
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            tp = uix.TabPanel('Parent',fx.FigureHandle);
            c1 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'r' );
            c2 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'g' );
            c3 = uicontrol( 'Style', 'frame', 'Parent', tp, 'Background', 'b' );
            % Select the 1st child, then disable the second
            tp.Selection = 1;
            oldSelection = tp.Selection;
            tp.TabEnables{2}='off';

            testcase.verifyEqual(oldSelection, tp.Selection);
        end

        function testParentBackgroundColor(testcase)
            % g1380756 Test to make sure that the some elements match the
            % parent (background)color
            testcase.assumeRooted() % TODO review
            % Create
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            fig = fx.FigureHandle;
            tabs = uiextras.TabPanel( 'Parent', fig );
            c1 = uix.Panel( 'Parent', tabs, 'BackgroundColor', rand( 1, 3 ) );
            c2 = uix.Panel( 'Parent', tabs, 'BackgroundColor', rand( 1, 3 ) );

            % Get the divider
            children = hgGetTrueChildren( tabs );
            dividers = findobj( children, 'Tag', 'TabPanelDividers' );

            checkDividersBackgroundColor( testcase, dividers, fig.Color );

            % Change figure color
            fig.Color = [1 0 0];
            checkDividersBackgroundColor( testcase, dividers, fig.Color );

            % Reparent
            container = uix.VBox( 'BackgroundColor', [0 1 0], 'Parent', fig );
            tabs.Parent = container;
            checkDividersBackgroundColor( testcase, dividers, container.BackgroundColor );

            % Change container's color
            container.BackgroundColor = [0 0 1];
            checkDividersBackgroundColor( testcase, dividers, container.BackgroundColor );

            % Nested
            function checkDividersBackgroundColor( testcase, dividers, color )
                % Check both CData and BackgroundColor
                testcase.verifyEqual( color, dividers.BackgroundColor,...
                    'The divider BackgroundColor does not match.' );
                testcase.verifyEqual( color, permute( dividers.CData(1, 1, :), [1 3 2] ),...
                    'The divider CData (mask) does not match.' );
            end
        end

    end

    methods (Access = private)
        function selectionChangedCallback(src, varargin)
            src.selectionChangedCallbackCalled = true;
        end
    end

end