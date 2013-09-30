classdef ( Hidden, Sealed ) LocationObserver < handle
    
    properties( SetAccess = private )
        Subject
        Location = [NaN NaN NaN NaN]
    end
    
    properties % ( Access = private )
        Figure = matlab.graphics.GraphicsPlaceholder.empty( [0 0] )
        Ancestors = matlab.graphics.GraphicsPlaceholder.empty( [0 1] )
        Units = cell( [0 1] )
        Positions = zeros( [0 4] )
        Offsets = zeros( [0 2] )
        Extent = [NaN NaN]
        LocationListeners = event.listener.empty( [0 1] )
        SizeListeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        LocationChange
    end
    
    methods
        
        function obj = LocationObserver( varargin )
            
            % Identify ancestors
            switch nargin
                case 1
                    subject = varargin{1};
                    [ancestors, figure] = uix.ancestors( subject );
                case 2
                    ancestors = varargin{1};
                    subject = ancestors(end);
                    figure = varargin{2};
                otherwise
                    narginchk( 1, 2 )
            end
            
            % Store subject and ancestors
            obj.Subject = subject;
            obj.Ancestors = ancestors;
            obj.Figure = figure;
            
            % Stop early for unrooted subjects
            if isempty( figure ), return, end
            
            % Store figure
            obj.Figure = ancestors(1);
            
            % Force update
            obj.update()
            
            % Create listeners
            for ii = 1:numel( ancestors )
                ancestor = ancestors(ii);
                locationListeners(ii,:) = event.listener( ancestor, ...
                    'LocationChange', @obj.onLocationChange ); %#ok<AGROW>
                sizeListeners(ii,:) = event.listener( ancestor, ...
                    'SizeChange', @obj.onSizeChange ); %#ok<AGROW>
            end
            
            % Store listeners
            obj.LocationListeners = locationListeners;
            obj.SizeListeners = sizeListeners;
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function update( obj, source, eventData )
            
            % Print debug information
            if nargin == 3
                fprintf( 1, 'Update due to %s on %s\n', eventData.EventName, class( source ) )
            end
            
            % Retrieve old values
            oldUnits = obj.Units;
            oldPositions = obj.Positions;
            oldOffsets = obj.Offsets;
            oldExtent = obj.Extent;
            oldLocation = obj.Location;
            
            % Compute modified values
            ancestors = obj.Ancestors;
            parents = [groot(); ancestors(1:end-1,:)];
            figure = obj.Figure;
            newUnits = get( ancestors, 'Units' );
            cNewPositions = get( ancestors, 'Position' );
            newPositions = vertcat( cNewPositions{:} );
            n = numel( ancestors );
            newOffsets = zeros( [n 2] ); % initialize
            for ii = 1:n
                offset = hgconvertunits( figure, newPositions(ii,:), ...
                    newUnits{ii}, 'pixels', parents(ii) );
                newOffsets(ii,:) = offset(1:2) - 1;
            end
            newExtent = offset(3:4);
            newLocation = [sum( newOffsets, 1 ) newExtent];
            
            % Store new values
            obj.Units = newUnits;
            obj.Positions = newPositions;
            obj.Offsets = newOffsets;
            obj.Extent = newExtent;
            obj.Location = newLocation;
            
            % Raise event
            if ~isequal( oldLocation, newLocation )
                notify( obj, 'LocationChange' )
            end
            
        end % update
        
    end % operations
    
    methods( Access = private )
        
        function onLocationChange( obj, source, eventData )
            
            % Update
            obj.update( source, eventData )
            
        end % onLocationChange
        
        function onSizeChange( obj, source, eventData )
            
            % Update
            obj.update( source, eventData )
            
        end % onSizeChange
        
    end % event handlers
    
end % classdef