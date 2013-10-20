classdef Grid < uix.Box
    
    properties( Access = public, Dependent, AbortSet )
        Widths % widths of contents, in pixels and/or weights
        MinimumWidths % minimum widths of contents, in pixels
        Heights % heights of contents, in pixels and/or weights
        MinimumHeights % minimum heights of contents, in pixels
    end
    
    properties( Access = protected )
        Widths_ = zeros( [0 1] ) % backing for Widths
        MinimumWidths_ = zeros( [0 1] ) % backing for MinimumWidths
        Heights_ = zeros( [0 1] ) % backing for Heights
        MinimumHeights_ = zeros( [0 1] ) % backing for MinimumHeights
    end
    
    methods
        
        function obj = Grid( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.Box( notmypv{:} );
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Widths( obj )
            
            value = obj.Widths_;
            
        end % get.Widths
        
        function set.Widths( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Widths'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Widths'' must be real and finite.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''Widths'' must match size of contents.' )
            n = numel( obj.Contents_ );
            co = numel( obj.Widths_ );
            ro = numel( obj.Heights_ );
            cn = numel( value );
            rn = ceil( n / cn );
            if cn < min( [1 n] )
                error( 'uix:InvalidPropertyValue' , ...
                    'Property ''Widths'' must be non-empty for non-empty contents.' )
            elseif ceil( n / rn ) < cn
                error( 'uix:InvalidPropertyValue' , ...
                    'Size of property ''Widths'' must not lead to empty columns.' )
            elseif cn > n
                error( 'uix:InvalidPropertyValue' , ...
                    'Size of property ''Widths'' must be no larger than size of contents.' )
            end
            
            % Set
            obj.Widths_ = value;
            if cn < co % number of columns decreasing
                obj.MinimumWidths_(cn+1:end,:) = [];
                if rn > ro % number of rows increasing
                    obj.Heights_(end+1:rn,:) = -1;
                    obj.MinimumHeights_(end+1:rn,:) = 1;
                end
            elseif cn > co % number of columns increasing
                obj.MinimumWidths_(end+1:cn,:) = -1;
                if rn < ro % number of rows decreasing
                    obj.Heights_(rn+1:end,:) = [];
                    obj.MinimumHeights_(rn+1:end,:) = [];
                end
            end
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Widths
        
        function value = get.MinimumWidths( obj )
            
            value = obj.MinimumWidths_;
            
        end % get.MinimumWidths
        
        function set.MinimumWidths( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''MinimumWidths'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                all( value >= 0 ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''MinimumWidths'' must be non-negative.' )
            assert( isequal( size( value ), size( obj.Widths_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''MinimumWidths'' must match size of contents.' )
            
            % Set
            obj.MinimumWidths_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.MinimumWidths
        
        function value = get.Heights( obj )
            
            value = obj.Heights_;
            
        end % get.Heights
        
        function set.Heights( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Heights'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Heights'' must be real and finite.' )
            assert( isequal( size( value ), size( obj.Contents_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''Heights'' must match size of contents.' )
            n = numel( obj.Contents_ );
            co = numel( obj.Widths_ );
            ro = numel( obj.Heights_ );
            rn = numel( value );
            cn = ceil( n / rn );
            if rn < min( [1 n] )
                error( 'uix:InvalidPropertyValue' , ...
                    'Property ''Heights'' must be non-empty for non-empty contents.' )
            elseif rn > n
                error( 'uix:InvalidPropertyValue' , ...
                    'Size of property ''Heights'' must be no larger than size of contents.' )
            end
            
            % Set
            obj.Heights_ = value;
            if rn < ro % number of rows decreasing
                obj.MinimumHeights_(rn+1:end,:) = [];
                if cn > co % number of columns increasing
                    obj.Widths_(end+1:cn,:) = -1;
                    obj.MinimumWidths_(end+1:cn,:) = 1;
                end
            elseif rn > ro % number of rows increasing
                obj.MinimumHeights_(end+1:rn,:) = -1;
                if cn < co % number of columns decreasing
                    obj.Widths_(cn+1:end,:) = [];
                    obj.MinimumWidths_(cn+1:end,:) = [];
                end
            end
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Heights
        
        function value = get.MinimumHeights( obj )
            
            value = obj.MinimumHeights_;
            
        end % get.MinimumHeights
        
        function set.MinimumHeights( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''MinimumHeights'' must be of type double.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                all( value >= 0 ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''MinimumHeights'' must be non-negative.' )
            assert( isequal( size( value ), size( obj.Heights_ ) ), ...
                'uix:InvalidPropertyValue', ...
                'Size of property ''MinimumHeights'' must match size of contents.' )
            
            % Set
            obj.MinimumHeights_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.MinimumHeights
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            widths = obj.Widths_;
            minimumWidths = obj.MinimumWidths_;
            heights = obj.Heights_;
            minimumHeights = obj.MinimumHeights_;
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            c = numel( widths );
            r = numel( heights );
            n = numel( obj.Contents_ );
            xSizes = uix.calcPixelSizes( bounds(3), widths, ...
                minimumWidths, padding, spacing );
            xPositions = [cumsum( [0; xSizes(1:end-1,:)] ) + padding + ...
                spacing * transpose( 0:c-1 ) + 1, xSizes];
            ySizes = uix.calcPixelSizes( bounds(4), heights, ...
                minimumHeights, padding, spacing );
            yPositions = [bounds(4) - cumsum( ySizes ) - padding - ...
                spacing * transpose( 0:r-1 ) + 1, ySizes];
            [iy, ix] = ind2sub( [r c], transpose( 1:n ) );
            positions = [xPositions(ix,1), yPositions(iy,1), ...
                xPositions(ix,2), yPositions(iy,2)];
            
            % Set positions
            children = obj.Contents_;
            for ii = 1:numel( children )
                child = children(ii);
                child.Units = 'pixels';
                if isa( child, 'matlab.graphics.axis.Axes' )
                    child.( child.ActivePositionProperty ) = positions(ii,:);
                else
                    child.Position = positions(ii,:);
                end
            end
            
        end % redraw
        
        function addChild( obj, child )
            
            % Add column and even a row if necessary
            n = numel( obj.Contents_ );
            c = numel( obj.Widths_ );
            r = numel( obj.Heights_ );
            if n == 0
                obj.Widths_(end+1,:) = -1;
                obj.MinimumWidths_(end+1,:) = 1;
                obj.Heights_(end+1,:) = -1;
                obj.MinimumHeights_(end+1,:) = 1;
            elseif ceil( (n+1)/r ) > c
                obj.Widths_(end+1,:) = -1;
                obj.MinimumWidths_(end+1,:) = 1;
            end
            
            % Call superclass method
            addChild@uix.Box( obj, child )
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Remove column and even row if necessary
            n = numel( obj.Contents_ );
            c = numel( obj.Widths_ );
            r = numel( obj.Heights_ );
            if n == 1
                obj.Widths_(end,:) = [];
                obj.MinimumWidths_(end,:) = [];
                obj.Heights_(end,:) = [];
                obj.MinimumHeights_(end,:) = [];
            elseif c == 1
                obj.Heights_(end,:) = [];
                obj.MinimumHeights_(end,:) = [];
            elseif ceil( (n-1)/r ) < c
                obj.Widths_(end,:) = [];
                obj.MinimumWidths_(end,:) = [];
            end
            
            % Call superclass method
            removeChild@uix.Box( obj, child )
            
        end % onChildRemoved
        
    end % template methods
    
end % classdef