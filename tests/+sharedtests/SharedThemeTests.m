classdef SharedThemeTests < glttestutilities.TestInfrastructure
    %SHAREDTHEMETESTS Shared tests for responses to theme changes.

    properties ( TestParameter, Abstract )
        % The constructor name, or class, of the component under test.
        ConstructorName
    end % properties ( TestParameter, Abstract )

    methods ( Test, Sealed )

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
                ConstructorName, 'BackgroundColor' )

        end % tComponentRespectsBackgroundColorMode

        function tComponentRespectsModeAfterSettingBackgroundColor( ...
                testCase, ConstructorName )

            testCase.tComponentRespectsModeAfterSettingColorProperty( ...
                ConstructorName, 'BackgroundColor' )

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
                ConstructorName, colorProperty )

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
                'property of the ', ConstructorName, ' component ', ...
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

            % Verify that the color property has now changed.
            diagnostic = ['Setting the ''', colorPropertyMode, '''', ...
                'property of the ', ConstructorName, ' component ', ...
                'to ''auto'' and changing the theme did not change ', ...
                'the ''', colorProperty, ''' of the component.'];
            darkThemeColor = component.(colorProperty);
            testCase.verifyNotEqual( darkThemeColor, color, diagnostic )

            % Change the theme and repeat the test.
            testFig.Theme = 'light';
            testCase.verifyNotEqual( component.(colorProperty), ...
                darkThemeColor, diagnostic )

        end % tComponentRespectsColorPropertyMode

        function tComponentRespectsModeAfterSettingColorProperty( ...
                testCase, ConstructorName, colorProperty )

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

            % Verify that the color property has changed.
            diagnostic = ['The ''', colorProperty, ''' of the ', ...
                ConstructorName, ' component did not change when the ', ...
                'theme was changed and ''', colorPropertyMode, '''', ...
                'set to ''auto''.'];
            testCase.verifyNotEqual( component.(colorProperty), ...
                requiredColor, diagnostic )

            % Repeat the test when changing from dark to light theme.
            testFig.Theme = 'light';
            testCase.verifyNotEqual( component.(colorProperty), ...
                requiredColor, diagnostic )

        end % tComponentRespectsModeAfterSettingColorProperty

        function [component, testFig] = prepareComponent( testCase, ...
                ConstructorName )

            % Assume that we have the new desktop environment enabled and
            % that we're in R2024a onwards. Assume that the component
            % parent is either a figure or a uifigure.
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

    end % methods ( Access = private )

end % classdef