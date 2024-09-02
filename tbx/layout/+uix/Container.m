classdef Container < matlab.ui.container.internal.UIContainer
    %uix.Container  Container base class
    %
    %  uix.Container is base class for containers that extend uicontainer.

    %  Copyright 2009-2020 The MathWorks, Inc.

    methods ( Access = protected, Static )

        function map = getThemeMap()
            %GETTHEMEMAP This method returns a struct describing the
            %relationship between class properties and theme attributes.

            map = struct( ...
                'BackgroundColor', '--mw-backgroundColor-primary' );

        end % getThemeMap

    end % protected static methods

end % classdef