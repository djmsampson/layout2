classdef tBoxPanel < ContainerSharedTests & PanelTests
    %TBOXPANEL Tests for uiextras.BoxPanel.

    properties ( TestParameter )
        % The container type (constructor name).
        ContainerType = {'uiextras.BoxPanel'}
        % Name-value pairs to use when testing the get/set methods.
        GetSetArgs = {{
            'BackgroundColor', [1, 1, 0], ...
            'IsMinimized', false, ...
            'IsDocked', true, ...
            'BorderType', 'etchedout', ...
            'BorderWidth', 10, ...
            'Title', 'uiextras.BoxPanel Test', ...
            'TitleColor', [1, 0, 0], ...
            'ForegroundColor', [1, 1, 1], ...
            'HighlightColor', [1, 0, 1], ...
            'ShadowColor', [0, 0, 0]
            }}
        % Name-value pairs to use when testing the constructor.
        ConstructorArgs = {{
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Padding', 5, ...
            'Tag', 'Test', ...
            'Visible', 'on', ...
            'BorderType', 'etchedout', ...
            'FontAngle', 'normal', ...
            'FontName', 'SansSerif', ...
            'FontSize', 20, ...
            'FontUnits', 'points', ...
            'FontWeight', 'bold'
            }}
    end % properties ( TestParameter )

    methods ( Test )

        function tBoxPanelAutoParentsCorrectly( testCase )

            % Create a new figure.
            newFig = figure();
            testCase.addTeardown( @() delete( newFig ) )

            % Instantiate the BoxPanel, without specifying the parent.
            boxPanel = uiextras.BoxPanel();
            testCase.addTeardown( @() delete( boxPanel ) )

            % Verify that the parent of the BoxPanel is the new figure we
            % created in the test.
            testCase.verifySameHandle( boxPanel.Parent, newFig, ...
                'uiextras.BoxPanel has not auto-parented correctly.' )

        end % tBoxPanelAutoParentsCorrectly

        function tBoxPanelEnableGetMethod( testCase )

            % Create a box panel.
            fig = testCase.FigureFixture.Figure;
            boxPanel = uiextras.BoxPanel( 'Parent', fig );
            testCase.addTeardown( @() delete( boxPanel ) )

            % Verify that the 'Enable' property exists and is set to 'on'.
            testCase.assertTrue( isprop( boxPanel, 'Enable' ), ...
                ['uiextras.BoxPanel does not ', ...
                'have the ''Enable'' property.'] )
            testCase.verifyTrue( strcmp( boxPanel.Enable, 'on' ), ...
                ['The ''Enable'' property of the ', ...
                'BoxPanel is not set to ''on''.'] )

        end % tBoxPanelEnableGetMethod

        function tBoxPanelEnableSetMethod( testCase )

            % Create a box panel.
            fig = testCase.FigureFixture.Figure;
            boxPanel = uiextras.BoxPanel( 'Parent', fig );
            testCase.addTeardown( @() delete( boxPanel ) )

            % Check that setting 'on' or 'off' is accepted.
            for enable = {'on', 'off'}
                enableSetter = @() set( boxPanel, 'Enable', enable{1} );
                testCase.verifyWarningFree( enableSetter, ...
                    ['uiextras.BoxPanel has not accepted a value ', ...
                    'of ''', enable{1}, ...
                    ''' for the ''Enable'' property.'] )
            end % for

            % Check that setting an invalid value causes an error.
            if verLessThan( 'matlab', '9.9' )
                errorID = 'uiextras:InvalidPropertyValue';
            else
                errorID = 'MATLAB:datatypes:onoffboolean:IncorrectValue';
            end % if
            invalidSetter = @() set( boxPanel, 'Enable', {} );
            testCase.verifyError( invalidSetter, errorID, ...
                ['uiextras.BoxPanel has not produced an ', ...
                'error with the expected ID when the ''Enable'' ', ...
                'property was set to an invalid value.'] )

        end % tBoxPanelEnableSetMethod

        function tGetSelectedChild( testCase )

            % Create a box panel.
            fig = testCase.FigureFixture.Figure;
            boxPanel = uiextras.BoxPanel( 'Parent', fig );
            testCase.addTeardown( @() delete( boxPanel ) )

            % Verify that the 'SelectedChild' property is equal to [].
            testCase.verifyEqual( boxPanel.SelectedChild, [], ...
                ['The ''SelectedChild'' property of ', ...
                'uiextras.BoxPanel is not equal to [].'] )

            % Add a child to the box panel.
            uicontrol( boxPanel )
            % Verify that the 'SelectedChild' property is equal to 1.
            testCase.verifyEqual( boxPanel.SelectedChild, 1, ...
                ['The ''SelectedChild'' property of ', ...
                'uiextras.BoxPanel is not equal to 1.'] )

        end % tGetSelectedChild

        function tSetSelectedChild( testCase )

            % Create a box panel.
            fig = testCase.FigureFixture.Figure;
            boxPanel = uiextras.BoxPanel( 'Parent', fig );
            testCase.addTeardown( @() delete( boxPanel ) )

            % Verify that setting the 'SelectedChild' property is
            % warning-free.
            setter = @() set( boxPanel, 'SelectedChild', 1 );
            testCase.verifyWarningFree( setter, ...
                ['uiextras.BoxPanel did not accept setting the ', ...
                '''SelectedChild'' property.'] )

        end % tSetSelectedChild

    end % methods ( Test )

end % class