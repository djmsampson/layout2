classdef tSelectionData < glttestutilities.TestInfrastructure
    %TSELECTIONDATA Tests for uix.SelectionData.

    methods ( Test, Sealed )

        function tConstructorReturnsScalarObject( testCase )

            % Create a uix.SelectionData object.
            SD = uix.SelectionData( 0, 1 );

            % Verify the size of the object.
            testCase.verifySize( SD, [1, 1], ...
                ['The uix.SelectionData constructor did not return ', ...
                'a scalar object.'] )

        end % tConstructorReturnsScalarObject

        function tConstructorAssignsPropertyValues( testCase )

            % Create a uix.SelectionData object.
            old = 0;
            new = 1;
            SD = uix.SelectionData( old, new );

            % Verify that the 'OldValue' property has been stored.
            testCase.verifyEqual( SD.OldValue, old, ...
                ['The uix.SelectionData constructor did not assign ', ...
                'the ''OldValue'' property correctly.'] )
            testCase.verifyEqual( SD.NewValue, new, ...
                ['The uix.SelectionData constructor did not assign ', ...
                'the ''NewValue'' property correctly.'] )

        end % tConstructorAssignsPropertyValues

    end % methods ( Test, Sealed )

end % classdef