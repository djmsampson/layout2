classdef CardPanel < uix.Container
    
    properties( Access = public, Dependent, AbortSet )
        Selection % selected contents
    end
    
    properties( Access = protected )
        Selection_ = 0 % backing for Selection
    end
    
    methods
        
        function obj = CardPanel( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.Container( notmypv{:} );
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
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
        
        function redraw( obj )
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            padding = obj.Padding_;
            xSizes = uix.calcPixelSizes( bounds(3), -1, 1, padding, 0 );
            ySizes = uix.calcPixelSizes( bounds(4), -1, 1, padding, 0 );
            position = [padding+1 padding+1 xSizes ySizes];
            
            % Set positions and visibility
            children = obj.Contents_;
            selection = obj.Selection_;
            for ii = 1:numel( children )
                child = children(ii);
                if ii == selection
                    child.Units = 'pixels';
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        child.( child.ActivePositionProperty ) = position;
                    else
                        child.Position = position;
                    end
                    child.Visible = 'on';
                else
                    child.Visible = 'off';
                end
            end
            
        end % redraw
        
        function addChild( obj, child )
            
            % Select new content
            obj.Selection_ = numel( obj.Contents_ ) + 1;
            
            % Call superclass method
            addChild@uix.Container( obj, child )
            
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
            removeChild@uix.Container( obj, child )
            
        end % onChildRemoved
        
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
            reorder@uix.Container( obj, indices )
            
        end % reorder
        
    end % template methods
    
end % classdef