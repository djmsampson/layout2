classdef tCardPanel < sharedtests.SharedPanelTests
    %TCARDPANEL Tests for uiextras.CardPanel and uix.CardPanel.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uiextras.CardPanel', 'uix.CardPanel'}
        % Name-value pair arguments to use when testing the component's
        % constructor and get/set methods.
        NameValuePairs = cardPanelNameValuePairs()
    end % properties ( TestParameter )

    methods ( Test, Sealed )

        function tDeletingChildrenUnsetsSelection( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Delete all the children.
            delete( cardPanel.Contents )

            % Verify that the 'Selection' property is equal to 0.
            testCase.verifyEqual( cardPanel.Selection, 0, ...
                'The selection of the CardPanel was not unset when all the children were deleted.' )

        end % tDeletingChildrenUnsetsSelection

        function tAddingChildrenSelectsLast( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Verify that the added control is selected.
            testCase.verifyEqual( cardPanel.Selection, numel( cardPanel.Contents ), ...
                'The CardPanel has not selected the newly added child.' )

            % Select earlier child.
            cardPanel.Selection = 1;

            % Add child.
            uicontrol( 'Parent', cardPanel );

            % Verify that the added control is selected.
            testCase.verifyEqual( cardPanel.Selection, numel( cardPanel.Contents ), ...
                'The CardPanel has not selected the newly added child.' )

        end % tAddingChildrenSelectsLast

        function tDeletingEarlierChildPreservesSelection( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Record the current selection, then delete the first child.
            oldContents = cardPanel.Contents;
            oldSelection = numel( oldContents );
            cardPanel.Selection = oldSelection;
            delete( cardPanel.Contents(1) )
            newContents = cardPanel.Contents;
            newSelection = cardPanel.Selection;

            % Test that deleting a child with a lower index than the
            % current selection causes the selection index to decrease by
            % 1.
            testCase.verifyEqual( oldContents(oldSelection), newContents(newSelection), ...
                'The CardPanel has not preserved its selection when an earlier child was deleted.' )

        end % tDeletingEarlierChildPreservesSelection

        function tDeletingSelectedFirstChildSelectsSecondChild( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Select the first child, then delete it.
            oldContents = cardPanel.Contents;
            oldSelection = 1;
            cardPanel.Selection = oldSelection;
            delete( cardPanel.Contents(oldSelection) );
            newContents = cardPanel.Contents;
            newSelection = cardPanel.Selection;

            % Verify that the 'Selection' property has remained the same.
            testCase.verifyEqual( newContents(newSelection), oldContents(2), ...
                'Then CardPanel has not selected the second child when the first child was selected and deleted.' )

        end % tDeletingSelectedChildPreservesSelection

        function tDeletingSelectedChildSelectsNextChild( testCase )

            % TODO revisit whether this behavior is desirable

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Select the first child, then delete it.
            oldContents = cardPanel.Contents;
            oldSelection = 2;
            cardPanel.Selection = oldSelection;
            delete( cardPanel.Contents(oldSelection) );
            newContents = cardPanel.Contents;
            newSelection = cardPanel.Selection;

            % Verify that the 'Selection' property has remained the same.
            testCase.verifyEqual( newContents(newSelection), oldContents(oldSelection+1), ...
                'Then CardPanel has not selected the next child when the selected child was deleted.' )

        end % tDeletingSelectedChildSelectsNextChild

        function tDeletingSelectedLastChildSelectsSecondLastChild( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Select the first child, then delete it.
            oldContents = cardPanel.Contents;
            oldSelection = numel( oldContents );
            cardPanel.Selection = oldSelection;
            delete( cardPanel.Contents(oldSelection) );
            newContents = cardPanel.Contents;
            newSelection = cardPanel.Selection;

            % Verify that the 'Selection' property has remained the same.
            testCase.verifyEqual( newContents(newSelection), oldContents(end-1), ...
                'Then CardPanel has not selected the second last child when the last child was selected and deleted.' )

        end % tDeletingSelectedLastChildSelectsSecondLastChild

        function tDeletingLaterChildPreservesSelection( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Record the current selection, then delete the first child.
            oldContents = cardPanel.Contents;
            oldSelection = 1;
            cardPanel.Selection = oldSelection;
            delete( cardPanel.Contents(end) )
            newContents = cardPanel.Contents;
            newSelection = cardPanel.Selection;

            % Test that deleting a child with a lower index than the
            % current selection causes the selection index to decrease by
            % 1.
            testCase.verifyEqual( oldContents(oldSelection), newContents(newSelection), ...
                'The CardPanel has not preserved its selection when a later child was deleted.' )

        end % tDeletingLaterChildPreservesSelection

    end % methods ( Test, Sealed )

    methods ( Access = private )

        function cardPanel = createCardPanelWithControls( testCase )

            % Create a CardPanel with three controls.
            parent = testCase.ParentFixture.Parent;
            cardPanelConstructor = testCase.ConstructorName{1};
            cardPanel = feval( cardPanelConstructor, 'Parent', parent );
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

end % classdef

function nvp = cardPanelNameValuePairs()
%CARDPANELNAMEVALUEPAIRS Define name-value pairs common to both
%uiextras.CardPanel and uix.CardPanel.

commonNameValuePairs = {
    'BackgroundColor', [1, 1, 0], ...
    'DeleteFcn', @glttestutilities.noop, ...
    'Padding', 5, ...
    'Units', 'pixels', ...
    'Position', [10, 10, 400, 400], ...
    'Tag', 'Test', ...
    'Visible', 'on'
    };
nvp = {commonNameValuePairs, commonNameValuePairs};

end % cardPanelNameValuePairs