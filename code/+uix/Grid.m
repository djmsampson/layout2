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
    
    properties( Hidden, Access = public, Dependent )
        ColumnSizes % deprecated
        MinimumColumnSizes % deprecated
        RowSizes % deprecated
        MinimumRowSizes % deprecated
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
            assert( isvector( value ), 'uix:InvalidPropertyValue', ...
                'Property ''Widths'' must be a column vector.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Widths'' must be real and finite.' )
            if ~iscolumn( value )
                % Warn and transpose
                warning( 'uix:InvalidPropertyValue' , ...
                    'Property ''Widths'' must be a column vector.' )
                value = value';
            end
            n = numel( obj.Contents_ );
            nxo = numel( obj.Widths_ );
            nyo = numel( obj.Heights_ );
            nxn = numel( value );
            nyn = ceil( n / nxn );
            if nxn < min( [1 n] )
                error( 'uix:InvalidPropertyValue' , ...
                    'Property ''Widths'' must be non-empty for non-empty contents.' )
            elseif ceil( n / nyn ) < nxn
                error( 'uix:InvalidPropertyValue' , ...
                    'Size of property ''Widths'' must not lead to empty columns.' )
            elseif nxn > n
                error( 'uix:InvalidPropertyValue' , ...
                    'Size of property ''Widths'' must be no larger than size of contents.' )
            end
            
            % Set
            obj.Widths_ = value;
            if nxn < nxo % number of columns decreasing
                obj.MinimumWidths_(nxn+1:end,:) = [];
                if nyn > nyo % number of rows increasing
                    obj.Heights_(end+1:nyn,:) = -1;
                    obj.MinimumHeights_(end+1:nyn,:) = 1;
                end
            elseif nxn > nxo % number of columns increasing
                obj.MinimumWidths_(end+1:nxn,:) = -1;
                if nyn < nyo % number of rows decreasing
                    obj.Heights_(nyn+1:end,:) = [];
                    obj.MinimumHeights_(nyn+1:end,:) = [];
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
            if isequal( size( value ), size( obj.Widths_ ) )
                % OK
            elseif isequal( size( value' ), size( obj.Widths_ ) )
                % Warn and transpose
                warning( 'uix:InvalidPropertyValue', ...
                    'Size of property ''MinimumWidths'' must match size of contents.' )
                value = value';
            else
                % Error
                error( 'uix:InvalidPropertyValue', ...
                    'Size of property ''MinimumWidths'' must match size of contents.' )
            end
            
            % Set
            obj.MinimumWidths_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.MinimumWidths
        
        function value = get.ColumnSizes( obj )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''ColumnSizes'' is deprecated.  Use ''Widths'' instead.' )
            
            % Get
            value = obj.Widths;
            
        end % get.ColumnSizes
        
        function set.ColumnSizes( obj, value )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''ColumnSizes'' is deprecated.  Use ''Widths'' instead.' )
            
            % Get
            obj.Widths = value;
            
        end % set.ColumnSizes
        
        function value = get.MinimumColumnSizes( obj )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''MinimumColumnSizes'' is deprecated.  Use ''MinimumWidths'' instead.' )
            
            % Get
            value = obj.MinimumWidths;
            
        end % get.MinimumColumnSizes
        
        function set.MinimumColumnSizes( obj, value )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''MinimumColumnSizes'' is deprecated.  Use ''MinimumWidths'' instead.' )
            
            % Get
            obj.MinimumWidths = value;
            
        end % set.MinimumColumnSizes
        
        function value = get.Heights( obj )
            
            value = obj.Heights_;
            
        end % get.Heights
        
        function set.Heights( obj, value )
            
            % Check
            assert( isa( value, 'double' ), 'uix:InvalidPropertyValue', ...
                'Property ''Heights'' must be of type double.' )
            assert( isvector( value ), 'uix:InvalidPropertyValue', ...
                'Property ''Heights'' must be a column vector.' )
            assert( all( isreal( value ) ) && ~any( isinf( value ) ) && ...
                ~any( isnan( value ) ), 'uix:InvalidPropertyValue', ...
                'Elements of property ''Heights'' must be real and finite.' )
            if ~iscolumn( value )
                % Warn and transpose
                warning( 'uix:InvalidPropertyValue' , ...
                    'Property ''Heights'' must be a column vector.' )
                value = value';
            end
            n = numel( obj.Contents_ );
            nxo = numel( obj.Widths_ );
            nyo = numel( obj.Heights_ );
            nyn = numel( value );
            nxn = ceil( n / nyn );
            if nyn < min( [1 n] )
                error( 'uix:InvalidPropertyValue' , ...
                    'Property ''Heights'' must be non-empty for non-empty contents.' )
            elseif nyn > n
                error( 'uix:InvalidPropertyValue' , ...
                    'Size of property ''Heights'' must be no larger than size of contents.' )
            end
            
            % Set
            obj.Heights_ = value;
            if nyn < nyo % number of rows decreasing
                obj.MinimumHeights_(nyn+1:end,:) = [];
                if nxn > nxo % number of columns increasing
                    obj.Widths_(end+1:nxn,:) = -1;
                    obj.MinimumWidths_(end+1:nxn,:) = 1;
                end
            elseif nyn > nyo % number of rows increasing
                obj.MinimumHeights_(end+1:nyn,:) = -1;
                if nxn < nxo % number of columns decreasing
                    obj.Widths_(nxn+1:end,:) = [];
                    obj.MinimumWidths_(nxn+1:end,:) = [];
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
            if isequal( size( value ), size( obj.Heights_ ) )
                % OK
            elseif isequal( size( value' ), size( obj.Heights_ ) )
                % Warn and transpose
                warning( 'uix:InvalidPropertyValue', ...
                    'Size of property ''MinimumHeights'' must match size of contents.' )
                value = value';
            else
                % Error
                error( 'uix:InvalidPropertyValue', ...
                    'Size of property ''MinimumHeights'' must match size of contents.' )
            end
            
            % Set
            obj.MinimumHeights_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.MinimumHeights
        
        function value = get.RowSizes( obj )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''RowSizes'' is deprecated.  Use ''Heights'' instead.' )
            
            % Get
            value = obj.Heights;
            
        end % get.RowSizes
        
        function set.RowSizes( obj, value )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''RowSizes'' is deprecated.  Use ''Heights'' instead.' )
            
            % Get
            obj.Heights = value;
            
        end % set.RowSizes
        
        function value = get.MinimumRowSizes( obj )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''MinimumRowSizes'' is deprecated.  Use ''MinimumHeights'' instead.' )
            
            % Get
            value = obj.MinimumHeights;
            
        end % get.MinimumRowSizes
        
        function set.MinimumRowSizes( obj, value )
            
            % Warn
            warning( 'uix:DeprecatedProperty', ...
                'Property ''MinimumRowSizes'' is deprecated.  Use ''MinimumHeights'' instead.' )
            
            % Get
            obj.MinimumHeights = value;
            
        end % set.MinimumRowSizes
        
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
            nx = numel( widths );
            ny = numel( heights );
            n = numel( obj.Contents_ );
            xSizes = uix.calcPixelSizes( bounds(3), widths, ...
                minimumWidths, padding, spacing );
            xPositions = [cumsum( [0; xSizes(1:end-1,:)] ) + padding + ...
                spacing * transpose( 0:nx-1 ) + 1, xSizes];
            ySizes = uix.calcPixelSizes( bounds(4), heights, ...
                minimumHeights, padding, spacing );
            yPositions = [bounds(4) - cumsum( ySizes ) - padding - ...
                spacing * transpose( 0:ny-1 ) + 1, ySizes];
            [iy, ix] = ind2sub( [ny nx], transpose( 1:n ) );
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
            nx = numel( obj.Widths_ );
            ny = numel( obj.Heights_ );
            if n == 0
                obj.Widths_(end+1,:) = -1;
                obj.MinimumWidths_(end+1,:) = 1;
                obj.Heights_(end+1,:) = -1;
                obj.MinimumHeights_(end+1,:) = 1;
            elseif ceil( (n+1)/ny ) > nx
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