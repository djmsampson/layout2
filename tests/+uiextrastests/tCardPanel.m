classdef tCardPanel < PanelTests & ContainerSharedTests
    %TCARDPANEL Tests for uiextras.CardPanel.

    properties ( TestParameter )
        % The container type (constructor name).
        ContainerType = {'uiextras.CardPanel'}
        % Name-value pairs to use when testing the get/set methods.
        GetSetArgs = {{
            'BackgroundColor', [1, 1, 0], ...
            'SelectedChild', 2
            }}
        % Name-value pairs to use when testing the constructor.
        ConstructorArgs = {{
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Padding', 5, ...
            'Tag', 'Test', ...
            'Visible', 'on'
            }}
    end % properties ( TestParameter )

    methods ( Test )

        function tDeletingChildrenSetsSelectionToZero( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Delete all the children.
            delete( cardPanel.Children )

            % Verify that the 'Selection' property is equal to 0.
            testCase.verifyEqual( cardPanel.Selection, 0, ...
                ['The ''Selection'' property of the CardPanel ', ...
                'was not set to 0 when all the children of the ', ...
                'CardPanel were deleted.'] )

        end % tDeletingChildrenSetsSelectionToZero

        function tAddingChildIncrementsSelection( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Verify that the thid control is selected.
            testCase.verifyEqual( cardPanel.Selection, 3, ...
                ['The CardPanel has not correctly updated its ', ...
                '''Selection'' property when a new child was added.'] )

        end % tAddingChildIncrementsSelection

        function tDeletingLowerIndexChildDecrementsSelection( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Record the current selection, then delete the first child.
            currentSelection = cardPanel.Selection;
            delete( cardPanel.Children(3) )

            % Test that deleting a child with a lower index than the
            % current selection causes the selection index to decrease by
            % 1.
            testCase.verifyEqual( cardPanel.Selection, ...
                currentSelection - 1, ...
                ['The CardPanel has not correctly updated its ', ...
                '''Selection'' property when a child with a lower ', ...
                'index than the current selection was deleted.'] )

        end % tDeletingLowerIndexChildDecrementsSelection

        function tDeletingSelectedChildPreservesSelection( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Select the second child, record the current selection, then
            % delete the second child.
            cardPanel.Selection = 2;
            currentSelection = cardPanel.Selection;
            delete( cardPanel.Children(2) )

            % Verify that the 'Selection' property has remained the same.
            testCase.verifyEqual( cardPanel.Selection, ...
                currentSelection, ...
                ['The ''Selection'' property of the CardPanel ', ...
                'has not remained the same when the current child ', ...
                'was deleted (and the current child was not the ', ...
                'highest index child).'] )

        end % tDeletingSelectedChildPreservesSelection

        function tDeletingHigherIndexChildPreservesSelection( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Select the second child, record the current selection, and
            % delete the third child.
            cardPanel.Selection = 2;
            currentSelection = cardPanel.Selection;
            delete( cardPanel.Children(1) )

            % Verify that the 'Selection' property has remained the same.
            testCase.verifyEqual( cardPanel.Selection, ...
                currentSelection, ...
                ['The ''Selection'' property of the CardPanel ', ...
                'has not remained the same when a higher index child ', ...
                'was deleted (and the current child was not the ', ...
                'highest index child).'] )

        end % tDeletingHigherIndexChildPreservesSelection        

    end % methods ( Test )

    methods ( Access = private )

        function cardPanel = createCardPanelWithControls( testCase )

            % Create a CardPanel with three controls.
            fig = testCase.FigureFixture.Figure;
            cardPanel = uix.CardPanel( 'Parent', fig );
            testCase.addTeardown( @() delete( cardPanel ) )
            uicontrol( 'Parent', cardPanel, ...
                'Style', 'frame', ...
                'BackgroundColor', 'r' )
            uicontrol( 'Parent', cardPanel, ...
                'Style', 'frame', ...
                'BackgroundColor', 'g' )
            uicontrol( 'Parent', cardPanel, ...
                'Style', 'frame', ...
                'BackgroundColor', 'b' )

        end % createCardPanelWithControls

    end % methods ( Access = private )

end % class