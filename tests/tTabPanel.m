classdef tTabPanel < sharedtests.SharedPanelTests
    %TTABPANEL Tests for uiextras.TabPanel.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uiextras.TabPanel', 'uix.TabPanel'}
        % Name-value pair arguments to use when testing the component's
        % constructor and get/set methods.
        NameValuePairs = {{
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Padding', 5, ...
            'Tag', 'Test', ...
            'Visible', 'on', ...
            'FontAngle', 'italic', ...
            'FontName', 'Helvetica', ...
            'FontUnits', 'centimeters', ...
            'FontSize', 0.5, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [1, 1, 0], ...
            'TabNames', cell.empty( 1, 0 ), ...
            'TabEnable', cell.empty( 1, 0 ), ...
            'TabPosition', 'top', ...
            'TabSize', 50, ...
            'ForegroundColor', [1, 1, 1], ...
            'HighlightColor', [1, 0, 1], ...
            'ShadowColor', [0, 0, 0], ...
            }, ...
            {
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Padding', 5, ...
            'Tag', 'Test', ...
            'Visible', 'on', ...
            'FontAngle', 'italic', ...
            'FontName', 'Helvetica', ...
            'FontUnits', 'centimeters', ...
            'FontSize', 0.5, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [1, 1, 0], ...
            'TabTitles', cell.empty( 0, 1 ), ...
            'TabEnables', cell.empty( 0, 1 ), ...
            'TabLocation', 'bottom', ...
            'TabWidth', 100, ...
            'ForegroundColor', [1, 1, 1], ...
            'HighlightColor', [1, 0, 1], ...
            'ShadowColor', [0, 0, 0], ...
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

    methods ( Test, Sealed )

        function tSettingTabPanelCallbackStoresValue( ...
                testCase, ConstructorName, Callback )

            % This test is just for uiextras.TabPanel.
            testCase.assumeComponentIsFromNamespace( ...
                ConstructorName, 'uiextras' )

            % Create a tab panel.
            tabPanel = testCase.constructComponent( ConstructorName );

            % Set the 'Callback' property.
            tabPanel.Callback = Callback;

            % Verify that the value has been stored.
            testCase.verifyEqual( tabPanel.Callback, Callback, ...
                [ConstructorName, ' has not stored the ', ...
                '''Callback'' property correctly.'] )

        end % tSettingTabPanelCallbackStoresValue

        function tSettingInvalidCallbackThrowsError( ...
                testCase, ConstructorName )

            % Create a tab panel.
            tabPanel = testCase.constructComponent( ConstructorName );

            % Verify that setting the 'Callback' or 'SelectionChangedFcn'
            % property to an invalid value causes an error with ID
            % 'uiextras:InvalidPropertyValue' or
            % 'uix:InvalidPropertyValue'.
            if strcmp( ConstructorName, 'uiextras.TabPanel' )
                propName = 'Callback';
                ID = 'uiextras:InvalidPropertyValue';
            else
                propName = 'SelectionChangedFcn';
                ID = 'uix:InvalidPropertyValue';
            end % if
            invalidSetter = @() set( tabPanel, propName, 0 );
            testCase.verifyError( invalidSetter, ID, ...
                ['The TabPanel has not thrown an error with ID ', ...
                '''', ID, ''' when its ''', propName, ''' property ', ...
                'was set to an invalid value.'] )

        end % tSettingInvalidCallbackThrowsError

        function tSettingTabPanelSelectionChangedFcnStoresValue( ...
                testCase, ConstructorName, Callback )

            % Create a tab panel.
            tabPanel = testCase.constructComponent( ConstructorName );

            % Set the 'SelectionChangedFcn' property.
            tabPanel.SelectionChangedFcn = Callback;

            % Verify that the value has been stored.
            testCase.verifyEqual( tabPanel.SelectionChangedFcn, ...
                Callback, ...
                [ConstructorName, ' has not stored the ', ...
                '''SelectionChangedFcn'' property correctly.'] )

        end % tSettingTabPanelSelectionChangedFcnStoresValue

        function tTabPanelSelectionChangedFcnIsInvoked( ...
                testCase, ConstructorName )

            % Create a tab panel.
            tabPanel = testCase.constructComponent( ConstructorName );

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
                [ConstructorName, ' did not invoke the ', ...
                '''SelectionChangedFcn'' callback when the ', ...
                '''Selection'' property was changed.'] )

            % Restore the selection.
            tabPanel.Selection = 1;
            callbackInvoked = false;

            % Cover other callback options.
            callbackOptions = {'glttestutilities.noop', ...
                @glttestutilities.noop, ...
                {@glttestutilities.noop}};

            for callback = callbackOptions
                % Assign the callback.
                if strcmp( ConstructorName, 'uiextras.TabPanel' )
                    tabPanel.Callback = callback{1};
                else
                    tabPanel.SelectionChangedFcn = callback{1};
                end % if
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
                testCase, ConstructorName )

            % Filter the unrooted case.
            testCase.assumeGraphicsAreRooted()

            % Create a tab panel.
            tabPanel = testCase.constructComponent( ConstructorName );
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
                ['Reparenting a ', ConstructorName, ...
                ' component with an existing context menu has ', ...
                'not reparented the context menu.'] )

            % Unparent the tab panel.
            tabPanel.Parent = [];

            % Verify that the context menu has also been unparented.
            testCase.verifyEmpty( contextMenu.Parent, ...
                ['Unparenting a ', ConstructorName, ...
                ' component with an existing context menu has ', ...
                'not unparented the context menu.'] )

            % Reparent the tab panel.
            tabPanel.Parent = testFig;

            % Verify that the context menu has been reparented.
            testCase.verifySameHandle( contextMenu.Parent, testFig, ...
                ['Reparenting a ', ConstructorName, ...
                ' component with an existing context menu has ', ...
                'not reparented the context menu.'] )

        end % tContextMenuIsReparentedWhenTabPanelIsReparented

        function tRotate3dDoesNotAddMoreTabs( testCase, ConstructorName )

            % Filter the unrooted case.
            testCase.assumeGraphicsAreRooted()

            % Create a tab panel.
            tabPanel = testCase.constructComponent( ConstructorName );

            % Add an axes to the tab panel.
            ax = axes( 'Parent', tabPanel );
            testCase.addTeardown( @() delete( ax ) )

            % Verify that the number of elements in the tab group is 1.
            testCase.verifyNumElements( tabPanel.TabTitles, 1, ...
                ['Adding an axes to a ', ConstructorName, ...
                ' component has not resulted in one element in the ', ...
                'tab group.'] )

            % Enable 3d rotation mode.
            rotate3d( ax, 'on' )

            % Verify that the number of elements in the tab group is 1.
            testCase.verifyNumElements( tabPanel.TabTitles, 1, ...
                ['Adding an axes to a ', ConstructorName, ...
                ' component has not resulted in one element in the ', ...
                'tab group.'] )

        end % tRotate3dDoesNotAddMoreTabs

        function tDeletingChildrenSetsSelectionToZero( ...
                testCase, ConstructorName )

            % Create a tab panel with controls.
            tabPanel = testCase...
                .createTabPanelWithControls( ConstructorName );

            % Delete all the children.
            delete( tabPanel.Children )

            % Verify that the 'Selection' property is equal to 0.
            testCase.verifyEqual( tabPanel.Selection, 0, ...
                ['The ''Selection'' property of the TabPanel ', ...
                'was not set to 0 when all the children of the ', ...
                'TabPanel were deleted.'] )

        end % tDeletingChildrenSetsSelectionToZero

        function tAddingChildPreservesSelection( ...
                testCase, ConstructorName )

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls( ...
                ConstructorName );

            % Verify that the first control is selected.
            testCase.verifyEqual( tabPanel.Selection, 1, ...
                ['The TabPanel has not preserved its ', ...
                '''Selection'' property when a new child was added.'] )

        end % tAddingChildIncrementsSelection

        function tDeletingLowerIndexChildDecrementsSelection( ...
                testCase, ConstructorName )

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls( ...
                ConstructorName );

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

        function tDeletingSelectedChildPreservesSelection( ...
                testCase, ConstructorName )

            % Create a tab panel with controls.
            tabPanel = testCase.createTabPanelWithControls( ...
                ConstructorName );

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

        function tDeletingHigherIndexChildPreservesSelection( ...
                testCase, ConstructorName )

            % Create a tab panel with controls.
            tabPanel = testCase...
                .createTabPanelWithControls( ConstructorName );

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

        function tDisablingSelectedChildPreservesSelection( ...
                testCase, ConstructorName )

            % Create a tab panel with controls.
            tabPanel = testCase...
                .createTabPanelWithControls( ConstructorName );

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

        function tDisablingNonSelectedChildPreservesSelection( ...
                testCase, ConstructorName )

            % Create a tab panel with controls.
            tabPanel = testCase...
                .createTabPanelWithControls( ConstructorName );

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

        function tTabPanelRespectsParentColor( testCase, ConstructorName )

            % Assume that the component is rooted.
            testCase.assumeGraphicsAreRooted()

            % Create a tab panel with controls.
            tabPanel = testCase...
                .createTabPanelWithControls( ConstructorName );
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

        function tPropertiesAreAssignedWhenMultipleTabsArePresent( ...
                testCase, ConstructorName )

            % Construct a tab panel with multiple tabs.
            tabPanel = testCase...
                .createTabPanelWithControls( ConstructorName );

            % Assign several properties.
            pairs = {'FontAngle', 'italic', ...
                'FontName', 'Courier', ...
                'FontUnits', 'inches', ...
                'FontSize', 0.25, ...
                'FontWeight', 'bold', ...
                'ForegroundColor', [1, 1, 0], ...
                'TabTitles', {'A'; 'B'; 'C'}, ...
                'TabLocation', 'bottom'};
            for k = 1 : 2 : numel( pairs )-1
                name = pairs{k};
                value = pairs{k+1};
                tabPanel.(name) = value;
                actualValue = tabPanel.(name);
                testCase.verifyEqual( actualValue, value, ...
                    ['Setting the ''', name, ''' property of the ', ...
                    'TabPanel in the presence of multiple tabs ', ...
                    'did not assign the value correctly.'] )
            end % for

        end % tPropertiesAreAssignedWhenMultipleTabsArePresent

        function tPixelFontUnitsAreAssignedWhenMultipleTabsArePresent( ...
                testCase, ConstructorName )

            % Construct a tab panel with multiple tabs.
            tabPanel = testCase...
                .createTabPanelWithControls( ConstructorName );

            % Set 'FontUnits' to 'pixels', ensuring that it is not already
            % set to 'pixels.
            tabPanel.FontUnits = 'points';
            tabPanel.FontUnits = 'pixels';
            testCase.verifyEqual( tabPanel.FontUnits, 'pixels', ...
                ['Setting the ''FontUnits'' property of the TabPanel', ...
                ' to ''pixels'' in the presence of multiple tabs ', ...
                'did not assign the value correctly.'] )

        end % tPixelFontUnitsAreAssignedWhenMultipleTabsArePresent

        function tSettingPropertiesAsRowVectorAssignsValues( ...
                testCase, ConstructorName )

            % Construct a tab panel with multiple tabs.
            tabPanel = testCase...
                .createTabPanelWithControls( ConstructorName );

            % Set the 'TabEnables' property.
            rowVectorValue = {'on', 'off', 'on'};
            expectedValue = rowVectorValue(:);
            tabPanel.TabEnables = rowVectorValue;
            testCase.verifyEqual( tabPanel.TabEnables, ...
                expectedValue, ['Setting the ''TabEnables'' ', ...
                'property of the TabPanel as a row vector did ', ...
                'not assign the value correctly.'] )

            % Repeat for the 'TabTitles' property.
            rowVectorValue = {'A', 'B', 'C'};
            expectedValue = rowVectorValue(:);
            tabPanel.TabTitles = rowVectorValue;
            testCase.verifyEqual( tabPanel.TabTitles, ...
                expectedValue, ['Setting the ''TabTitles'' ', ...
                'property of the TabPanel as a row vector did ', ...
                'not assign the value correctly.'] )

        end % tSettingPropertiesAsRowVectorAssignsValues

        function tSettingRelativeTabWidthAssignsValue( ...
                testCase, ConstructorName )

            % Construct a tab panel with multiple tabs.
            tabPanel = testCase...
                .createTabPanelWithControls( ConstructorName );

            % Set a relative value for the 'TabWidth' property.
            relativeValue = -1;
            tabPanel.TabWidth = relativeValue;
            testCase.verifyEqual( tabPanel.TabWidth, relativeValue, ...
                ['Setting a relative value for the ''TabWidth'' ', ...
                'property on the TabPanel did not assign the value', ...
                ' correctly.'] )

        end % tSettingRelativeTabWidthAssignsValue

        function tAddingAxesToDisabledTabHidesContents( ...
                testCase, ConstructorName )

            % Construct a tab panel.
            tabPanel = testCase.constructComponent( ConstructorName );

            % Add an axes and a control. Plot something on the axes. Set
            % the 'ActivePositionProperty' on the axes in order to reach
            % the additional code branch for hiding the tab contents,
            ax = axes( 'Parent', tabPanel, ...
                'ActivePositionProperty', 'outerposition' );
            plot( ax, 1:10 )
            uicontrol( 'Parent', tabPanel )

            % Disable the first tab (and enable the second tab).
            tabPanel.TabEnables = {'off', 'on'};

            % Verify that the axes and plot have been made invisible.
            testCase.verifyEqual( char( ax.Visible ), 'off', ...
                ['Disabling a tab containing an axes did not ', ...
                'make the axes invisible.'] )
            testCase.verifyEqual( char( ax.ContentsVisible ), 'off', ...
                ['Disabling a tab containing an axes did not make ', ...
                'the contents invisible.'] )

        end % tAddingAxesToDisabledTabHidesContents

        % function tStringSupportForTabPanelScalarStringProperties( ...
        %         testCase, ConstructorName )
        % 
        %     % Assume that we are in R2017b or later.
        %     testCase.assumeMATLABVersionIsAtLeast( 'R2017b' )
        % 
        %     % Construct a tab panel.
        %     tabPanel = testCase.constructComponent( ConstructorName );
        % 
        %     % Define a list of property names and values to set.
        %     propertyNames = {'FontAngle', 'FontName', 'FontWeight', ...
        %         'FontUnits', 'TabLocation'};
        %     propertyValues = string( {'italic', 'Helvetica', 'bold', ...
        %         'pixels', 'bottom'} ); %#ok<STRCLQT>
        % 
        %     for k = 1 : numel( propertyNames )
        %         currentProperty = propertyNames{k};
        %         currentValue = propertyValues(k);
        %         % Set the property, using a string value.
        %         tabPanel.(currentProperty) = currentValue;
        %         % Verify that the correct value has been stored.
        %         testCase.verifyEqual( tabPanel.(currentProperty), ...
        %         char( currentValue ), ...
        %         ['The ''', currentProperty, ''' property of the ', ...
        %         ConstructorName, ...
        %         ' component did not accept a string value.'] )
        %     end % for
        % 
        % end % tStringSupportForTabPanelScalarStringProperties
        % 
        % function tStringSupportForTabEnablesProperty( ...
        %         testCase, ConstructorName )
        % 
        %     % Assume that we are in R2017b or later.
        %     testCase.assumeMATLABVersionIsAtLeast( 'R2017b' )
        % 
        %     % Construct a tab panel.
        %     tabPanel = testCase.constructComponent( ConstructorName );
        % 
        %     % Add one child.
        %     uicontrol( tabPanel )
        % 
        %     % Set the TabEnables property.
        %     tabEnables = string( 'off' ); %#ok<STRQUOT>
        %     tabPanel.TabEnables = tabEnables;
        %     testCase.verifyEqual( tabPanel.TabEnables, ...
        %         cellstr( tabEnables ), ...
        %         ['The ''TabEnables'' property on the ', ...
        %         ConstructorName, ' component (when it has one child) ', ...
        %         'did not accept a string value.'] )
        % 
        %     % Add further children.
        %     for k = 1 : 3
        %         uicontrol( tabPanel )
        %     end % for
        % 
        %     % Set the TabEnables property.
        %     tabEnables = string( {'on'; 'off'; 'on'; 'off'} ); %#ok<STRCLQT>
        %     tabPanel.TabEnables = tabEnables;
        % 
        %     % Verify that the stored value is correct.
        %     testCase.verifyEqual( tabPanel.TabEnables, ...
        %         cellstr( tabEnables ), ['The ''TabEnables'' property ', ...
        %         ' of the ', ConstructorName, ' component (when it has', ...
        %         ' multiple children) did not accept a string value.'] )
        % 
        % end % tStringSupportForTabEnablesProperty
        % 
        % function tStringSupportForTabTitlesProperty( ...
        %         testCase, ConstructorName )
        % 
        %     % Assume that we are in R2017b or later.
        %     testCase.assumeMATLABVersionIsAtLeast( 'R2017b' )
        % 
        %     % Construct a tab panel.
        %     tabPanel = testCase.constructComponent( ConstructorName );
        % 
        %     % Add one child.
        %     uicontrol( tabPanel )
        % 
        %     % Set the TabTitles property.
        %     tabTitles = string( 'My Title' ); %#ok<STRQUOT>
        %     tabPanel.TabTitles = tabTitles;
        %     testCase.verifyEqual( tabPanel.TabTitles, ...
        %         cellstr( tabTitles ), ...
        %         ['The ''TabTitles'' property on the ', ...
        %         ConstructorName, ' component (when it has one child) ', ...
        %         'did not accept a string value.'] )
        % 
        %     % Add further children.
        %     for k = 1 : 3
        %         uicontrol( tabPanel )
        %     end % for
        % 
        %     % Set the TabTitles property.
        %     tabTitles = string( {'A'; 'B'; 'C'; 'D'} ); %#ok<STRCLQT>
        %     tabPanel.TabTitles = tabTitles;
        % 
        %     % Verify that the stored value is correct.
        %     testCase.verifyEqual( tabPanel.TabTitles, ...
        %         cellstr( tabTitles ), ['The ''TabTitles'' property ', ...
        %         ' of the ', ConstructorName, ' component (when it has', ...
        %         ' multiple children) did not accept a string value.'] )
        % 
        % end % tStringSupportForTabTitlesProperty

    end % methods ( Test, Sealed )

    methods ( Access = private )

        function tabPanel = createTabPanelWithControls( ...
                testCase, ConstructorName )

            % Create a TabPanel with three controls.
            tabPanel = testCase.constructComponent( ConstructorName );
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

end % classdef