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
        % Possible ways in which to specify a callback.
        Callback = struct( ...
            'StringCallback', ...
            '@() disp( ''String callback'' )', ...
            'FunctionHandleCallback', ...
            @() disp( 'Function handle callback' ), ...
            'CellArrayCallback', ...
            {{@disp, 'Cell array callback'}} )
    end % properties ( TestParameter )

    methods ( Test )

        function tSettingTabPanelCallbackStoresValue( testCase, Callback )

            % Create a tab panel.
            tabPanel = testCase.createTabPanel();

            % Set the 'Callback' property.
            tabPanel.Callback = Callback;

            % Verify that the value has been stored.
            testCase.verifyEqual( tabPanel.Callback, Callback, ...
                ['uiextras.TabPanel has not stored the ', ...
                '''Callback'' property correctly.'] )

        end % tSettingTabPanelCallbackStoresValue

        function tSettingInvalidCallbackThrowsError( testCase )

            % Create a tab panel.
            tabPanel = testCase.createTabPanel();

            % Verify that setting the 'Callback' property to an invalid
            % value causes an error with ID
            % 'uiextras:InvalidPropertyValue'.
            invalidSetter = @() set( tabPanel, 'Callback', 0 );
            testCase.verifyError( invalidSetter, ...
                'uiextras:InvalidPropertyValue', ...
                ['The TabPanel has not thrown an error with ID ', ...
                '''uiextras:InvalidPropertyValue'' when its ', ...
                '''Callback'' property was set to an invalid value.'] )

        end % tSettingInvalidCallbackThrowsError

        function tSettingTabPanelSelectionChangedFcnStoresValue( ...
                testCase, Callback )

            % Create a tab panel.
            tabPanel = testCase.createTabPanel();

            % Set the 'SelectionChangedFcn' property.
            tabPanel.SelectionChangedFcn = Callback;

            % Verify that the value has been stored.
            testCase.verifyEqual( tabPanel.SelectionChangedFcn, ...
                Callback, ...
                ['uiextras.TabPanel has not stored the ', ...
                '''SelectionChangedFcn'' property correctly.'] )

        end % tSettingTabPanelSelectionChangedFcnStoresValue

        function tTabPanelSelectionChangedFcnIsInvoked( testCase )

            % Create a tab panel.
            tabPanel = testCase.createTabPanel();

            % Add content to the tab panel.
            uicontrol( tabPanel )
            uicontrol( tabPanel )

            % Set the 'SelectionChangedFcn' callback.
            callbackInvoked = false;
            tabPanel.SelectionChangedFcn = @( s, e ) onSelectionChanged();

            % Change the selection.
            tabPanel.Selection = 2;

            % Verify that the callback was invoked.
            testCase.verifyTrue( callbackInvoked, ...
                ['uiextras.TabPanel did not invoke the ', ...
                '''SelectionChangedFcn'' callback when the ', ...
                '''Selection'' property was changed.'] )

            % Restore the selection.
            tabPanel.Selection = 1;
            callbackInvoked = false;

            % Cover other callback options.
            callbackOptions = {'uiextrastests.noop', ...
                @uiextrastests.noop, ...
                {@uiextrastests.noop}};
            
            for callback = callbackOptions
                % Assign the callback.
                tabPanel.Callback = callback{1};
                % Verify that invoking it is warning-free.
                selectionSetter = @() set( tabPanel, 'Selection', 2 );
                testCase.verifyWarningFree( selectionSetter, ...
                    ['The TabPanel issued a warning when its ', ...
                    '''SelectionChangedFcn'' callback was changed.'] )
                % Restore the selection.
                tabPanel.Selection = 1;
            end % for

            function onSelectionChanged()

                callbackInvoked = true;

            end % onSelectionChanged

        end % tTabPanelSelectionChangedFcnIsInvoked

        function tContextMenuIsReparentedWhenTabPanelIsReparented( ...
                testCase )

            % Filter the unrooted case.
            testCase.assumeRooted()

            % Create a tab panel.
            tabPanel = testCase.createTabPanel();
            testFig = tabPanel.Parent;

            % Add controls.
            for c = 1:3
                uicontrol( 'Parent', tabPanel )
            end % for

            % Create a context menu.
            contextMenu = uicontextmenu( 'Parent', testFig );
            uimenu( 'Parent', contextMenu, 'Text', 'Test Menu' )

            % Attach the context menu to the second tab.
            tabPanel.TabContextMenus{2} = contextMenu;

            % Create a new figure parent.
            if isempty( testFig.Number )
                newFig = uifigure();
            else
                newFig = figure();
            end % if
            testCase.addTeardown( @() delete( newFig ) )

            % Reparent the tab panel.
            tabPanel.Parent = newFig;

            % Verify that the context menu has been reparented.
            testCase.verifySameHandle( contextMenu.Parent, newFig, ...
                ['Reparenting a uiextras.TabPanel component with an ', ...
                'existing context menu has not reparented the ', ...
                'context menu.'] )

            % Unparent the tab panel.
            tabPanel.Parent = [];

            % Verify that the context menu has also been unparented.
            testCase.verifyEmpty( contextMenu.Parent, ...
                ['Unparenting a uiextras.TabPanel component with an ', ...
                'existing context menu has not unparented the ', ...
                'context menu.'] )

            % Reparent the tab panel.
            tabPanel.Parent = testFig;

            % Verify that the context menu has been reparented.
            testCase.verifySameHandle( contextMenu.Parent, testFig, ...
                ['Reparenting a uiextras.TabPanel component with an ', ...
                'existing context menu has not reparented the ', ...
                'context menu.'] )

        end % tContextMenuIsReparentedWhenTabPanelIsReparented

        function tRotate3dDoesNotAddMoreTabs( testCase )

            % Filter the unrooted case.
            testCase.assumeRooted()

            % Create a tab panel.
            tabPanel = testCase.createTabPanel();

            % Add an axes to the tab panel.
            ax = axes( 'Parent', tabPanel );
            testCase.addTeardown( @() delete( ax ) )

            % Verify that the number of elements in the tab group is 1.
            testCase.verifyNumElements( tabPanel.TabTitles, 1, ...
                ['Adding an axes to a uiextras.TabPanel component ', ...
                'has not resulted in one element in the tab group.'] )

            % Enable 3d rotation mode.
            rotate3d( ax, 'on' )

            % Verify that the number of elements in the tab group is 1.
            testCase.verifyNumElements( tabPanel.TabTitles, 1, ...
                ['Adding an axes to a uiextras.TabPanel component ', ...
                'has not resulted in one element in the tab group.'] )

        end % tRotate3dDoesNotAddMoreTabs

        function tDeletingChildrenSetsSelectionToZero( testCase )

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls();

            % Delete all the children.
            delete( tabPanel.Children )

            % Verify that the 'Selection' property is equal to 0.
            testCase.verifyEqual( tabPanel.Selection, 0, ...
                ['The ''Selection'' property of the TabPanel ', ...
                'was not set to 0 when all the children of the ', ...
                'TabPanel were deleted.'] )

        end % tDeletingChildrenSetsSelectionToZero

        function tAddingChildPreservesSelection( testCase )

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls();

            % Verify that the first control is selected.
            testCase.verifyEqual( tabPanel.Selection, 1, ...
                ['The TabPanel has not preserved its ', ...
                '''Selection'' property when a new child was added.'] )

        end % tAddingChildIncrementsSelection

        function tDeletingLowerIndexChildDecrementsSelection( testCase )

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls();

            % Select the second child, record the current selection, then
            % delete the first child.
            tabPanel.Selection = 2;
            currentSelection = tabPanel.Selection;
            delete( tabPanel.Children(3) )

            % Test that deleting a child with a lower index than the
            % current selection causes the selection index to decrease by
            % 1.
            testCase.verifyEqual( tabPanel.Selection, ...
                currentSelection - 1, ...
                ['The TabPanel has not correctly updated its ', ...
                '''Selection'' property when a child with a lower ', ...
                'index than the current selection was deleted.'] )

        end % tDeletingLowerIndexChildDecrementsSelection

        function tDeletingSelectedChildPreservesSelection( testCase )

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls();

            % Select the second child, record the current selection, then
            % delete the second child.
            tabPanel.Selection = 2;
            currentSelection = tabPanel.Selection;
            delete( tabPanel.Children(2) )

            % Verify that the 'Selection' property has remained the same.
            testCase.verifyEqual( tabPanel.Selection, ...
                currentSelection, ...
                ['The ''Selection'' property of the TabPanel ', ...
                'has not remained the same when the current child ', ...
                'was deleted (and the current child was not the ', ...
                'highest index child).'] )

        end % tDeletingSelectedChildPreservesSelection

        function tDeletingHigherIndexChildPreservesSelection( testCase )

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls();

            % Select the second child, record the current selection, and
            % delete the third child.
            tabPanel.Selection = 2;
            currentSelection = tabPanel.Selection;
            delete( tabPanel.Children(1) )

            % Verify that the 'Selection' property has remained the same.
            testCase.verifyEqual( tabPanel.Selection, ...
                currentSelection, ...
                ['The ''Selection'' property of the TabPanel ', ...
                'has not remained the same when a higher index child ', ...
                'was deleted (and the current child was not the ', ...
                'highest index child).'] )

        end % tDeletingHigherIndexChildPreservesSelection

        function tDisablingSelectedChildPreservesSelection( testCase )

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls();

            % Select the second child, record the current selection, then
            % disable the second child.
            tabPanel.Selection = 2;
            currentSelection = tabPanel.Selection;
            tabPanel.TabEnables{2} = 'off';

            % Verify that the 'Selection' property has been preserved.
            testCase.verifyEqual( tabPanel.Selection, ...
                currentSelection, ...
                ['Disabling the selected child of a TabPanel ', ...
                'has not preserved the ''Selection'' property.'] )

        end % tDisablingSelectedChildPreservesSelection

        function tDisablingNonSelectedChildPreservesSelection( testCase )

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls();

            % Select the first child, record the current selection, then
            % disable the second child.
            tabPanel.Selection = 1;
            currentSelection = tabPanel.Selection;
            tabPanel.TabEnables{2} = 'off';

            % Verify that the 'Selection' property has been preserved.
            testCase.verifyEqual( tabPanel.Selection, ...
                currentSelection, ...
                ['Disabling a non-selected child of a TabPanel ', ...
                'has not preserved the ''Selection'' property.'] )

        end % tDisablingNonSelectedChildPreservesSelection

        function tTabPanelRespectsParentColor( testCase )

            % Assume that the component is rooted.
            testCase.assumeRooted()

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls();
            testFig = tabPanel.Parent;

            % Identify the tab panel dividers.
            allChildren = hgGetTrueChildren( tabPanel );
            dividers = findobj( allChildren, 'Tag', 'TabPanelDividers' );

            % Verify their 'CData' and 'BackgroundColor' properties.
            verifyDividersCDataAndBackgroundColor( testFig.Color )

            % Next, change the figure's color, and re-check the dividers'
            % 'CData' and 'BackgroundColor' properties.
            testFig.Color = [1, 0, 0];
            verifyDividersCDataAndBackgroundColor( testFig.Color )

            % Next, reparent the tab panel, and re-check the color-related
            % properties.
            newColor = [0, 1, 0];
            newContainer = uix.VBox( 'Parent', testFig, ...
                'BackgroundColor', newColor );
            tabPanel.Parent = newContainer;
            verifyDividersCDataAndBackgroundColor( newColor )

            % Change the new container's 'BackgroundColor' property.
            newColor = [0, 0, 1];
            newContainer.BackgroundColor = newColor;
            verifyDividersCDataAndBackgroundColor( newColor )

            function verifyDividersCDataAndBackgroundColor( targetColor )

                % Check the 'BackgroundColor' property.
                testCase.verifyEqual( dividers.BackgroundColor, ...
                    targetColor, ...
                    ['The TabPanel''s divider''s ''BackgroundColor'' ', ...
                    'does not match its Parent''s ''BackgroundColor''.'] )
                % Check the 'CData' property.
                dividersCData = permute( ...
                    dividers.CData(1, 1, :), [1, 3, 2] );
                testCase.verifyEqual( dividersCData, targetColor, ...
                    ['The TabPanel''s divider''s ''CData'' ', ...
                    'does not match its Parent''s ''CData''.'] )

            end % verifyDividersCDataAndBackgroundColor

        end % tTabPanelRespectsParentColor

    end % methods ( Test )

    methods ( Access = private )

        function tabPanel = createTabPanel( testCase )

            % Create a tab panel.
            testFig = testCase.FigureFixture.Figure;
            tabPanel = uiextras.TabPanel( 'Parent', testFig );
            testCase.addTeardown( @() delete( tabPanel ) )

        end % createTabPanel

        function tabPanel = createTabPanelWithControls( testCase )

            % Create a TabPanel with three controls.
            tabPanel = testCase.createTabPanel();
            uicontrol( 'Parent', tabPanel, ...
                'Style', 'frame', ...
                'BackgroundColor', 'r' )
            uicontrol( 'Parent', tabPanel, ...
                'Style', 'frame', ...
                'BackgroundColor', 'g' )
            uicontrol( 'Parent', tabPanel, ...
                'Style', 'frame', ...
                'BackgroundColor', 'b' )

        end % createTabPanelWithControls

    end % methods ( Access = private )

end % class