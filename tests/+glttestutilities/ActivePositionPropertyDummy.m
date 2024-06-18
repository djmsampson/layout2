classdef ActivePositionPropertyDummy < handle
    %ACTIVEPOSITIONPROPERTYTESTDUMMY Dummy for use in tests for
    %uix.getPosition and uix.setPosition.

    properties
        % Dummy ActivePositionProperty.
        ActivePositionProperty
        % Dummy Position.
        Position = zeros( 1, 4 )
    end % properties

    methods

        function obj = ActivePositionPropertyDummy( ...
                activePositionProperty )

            if nargin == 1
                obj.ActivePositionProperty = activePositionProperty;
            else
                obj.ActivePositionProperty = 'position';
            end % if

        end % constructor

    end % methods

end % classdef
