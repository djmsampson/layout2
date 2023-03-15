classdef UIControlFixture < matlab.unittest.fixtures.Fixture
    %UICONTROLFIXTURE Fixture to enable the use of uicontrol in web
    %figures. Use this fixture for testing from versions R2020b - R2021b.
    %The earliest GUI Layout Toolbox compatibility with web graphics occurs
    %in R2020b. Support for uicontrol in web figures was added in R2022a.

    properties ( Access = private )
        % Original value for the UseRedirect property.
        OriginalUseRedirect
        % Original value for the UseRedirectInUifigure property.
        OriginalEnableInWebFigure
    end % properties ( Access = private )

    methods

        function setup( fixture )
            %SETUP Set up the uicontrol fixture.

            % Enable the UseRedirect property.
            s = settings();
            fixture.OriginalUseRedirect = s.matlab.ui.internal...
                .uicontrol.UseRedirect.hasTemporaryValue;
            s.matlab.ui.internal...
                .uicontrol.UseRedirect.TemporaryValue = true;

            % Enable the UseRedirectInUifigure property.
            fixture.OriginalEnableInWebFigure = s.matlab.ui.internal...
                .uicontrol.UseRedirectInUifigure.hasTemporaryValue;
            s.matlab.ui.internal...
                .uicontrol.UseRedirectInUifigure.TemporaryValue = true;
        end % setup

        function teardown( fixture )
            %TEARDOWN Tear down the uicontrol fixture.

            % Revert to the original values.
            s = settings();
            s.matlab.ui.internal.uicontrol...
                .UseRedirect.TemporaryValue = fixture.OriginalUseRedirect;
            s.matlab.ui.internal.uicontrol.UseRedirectInUifigure...
                .TemporaryValue = fixture.OriginalEnableInWebFigure;

        end % teardown

    end % methods

end % class