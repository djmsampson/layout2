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

        function tAddingChildIncrementsSelection( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Verify that the third control is selected.
            testCase.verifyEqual( cardPanel.Selection, 3, ...
                ['The CardPanel has not correctly updated its ', ...
                '''Selection'' property when a new child was added.'] )

        end % tAddingChildIncrementsSelection

        function tDeletingLowerIndexChildDecrementsSelection( testCase )

            % Create a card panel with controls.
            cardPanel = testCase.createCardPanelWithControls();

            % Record the current selection, then delete the first child.
            currentSelection = cardPanel.Selection;
            delete( cardPanel.Contents(3) )

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
            delete( cardPanel.Contents(2) )

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
            delete( cardPanel.Contents(1) )

            % Verify that the 'Selection' property has remained the same.
            testCase.verifyEqual( cardPanel.Selection, ...
                currentSelection, ...
                ['The ''Selection'' property of the CardPanel ', ...
                'has not remained the same when a higher index child ', ...
                'was deleted (and the current child was not the ', ...
                'highest index child).'] )

        end % tDeletingHigherIndexChildPreservesSelection

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