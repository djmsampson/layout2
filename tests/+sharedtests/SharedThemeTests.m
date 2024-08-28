classdef SharedThemeTests < glttestutilities.TestInfrastructure
    %SHAREDTHEMETESTS Shared tests for responses to theme changes.

    properties ( TestParameter, Abstract )
        % The constructor name, or class, of the component under test.
        ConstructorName
    end % properties ( TestParameter, Abstract )

    methods ( Test, Sealed )

        function tReparentingComponentUpdatesBackgroundColor( ...
                testCase, ConstructorName )

            % Prepare the component.
            [component, testFigLight] = testCase.prepareComponent( ...
                ConstructorName );
            lightThemeBackgroundColor = component.BackgroundColor;            

            % Create a separate figure in dark mode.
            testFigDark = uifigure( 'AutoResizeChildren', 'off', ...
                'Theme', 'dark' );
            testCase.addTeardown( @() delete( testFigDark ) )            

            % Reparent the component.
            component.Parent = testFigDark;
            darkThemeBackgroundColor = component.BackgroundColor;            

            % Verify that the BackgroundColor has changed.
            diagnostic = @( from, to ) ['Reparenting a ', ...
                ConstructorName, ' component from a figure with ', ...
                from, ' theme to a figure with ', to, ' theme did not', ...
                ' change the ''BackgroundColor'' of the component.'];
            testCase.verifyNotEqual( darkThemeBackgroundColor, ...
                lightThemeBackgroundColor, ...
                diagnostic( 'light', 'dark' ) )

            % Repeat the test in the other direction.
            component.Parent = testFigLight;
            lightThemeBackgroundColor = component.BackgroundColor;
            testCase.verifyNotEqual( lightThemeBackgroundColor, ...
                darkThemeBackgroundColor, ...
                diagnostic( 'dark', 'light' ) )

        end % tReparentingComponentUpdatesBackgroundColor

        function tBackgroundColorRespondsToThemeChanges( testCase, ...
                ConstructorName )

            testCase.tColorPropertyRespondsToThemeChanges( ...
                ConstructorName, 'BackgroundColor', true )

        end % tBackgroundColorRespondsToThemeChanges

        function tBackgroundColorIgnoresThemeChangesIfSetManually( ...
                testCase, ConstructorName )

            testCase.tColorPropertyIgnoresThemeChangesIfSetManually( ...
                ConstructorName, 'BackgroundColor' )

        end % tBackgroundColorIgnoresThemeChangesIfSetManually

        function tComponentRespectsBackgroundColorMode( testCase, ...
                ConstructorName )

            testCase.tComponentRespectsColorPropertyMode( ...
                ConstructorName, 'BackgroundColor', true )

        end % tComponentRespectsBackgroundColorMode

        function tComponentRespectsModeAfterSettingBackgroundColor( ...
                testCase, ConstructorName )

            testCase.tComponentRespectsModeAfterSettingColorProperty( ...
                ConstructorName, 'BackgroundColor', true )

        end % tComponentRespectsModeAfterSettingBackgroundColor

        function tHighlightColorRespondsToThemeChangesForPanels( ...
                testCase, ConstructorName )

            % This test only applies to panels and box panels.
            testCase.assumeComponentIsAPanelOrBoxPanel( ConstructorName )

            % Run the test.
            testCase.tColorPropertyRespondsToThemeChanges( ...
                ConstructorName, 'HighlightColor', false )

        end % tHighlightColorRespondsToThemeChangesForPanels

        function tHighlightColorIgnoresThemeChangesIfSetManually( ...
                testCase, ConstructorName )

            % This test only applies to panels and box panels.
            testCase.assumeComponentIsAPanelOrBoxPanel( ConstructorName )

            % Run the test.
            testCase.tColorPropertyIgnoresThemeChangesIfSetManually( ...
                ConstructorName, 'HighlightColor' )

        end % tHighlightColorIgnoresThemeChangesIfSetManually

        function tPanelsRespectHighlightColorMode( testCase, ...
                ConstructorName )

            % This test only applies to panels and box panels.
            testCase.assumeComponentIsAPanelOrBoxPanel( ConstructorName )

            % Run the test.
            testCase.tComponentRespectsColorPropertyMode( ...
                ConstructorName, 'HighlightColor', false )

        end % tPanelsRespectHighlightColorMode

        function tPanelsRespectModeAfterSettingHighlightColor( ...
                testCase, ConstructorName )

            % This test only applies to panels and box panels.
            testCase.assumeComponentIsAPanelOrBoxPanel( ConstructorName )

            % Run the test.
            testCase.tComponentRespectsModeAfterSettingColorProperty( ...
                ConstructorName, 'HighlightColor', false )

        end % tPanelsRespectModeAfterSettingHighlightColor

        function tBorderColorRespondsToThemeChangesForPanels( ...
                testCase, ConstructorName )

            % This test only applies to panels and box panels.
            testCase.assumeComponentIsAPanelOrBoxPanel( ConstructorName )

            % Run the test.
            testCase.tColorPropertyRespondsToThemeChanges( ...
                ConstructorName, 'BorderColor', false )

        end % tBorderColorRespondsToThemeChangesForPanels

        function tBorderColorIgnoresThemeChangesIfSetManually( ...
                testCase, ConstructorName )

            % This test only applies to panels and box panels.
            testCase.assumeComponentIsAPanelOrBoxPanel( ConstructorName )

            % Run the test.
            testCase.tColorPropertyIgnoresThemeChangesIfSetManually( ...
                ConstructorName, 'BorderColor' )

        end % tBorderColorIgnoresThemeChangesIfSetManually

        function tPanelForegroundColorRespondsToThemeChanges( testCase, ...
                ConstructorName )

            % This test only applies to panels.
            testCase.assumeComponentIsAPanel( ConstructorName )
            
            % Run the test.
            testCase.tColorPropertyRespondsToThemeChanges( ...
                ConstructorName, 'ForegroundColor', true )

        end % tPanelForegroundColorRespondsToThemeChanges

        function tPanelForegroundColorIgnoresThemeChangesIfSetManually( ...
                testCase, ConstructorName )

            % This test only applies to panels.
            testCase.assumeComponentIsAPanel( ConstructorName )
            
            % Run the test.
            testCase.tColorPropertyIgnoresThemeChangesIfSetManually( ...
                ConstructorName, 'ForegroundColor' )

        end % tPanelForegroundColorIgnoresThemeChangesIfSetManually

        function tPanelRespectsForegroundColorMode( testCase, ...
                ConstructorName )

            % This test only applies to panels.
            testCase.assumeComponentIsAPanel( ConstructorName )
            
            % Run the test.
            testCase.tComponentRespectsColorPropertyMode( ...
                ConstructorName, 'ForegroundColor', true )

        end % tPanelRespectsForegroundColorMode

        function tPanelRespectsModeAfterSettingForegroundColor( ...
                testCase, ConstructorName )

            % This test only applies to panels.
            testCase.assumeComponentIsAPanel( ConstructorName )
            
            % Run the test.
            testCase.tComponentRespectsModeAfterSettingColorProperty( ...
                ConstructorName, 'ForegroundColor', true )

        end % tPanelRespectsModeAfterSettingForegroundColor

        function tBoxPanelForegroundColorIgnoresThemeChanges( testCase, ...
                ConstructorName )

            % This test only applies to box panels.
            testCase.assumeComponentIsABoxPanel( ConstructorName )

            % Create a component.
            [component, testFig] = testCase.prepareComponent( ...
                ConstructorName );

            % Verify that ForegroundColorMode is 'manual' on construction.
            testCase.verifyEqual( component.ForegroundColorMode, ...
                'manual', ['The ''ForegroundColorMode'' property ', ...
                'of the ', ConstructorName, ' component was not ', ...
                'set to ''manual'' on construction.'] )

            % Verify that the ForegroundColor is white.
            white = [1, 1, 1];
            testCase.verifyEqual( component.ForegroundColor, ...
                white, ['The ''ForegroundColor'' property of ', ...
                'the ', ConstructorName, ' component was not set', ...
                ' to white ([1, 1, 1]) on construction.'] )

            % Change the theme.
            testFig.Theme = 'dark';

            % Verify that the ForegroundColor is still white.
            diagnostic = @( from , to ) ['The ''ForegroundColor'' ', ...
                'property of the ', ConstructorName, ' component did ', ...
                'not remain white after changing the theme from ', ...
                from, ' to ', to];
            testCase.verifyEqual( component.ForegroundColor, white, ...
                diagnostic( 'light', 'dark' ) )

            % Repeat the test in reverse.
            testFig.Theme = 'light';
            testCase.verifyEqual( component.ForegroundColor, white, ...
                diagnostic( 'dark', 'light' ) )

        end % tBoxPanelForegroundColorIgnoresThemeChanges

        function tBoxPanelTitleColorRespondsToThemeChanges( testCase, ...
                ConstructorName )           

            % This test is only for box panels.
            testCase.assumeComponentIsABoxPanel( ConstructorName )

            % Run the test.
            testCase.tColorPropertyRespondsToThemeChanges( ...
                ConstructorName, 'TitleColor', true )

        end % tBoxPanelTitleColorRespondsToThemeChanges

        function tBoxPanelTitleColorIgnoresThemeIfSetManually( ...
                testCase, ConstructorName )

            % Assume we're in R2025a or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2025a' )

            % This test is only for box panels.
            testCase.assumeComponentIsABoxPanel( ConstructorName )

            % Run the test.
            testCase.tColorPropertyIgnoresThemeChangesIfSetManually( ...
                ConstructorName, 'TitleColor' )

        end % tBoxPanelTitleColorIgnoresThemeIfSetManually

        function tBoxPanelRespectsTitleColorMode( testCase, ...
                ConstructorName )

            % Assume we're in R2025a or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2025a' )

            % This test is only for box panels.
            testCase.assumeComponentIsABoxPanel( ConstructorName )

            % Run the test.
            testCase.tComponentRespectsColorPropertyMode( ...
                ConstructorName, 'TitleColor', true )

        end % tBoxPanelRespectsTitleColorMode

        function tBoxPanelRespectsModeAfterSettingTitleColor( testCase, ...
                ConstructorName )            

            % This test is only for box panels.
            testCase.assumeComponentIsABoxPanel( ConstructorName )

            % Run the test.
            testCase.tComponentRespectsModeAfterSettingColorProperty( ...
                ConstructorName, 'TitleColor', true )

        end % tBoxPanelRespectsModeAfterSettingTitleColor

        function tTabPanelForegroundColorRespondsToThemeChanges( ...
                testCase, ConstructorName )            

            % This test is only for tab panels.
            testCase.assumeComponentIsATabPanel( ConstructorName )

            % Run the test.
            testCase.tColorPropertyRespondsToThemeChanges( ...
                ConstructorName, 'ForegroundColor', true )

        end % tTabPanelForegroundColorRespondsToThemeChanges

        function tTabPanelForegroundColorIgnoresThemeIfSetManually( ...
                testCase, ConstructorName )

            % Assume we're in R2025a or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2025a' )

            % This test is only for tab panels.
            testCase.assumeComponentIsATabPanel( ConstructorName )

            % Run the test.
            testCase.tColorPropertyIgnoresThemeChangesIfSetManually( ...
                ConstructorName, 'ForegroundColor' )

        end % tTabPanelForegroundColorIgnoresThemeIfSetManually

        function tTabPanelRespectsForegroundColorMode( testCase, ...
                ConstructorName )

            % Assume we're in R2025a or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2025a' )

            % This test is only for tab panels.
            testCase.assumeComponentIsATabPanel( ConstructorName )

            % Run the test.
            testCase.tComponentRespectsColorPropertyMode( ...
                ConstructorName, 'ForegroundColor', true )

        end % tTabPanelRespectsForegroundColorMode

        function tTabPanelRespectsModeAfterSettingForegroundColor( ...
                testCase, ConstructorName )            

            % This test is only for tab panels.
            testCase.assumeComponentIsATabPanel( ConstructorName )

            % Run the test.
            testCase.tComponentRespectsModeAfterSettingColorProperty( ...
                ConstructorName, 'ForegroundColor', true )

        end % tTabPanelRespectsModeAfterSettingForegroundColor

    end % methods ( Test, Sealed )

    methods ( Access = private )

        function tColorPropertyRespondsToThemeChanges( testCase, ...
                ConstructorName, colorProperty, colorShouldChange )

            % Prepare the component.
            [component, testFig] = prepareComponent( testCase, ...
                ConstructorName );

            % Record the property.
            lightThemeColorProperty = component.(colorProperty);

            % Now change the theme.
            testFig.Theme = 'dark';

            % Record the new property.
            darkThemeColorProperty = component.(colorProperty);

            % Verify that the property has changed (or not).
            diagnostic = @(property, changed, from, to) ['The ', ...
                ConstructorName, ...
                ' component ', changed, ' its ''', property, '''', ...
                ' when the figure theme was changed from ''', from, ...
                ''' to ''', to, '''.'];
            if colorShouldChange
                testCase.verifyNotEqual( darkThemeColorProperty, ...
                    lightThemeColorProperty, diagnostic( colorProperty, ...
                    'did not change', 'light', 'dark' ) )
            else
                testCase.verifyEqual( darkThemeColorProperty, ...
                    lightThemeColorProperty, diagnostic( colorProperty, ...
                    'changed', 'light', 'dark' ) )
            end % if

            % Now change from dark theme to light theme.
            testFig.Theme = 'light';

            % Record the new color property.
            lightThemeColorProperty = component.(colorProperty);

            % Verify that the color property has changed (or not).
            if colorShouldChange
                testCase.verifyNotEqual( lightThemeColorProperty, ...
                    darkThemeColorProperty, diagnostic( colorProperty, ...
                    'did not change', 'dark', 'light' ) )
            else
                testCase.verifyEqual( lightThemeColorProperty, ...
                    darkThemeColorProperty, diagnostic( colorProperty, ...
                    'changed', 'dark', 'light' ) )
            end % if

        end % tColorPropertyRespondsToThemeChanges

        function tColorPropertyIgnoresThemeChangesIfSetManually( ...
                testCase, ConstructorName, colorProperty )

           % Prepare the component.
            [component, testFig] = prepareComponent( testCase, ...
                ConstructorName );

            % Set the color property of the component manually.
            actualColor = [1, 0, 0];            
            component.(colorProperty) = actualColor;

            % Change the theme.
            testFig.Theme = 'dark';

            % Verify that the color property remains the same.
            diagnostic = ['The (manually set) ''', colorProperty, '''', ...
                ' of the ', ConstructorName, ' component ', ...
                'unexpectedly changed when the theme was changed.'];
            testCase.verifyEqual( component.(colorProperty), ...
                actualColor, diagnostic )

            % Repeat the test, going from dark to light theme.
            testFig.Theme = 'light';
            testCase.verifyEqual( component.(colorProperty), ...
                actualColor, diagnostic )

        end % tColorPropertyIgnoresThemeChangesIfSetManually

        function tComponentRespectsColorPropertyMode( testCase, ...
                ConstructorName, colorProperty, colorShouldChange )

            % Prepare the component.
            [component, testFig] = prepareComponent( testCase, ...
                ConstructorName );            

            % Set the color mode to 'manual' and record the current color
            % property.
            colorPropertyMode = [colorProperty, 'Mode'];
            component.(colorPropertyMode) = 'manual';
            color = component.(colorProperty);

            % Change the theme.
            testFig.Theme = 'dark';

            % Verify that the color property has not changed.
            diagnostic = ['Setting the ''', colorPropertyMode, '''', ...
                ' property of the ', ConstructorName, ' component ', ...
                'to ''manual'' and changing the theme did not ', ...
                'preserve the ''', colorProperty, ''' of the component.'];
            testCase.verifyEqual( component.(colorProperty), color, ...
                diagnostic )

            % Change the theme and repeat the test.
            testFig.Theme = 'light';
            testCase.verifyEqual( component.(colorProperty), color, ...
                diagnostic )

            % Set the color property mode to 'auto'.
            component.(colorPropertyMode) = 'auto';

            % Verify that the color property hasn't changed.
            testCase.verifyEqual( component.(colorProperty), color, ...
                ['The ''', colorProperty, ''' of the ', ...
                ConstructorName, ' component changed after ''', ...
                colorPropertyMode, ''' was set to ''auto''.'] )

            % Change the theme.
            testFig.Theme = 'dark';
            darkThemeColor = component.(colorProperty);

            % Verify that the color property has now changed (or not).
            diagnostic = @( context ) ['Setting the ''', ...
                colorPropertyMode, ''' ', ...
                'property of the ', ConstructorName, ' component ', ...
                'to ''auto'' and changing the theme ', context, ...
                ' the ''', colorProperty, ''' of the component.'];

            if colorShouldChange
                testCase.verifyNotEqual( darkThemeColor, color, ...
                    diagnostic( 'did not change' ) )
            else
                testCase.verifyEqual( darkThemeColor, color, ...
                    diagnostic( 'changed' ) )
            end % if

            % Change the theme and repeat the test.
            testFig.Theme = 'light';

            if colorShouldChange
                testCase.verifyNotEqual( component.(colorProperty), ...
                    darkThemeColor, diagnostic( 'did not change' ) )
            else
                testCase.verifyEqual( component.(colorProperty), ...
                    darkThemeColor, diagnostic( 'changed' ) )
            end % if

        end % tComponentRespectsColorPropertyMode

        function tComponentRespectsModeAfterSettingColorProperty( ...
                testCase, ConstructorName, colorProperty, ...
                colorShouldChange )

            % Prepare the component.
            [component, testFig] = prepareComponent( testCase, ...
                ConstructorName );            

            % Set the color property of the component.
            requiredColor = [1, 0, 0];
            colorPropertyMode = [colorProperty, 'Mode'];
            component.(colorProperty) = requiredColor;

            % Verify that color property mode is now 'manual'.
            testCase.verifyEqual( component.(colorPropertyMode), ...
                'manual', ['Setting the ''', colorProperty, '''', ...
                'of the ', ConstructorName, ' component did not ', ...
                'update the ''', colorPropertyMode, ''' to ''manual''.'] )

            % Reset the color property mode back to 'auto'.
            component.(colorPropertyMode) = 'auto';           

            % Change the theme.
            testFig.Theme = 'dark';
            darkThemeColorProperty = component.(colorProperty);

            % Verify that the color property has changed.
            diagnostic = @( context ) ['The ''', colorProperty, ...
                ''' of the ', ConstructorName, ' component ', ...
                context, ' when the theme was changed and ''', ...
                colorPropertyMode, ''' was set to ''auto''.'];            
            testCase.verifyNotEqual( darkThemeColorProperty, ...
                requiredColor, diagnostic( 'did not change' ) )                     

            % Repeat the test when changing from dark to light theme.
            testFig.Theme = 'light';
            lightThemeColorProperty = component.(colorProperty);
            if colorShouldChange
                testCase.verifyNotEqual( darkThemeColorProperty, ...
                    lightThemeColorProperty, ...
                    diagnostic( 'did not change' ) )
            else
                testCase.verifyEqual( darkThemeColorProperty, ...
                    lightThemeColorProperty, diagnostic( 'changed' ) )
            end % if  

        end % tComponentRespectsModeAfterSettingColorProperty

        function [component, testFig] = prepareComponent( testCase, ...
                ConstructorName )

            % Assume that we're not running in CI, that we have the new 
            % desktop environment enabled, and that we're in R2024a 
            % onwards. Assume that the component parent is either a figure
            % or a uifigure.
            %testCase.assumeNotRunningOnCI()
            testCase.assumeJavaScriptDesktop()
            testCase.assumeMATLABVersionIsAtLeast( 'R2024a' )
            testCase.assumeGraphicsAreRooted()

            % Construct a component.
            component = testCase.constructComponent( ConstructorName );

            % Find the figure parent.
            testFig = component.Parent;

            % Set light theme.
            testFig.Theme = 'light';

        end % prepareComponent

        function assumeComponentIsAPanelOrBoxPanel( testCase, ...
                ConstructorName )

            isPanelOrBoxPanel = ismember( ConstructorName, ...
                {'uiextras.Panel', 'uix.Panel', ...
                'uiextras.BoxPanel', 'uix.BoxPanel'} );
            testCase.assumeTrue( isPanelOrBoxPanel, ...
                ['This test is only applicable to ', ...
                'uix/uiextras.Panel/BoxPanel.'] )

        end % assumeComponentIsAPanelOrBoxPanel

        function assumeComponentIsAPanel( testCase, ConstructorName )

            isPanel = ismember( ConstructorName, ...
                {'uiextras.Panel', 'uix.Panel'} );
            testCase.assumeTrue( isPanel, ...
                'This test is only applicable to uix/uiextras.Panel.' )

        end % assumeComponentIsAPanel

        function assumeComponentIsABoxPanel( testCase, ConstructorName )

            isPanel = ismember( ConstructorName, ...
                {'uiextras.BoxPanel', 'uix.BoxPanel'} );
            testCase.assumeTrue( isPanel, ...
                'This test is only applicable to uix/uiextras.BoxPanel.' )

        end % assumeComponentIsABoxPanel

        function assumeComponentIsATabPanel( testCase, ConstructorName )

            isTabPanel = ismember( ConstructorName, ...
                {'uiextras.TabPanel', 'uix.TabPanel'} );
            testCase.assumeTrue( isTabPanel, ...
                'This test is only applicable to uix/uiextras.TabPanel.' )

        end % assumeComponentIsATabPanel

    end % methods ( Access = private )

end % classdef