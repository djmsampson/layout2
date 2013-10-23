classdef BoxPanel < uix.Box
    
    methods
        
        function obj = BoxPanel( varargin )
            
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
    
    methods( Access = protected )
        
        function redraw( obj )
            
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            c = numel( obj.Contents_ );
            widths = -ones( [c 1] );
            minimumWidths = ones( [c 1] );
            padding = obj.Padding_;
            spacing = obj.Spacing_;
            xSizes = uix.calcPixelSizes( bounds(3), widths, ...
                minimumWidths, padding, spacing );
            xPositions = [cumsum( [0; xSizes(1:c-1,:)] ) + padding + ...
                spacing * transpose( 0:c-1 ) + 1, xSizes];
            yPositions = [padding + 1, max( bounds(4) - 2 * padding, 1 )];
            yPositions = repmat( yPositions, [c 1] );
            positions = [xPositions(:,1), yPositions(:,1), ...
                xPositions(:,2), yPositions(:,2)];
            
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
        
    end % template methods
    
end % classdef