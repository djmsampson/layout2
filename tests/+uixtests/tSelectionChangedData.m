classdef tSelectionChangedData < glttestutilities.TestInfrastructure
    %TSELECTIONCHANGEDDATA Tests for uix.SelectionChangedData.

    methods ( Test, Sealed )

        function tConstructorReturnsScalarObject( testCase )

            % Create a uix.SelectionChangedData object.
            SD = uix.SelectionChangedData( 0, 1 );

            % Verify the size of the object.
            testCase.verifySize( SD, [1, 1], ...
                ['The uix.SelectionChangedData constructor did not return ', ...
                'a scalar object.'] )

        end % tConstructorReturnsScalarObject

        function tConstructorAssignsPropertyValues( testCase )

            % Create a uix.SelectionChangedData object.
            old = 0;
            new = 1;
            SD = uix.SelectionChangedData( old, new );

            % Verify that the 'OldValue' property has been stored.
            testCase.verifyEqual( SD.OldValue, old, ...
                ['The uix.SelectionChangedData constructor did not assign ', ...
                'the ''OldValue'' property correctly.'] )
            testCase.verifyEqual( SD.NewValue, new, ...
                ['The uix.SelectionChangedData constructor did not assign ', ...
                'the ''NewValue'' property correctly.'] )

        end % tConstructorAssignsPropertyValues

    end % methods ( Test, Sealed )

end % classdef