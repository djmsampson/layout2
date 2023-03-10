classdef UIControlFixture < matlab.unittest.fixtures.Fixture
    % Custom fixture to allow uicontrol to work when a container is
    % parented to a uifigure
    properties (Access = private)
        OriginalUseRedirect;
        OriginalEnableInUifigure;
    end
    methods
        function setup(fixture)
            sys = settings();
            fixture.OriginalUseRedirect = ...
                sys.matlab.ui.internal.uicontrol.UseRedirect.hasTemporaryValue;
            sys.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue = true;
            
            fixture.OriginalEnableInUifigure = ...
                sys.matlab.ui.internal.uicontrol.UseRedirectInUifigure.hasTemporaryValue;
            sys.matlab.ui.internal.uicontrol.UseRedirectInUifigure.TemporaryValue = true;
        end
        function teardown(fixture)
            sys = settings();
            sys.matlab.ui.internal.uicontrol.UseRedirect.TemporaryValue = ...
                fixture.OriginalUseRedirect;
            
            sys.matlab.ui.internal.uicontrol.UseRedirectInUifigure.TemporaryValue = ...
                fixture.OriginalEnableInUifigure;
        end
    end
end