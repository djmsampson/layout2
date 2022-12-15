classdef GetPositionTestDummy < handle
    %GETPOSITIONTESTDUMMY Test dummy for uix.getPosition.

    properties
        % Dummy ActivePositionProperty.
        ActivePositionProperty
        % Dummy Position.
        Position = zeros( 1, 4 )
    end % properties

    methods

        function obj = GetPositionTestDummy( activePositionProperty )

            if nargin == 1
                obj.ActivePositionProperty = activePositionProperty;
            else
                obj.ActivePositionProperty = 'position';
            end % if

        end % constructor

    end % methods

end % class
