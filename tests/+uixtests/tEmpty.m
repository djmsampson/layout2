classdef tEmpty < utilities.mixin.EmptyTests
    %TEMPTY Tests for uix.Empty. Empty is not a container, so does not
    %utilize the shared container tests.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uix.Empty'}
    end % properties ( TestParameter )

end % class