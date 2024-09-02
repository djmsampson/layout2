classdef Box < uix.Container & uix.mixin.Container
    %uix.Box  Box and grid base class
    %
    %  uix.Box is a base class for containers with spacing between
    %  contents.

    %  Copyright 2009-2020 The MathWorks, Inc.

    properties( Access = public, Dependent, AbortSet )
        Spacing = 0 % space between contents, in pixels
    end

    properties( Access = protected )
        Spacing_ = 0 % backing for Spacing
    end

    methods

        function value = get.Spacing( obj )

            value = obj.Spacing_;

        end % get.Spacing

        function set.Spacing( obj, value )

            % Check
            try
                value = double( value ); % convert
                assert( isscalar( value ) && isreal( double ) && ...
                    ~isinf( value ) && ~isnan( value ) && value >= 0 )
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Error setting property ''%s'' of class ''%s''.\n%s', ...
                    'Spacing', class( obj ), ...
                    'Value must be a nonnegative scalar double.' ) )
            end

            % Set
            obj.Spacing_ = value;

            % Mark as dirty
            obj.Dirty = true;

        end % set.Spacing

    end % accessors

end % classdef