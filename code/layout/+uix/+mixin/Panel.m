classdef Panel < uix.mixin.Container
    %uix.mixin.Panel  Panel mixin
    %
    %  uix.mixin.Panel is a mixin class used by uix.Panel, uix.CardPanel,
    %  uix.BoxPanel and uix.TabPanel to provide various properties and
    %  template methods.
    %
    %  p@uix.mixin.Panel() initializes the panel p.
    
    %  Copyright 2009-2014 The MathWorks, Inc.
    %  $Revision: 1077 $ $Date: 2015-03-19 16:44:14 +0000 (Thu, 19 Mar 2015) $
    
    properties( Access = public, Dependent, AbortSet )
        Selection % selected contents
    end
    
    properties( Access = protected )
        Selection_ = 0 % backing for Selection
    end
    
    properties( Access = protected )
        G1218142 = false % bug flag
    end
    
    methods
        
        function obj = Panel()
            %uix.mixin.Panel  Initialize
            %
            %  p@uix.mixin.Panel() initializes the panel p.
            
            % Call superclass constructor
            obj@uix.mixin.Container()
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Selection( obj )
            
            value = obj.Selection_;
            
        end % get.Selection
        
        function set.Selection( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Selection'' must be of type double.' )
            assert( isequal( size( value ), [1 1] ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Selection'' must be scalar.' )
            assert( isreal( value ) && rem( value, 1 ) == 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Selection'' must be an integer.' )
            n = numel( obj.Contents_ );
            if n == 0
                assert( value == 0, 'uix:InvalidPropertyValue', ...
                    'Property ''Selection'' must be 0 for a container with no children.' )
            else
                assert( value >= 1 && value <= n, 'uix:InvalidPropertyValue', ...
                    'Property ''Selection'' must be between 1 and the number of children.' )
            end
            
            % Set
            obj.Selection_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Selection
        
    end % accessors
    
    methods( Access = protected )
        
        function addChild( obj, child )
            
            % Check for bug
            if verLessThan( 'MATLAB', '8.5' ) && strcmp( child.Visible, 'off' )
                obj.G1218142 = true;
            end
            
            % Select new content
            obj.Selection_ = numel( obj.Contents_ ) + 1;
            
            % Call superclass method
            addChild@uix.mixin.Container( obj, child )
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Adjust selection if required
            contents = obj.Contents_;
            n = numel( contents );
            index = find( contents == child );
            selection = obj.Selection_;
            if index == 1 && selection == 1 && n > 1
                % retain selection
            elseif index <= selection
                obj.Selection_ = selection - 1;
            else
                % retain selection
            end
            
            % Call superclass method
            removeChild@uix.mixin.Container( obj, child )
            
        end % removeChild
        
        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).
            
            % Reorder
            selection = obj.Selection_;
            if selection ~= 0
                obj.Selection_ = find( indices == selection );
            end
            
            % Call superclass method
            reorder@uix.mixin.Container( obj, indices )
            
        end % reorder
        
    end % template methods
    
end % classdef