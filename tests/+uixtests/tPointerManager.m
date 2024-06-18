classdef tPointerManager < glttestutilities.TestInfrastructure
    %TPOINTERMANAGER Tests for uix.PointerManager.    
    
    methods ( Test, Sealed )

        function tGetInstanceReturnsScalarObject( testCase )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Get an instance of the PointerManager.
            fig = testCase.ParentFixture.Parent;
            PM = uix.PointerManager.getInstance( fig );

            % Verify that the object is scalar.
            testCase.verifySize( PM, [1, 1], ...
                ['The getInstance() method of uix.PointerManager ', ...
                'did not return a scalar object.'] )

            % Test again.
            PM = uix.PointerManager.getInstance( fig );
            testCase.verifySize( PM, [1, 1], ...
                ['The getInstance() method of uix.PointerManager ', ...
                'did not return a scalar object.'] )

        end % tGetInstanceReturnsScalarObject

        function tSettingAndUnsettingPointerIsCorrect( testCase )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Get an instance of the PointerManager.
            fig = testCase.ParentFixture.Parent;
            PM = uix.PointerManager.getInstance( fig );

            % Set the figure pointer.
            pointer = 'circle';
            PM.setPointer( fig, pointer );
            testCase.verifyEqual( fig.Pointer, pointer, ...
                ['The setPointer() method of uix.PointerManager ', ...
                'did not set the figure''s ''Pointer'' property.'] )

            % Unset it.
            PM.unsetPointer( fig, 1 )
            testCase.verifyEqual( fig.Pointer, 'arrow', ...
                ['The unsetPointer() method of uix.PointerManager ', ...
                'did not unset the figure''s ''Pointer'' property.'] )

        end % tSettingAndUnsettingPointerIsCorrect

        function tSettingFigurePointerIsWarningFree( testCase )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Get an instance of the PointerManager.
            fig = testCase.ParentFixture.Parent;
            uix.PointerManager.getInstance( fig );

            % Verify that setting the figure's 'Pointer' property is
            % warning-free.
            setter = @() set( fig, 'Pointer', 'circle' );
            testCase.verifyWarningFree( setter, ...
                ['Setting the figure''s ''Pointer'' property when ', ...
                'a uix.PointerManager object is managing the figure ', ...
                'is not warning-free.'] )

        end % tSettingFigurePointerIsWarningFree
        
    end % methods ( Test, Sealed )

end % classdef