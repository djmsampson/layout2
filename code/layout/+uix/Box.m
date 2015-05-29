classdef Box < uix.Container & uix.mixin.Container
    %uix.Box  Box and grid base class
    %
    %  uix.Box is a base class for containers with spacing between
    %  contents.
    
    %  Copyright 2009-2014 The MathWorks, Inc.
    %  $Revision$ $Date$
    
    properties( Access = public, Dependent, AbortSet )
        Spacing = 0 % space between contents, in pixels
    end
    
    properties( Access = protected )
        Spacing_ = 0 % backing for Spacing
    end
    
    methods
        
        function obj = Box()
            %uix.Box  Initialize
            %
            %  b@uix.Box() initializes the box b.
            
            % Call superclass constructors
            obj@uix.Container()
            obj@uix.mixin.Container()
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Spacing( obj )
            
            value = obj.Spacing_;
            
        end % get.Spacing
        
        function set.Spacing( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Spacing'' must be a non-negative scalar.' )
            
            % Set
            obj.Spacing_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Spacing
        
    end % accessors
    
end % classdef