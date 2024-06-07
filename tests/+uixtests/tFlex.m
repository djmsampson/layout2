classdef tFlex < glttestutilities.TestInfrastructure
    %TFLEX Tests for uix.mixin.Flex.

    methods ( Test, Sealed )

        function tDestructorUnsetsPointer( testCase )

            % Assume we are in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Create a dummy subclass.
            FD = glttestutilities.FlexDummy();

            % Set the pointer.
            fig = testCase.ParentFixture.Parent;
            FD.dummySetPointer( fig, 'circle' );

            % Delete the dummy.
            delete( FD )

            % Check the figure's 'Pointer' property.
            testCase.verifyEqual( fig.Pointer, 'arrow', ...
                ['Deleting a subclass object of uix.mixin.Flex did ', ...
                'not unset the figure''s ''Pointer'' property.'] )

        end % tDestructorUnsetsPointer

        function tSetPointerSetsPointer( testCase )

            % Assume we are in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Create a dummy subclass.
            FD = glttestutilities.FlexDummy();

            % Set the pointer.
            fig = testCase.ParentFixture.Parent;
            pointer = 'circle';
            FD.dummySetPointer( fig, pointer );

            % Check the figure's 'Pointer' property.
            testCase.verifyEqual( fig.Pointer, pointer, ...
                ['Setting the pointer on a subclass object of ', ...
                'uix.mixin.Flex did not set the figure''s ', ...
                '''Pointer'' property correctly.'] )

        end % tSetPointerSetsPointer

        function tSettingPointerUnsetsPointerIfSet( testCase )

            % Assume we are in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Create a dummy subclass.
            FD = glttestutilities.FlexDummy();

            % Set the pointer.
            fig = testCase.ParentFixture.Parent;
            initialPointer = 'circle';
            FD.dummySetPointer( fig, initialPointer );

            % Set the pointer again.
            newPointer = 'hand';
            FD.dummySetPointer( fig, newPointer );

            % Check the figure's 'Pointer' property.
            testCase.verifyEqual( fig.Pointer, newPointer, ...
                ['Setting the pointer twice on a subclass object of ', ...
                'uix.mixin.Flex did not set the figure''s ', ...
                '''Pointer'' property correctly.'] )

        end % tSetPointerSetsPointer

        function tUnsetPointerUnsetsPointer( testCase )

            % Assume we are in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Create a dummy subclass.
            FD = glttestutilities.FlexDummy();

            % Set the pointer.
            fig = testCase.ParentFixture.Parent;
            initialPointer = 'circle';
            FD.dummySetPointer( fig, initialPointer );

            % Unset the pointer.
            pointer = FD.dummyUnsetPointer();

            % Check the return value.
            testCase.verifyEqual( pointer, 'unset', ...
                ['Unsetting the pointer on a subclass object of ', ...
                'uix.mixin.Flex did not return the value ''unset''.'] )

            % Check the figure's 'Pointer' property.
            testCase.verifyEqual( fig.Pointer, 'arrow', ...
                ['Unsetting the pointer on a subclass object of ', ...
                'uix.mixin.Flex did not set the figure''s ', ...
                '''Pointer'' property correctly.'] )

        end % tUnsetPointerUnsetsPointer

        function tUnsetPointerErrorsWhenPointerIsAlreadyUnset( testCase )

            % Assume we are in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Create a dummy subclass.
            FD = glttestutilities.FlexDummy();

            % Verify that an error is thrown when a call to unsetPointer()
            % is made.
            f = @() FD.dummyUnsetPointer();
            testCase.verifyError( f, 'uix:InvalidOperation', ...
                ['Unsetting the pointer on a subclass object of ', ...
                'uix.mixin.Flex when the pointer was already unset ', ...
                'did not throw an error with the expected ', ...
                'ID (uix:InvalidOperation).'] )

        end % tUnsetPointerErrorsWhenPointerIsAlreadyUnset

    end % methods ( Test, Sealed )

end % classdef