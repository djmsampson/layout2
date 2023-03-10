classdef FlexDummy < uix.mixin.Flex
    %FLEXDUMMY Dummy class for testing uix.mixin.Flex.

    methods

        function pointer = dummySetPointer( obj, figure, pointer )

            obj.setPointer( figure, pointer )
            pointer = obj.Pointer;

        end % dummySetPointer

        function pointer = dummyUnsetPointer( obj )

            obj.unsetPointer()
            pointer = obj.Pointer;

        end % dummyUnsetPointer

    end % methods

end % class