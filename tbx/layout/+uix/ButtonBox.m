classdef ButtonBox < uix.Box
    %uix.ButtonBox  Button box base class
    %
    %  uix.ButtonBox is a base class for containers that lay out buttons.

    %  Copyright 2009-2020 The MathWorks, Inc.

    properties( Access = public, Dependent, AbortSet )
        ButtonSize % button size, in pixels
        HorizontalAlignment % horizontal alignment [left|center|right]
        VerticalAlignment % vertical alignment [top|middle|bottom]
    end

    properties( Access = protected )
        ButtonSize_ = [60 20] % backing for ButtonSize
        HorizontalAlignment_ = 'center' % backing for HorizontalAlignment
        VerticalAlignment_ = 'middle' % backing for VerticalAlignment
    end

    methods

        function value = get.ButtonSize( obj )

            value = obj.ButtonSize_;

        end % get.ButtonSize

        function set.ButtonSize( obj, value )

            % Check
            try
                value = double( value ); % convert
                assert( isequal( size( value ), [1 2] ) && ...
                    all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                    ~any( isnan( value ) ) && all( value > 0 ) )
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Error setting property ''%s'' of class ''%s''.\n%s', ...
                    'ButtonSize', class( obj ), ...
                    'Value must be a 1x2 positive double array.' ) )
            end

            % Set
            obj.ButtonSize_ = value;

            % Mark as dirty
            obj.Dirty = true;

        end % set.ButtonSize

        function value = get.HorizontalAlignment( obj )

            value = obj.HorizontalAlignment_;

        end % get.HorizontalAlignment

        function set.HorizontalAlignment( obj, value )

            % Check
            try
                value = char( value ); % convert
                assert( ismember( value, {'left';'center';'right'} ) )
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Error setting property ''%s'' of class ''%s''.\n%s', ...
                    'HorizontalAlignment', class( obj ), ...
                    'Value must be ''left'', ''right'', or ''center''.' ) )
            end

            % Set
            obj.HorizontalAlignment_ = value;

            % Mark as dirty
            obj.Dirty = true;

        end % set.HorizontalAlignment

        function value = get.VerticalAlignment( obj )

            value = obj.VerticalAlignment_;

        end % get.VerticalAlignment

        function set.VerticalAlignment( obj, value )

            % Check
            try
                value = char( value ); % convert
                assert( ismember( value, {'top';'middle';'bottom'} ) )
            catch
                throwAsCaller( MException( 'uix:InvalidPropertyValue', ...
                    'Error setting property ''%s'' of class ''%s''.\n%s', ...
                    'VerticalAlignment', class( obj ), ...
                    'Value must be ''top'', ''bottom'', or ''middle''.' ) )
            end

            % Set
            obj.VerticalAlignment_ = value;

            % Mark as dirty
            obj.Dirty = true;

        end % set.VerticalAlignment

    end % accessors

end % classdef