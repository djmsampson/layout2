classdef ( Hidden, Sealed ) LocationObserver < handle
    
    properties( SetAccess = private )
        Subject
        Location = [NaN NaN NaN NaN]
    end
    
    properties( Access = private )
        Figure = matlab.graphics.GraphicsPlaceholder.empty( [0 0] )
        Ancestors = matlab.graphics.GraphicsPlaceholder.empty( [0 1] )
        Offsets = zeros( [0 2] )
        Extent = [NaN NaN]
        LocationListeners = event.listener.empty( [0 1] )
        SizeListeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        LocationChange
    end
    
    methods
        
        function obj = LocationObserver( in )
            %uix.LocationObserver  Location observer
            %
            %  o = uix.LocationObserver(s) creates a location observer for
            %  the subject s.
            %
            %  o = uix.LocationObserver(a) creates a location observer
            %  for the figure-to-subject ancestry a.
            %
            %  A location observer assumes a fixed ancestry.  Use an
            %  ancestry observer to monitor changes to ancestry, and create
            %  a new location observer when ancestry changes.
            
            % Handle inputs
            if isscalar( in )
                subject = in;
                assert( ishghandle( subject ) && ...
                    isequal( size( subject ), [1 1] ) && ...
                    ~isa( subject, 'matlab.ui.Root' ), ...
                    'uix.InvalidArgument', ...
                    'Subject must be a graphics object.' )
                [ancestors, figure] = uix.ancestors( subject );
            else
                ancestors = in;
                assert( all( ishghandle( ancestors ) ) && ...
                    iscolumn( ancestors ) && ndims( ancestors ) == 2, ...
                    'uix.InvalidArgument', ...
                    'Ancestry must be a vector of graphics objects.' ) %#ok<ISMAT>
                subject = ancestors(end);
                figure = ancestors(1);
                cParents = get( ancestors, {'Parent'} );
                parents = vertcat( cParents{:} );
                assert( isequal( ancestors(1:end-1,:), parents(2:end,:) ), ...
                    'uix:InvalidArgument', 'Inconsistent ancestry.' )
                assert( isequal( cParents{1}, groot() ) || isempty( cParents{1} ), ...
                    'uix:InvalidArgument', 'Incomplete ancestry.' )
            end
            
            % Store subject, ancestors and figure
            obj.Subject = subject;
            obj.Ancestors = ancestors;
            obj.Figure = figure;
            
            % Stop early for unrooted subjects
            if isempty( figure ), return, end
            
            % Force update
            obj.update()
            
            % Create listeners
            cbLocationChange = @obj.onLocationChange;
            cbSizeChange = @obj.onSizeChange;
            for ii = 1:numel( ancestors )
                ancestor = ancestors(ii);
                locationListeners(ii,:) = event.listener( ancestor, ...
                    'LocationChange', cbLocationChange ); %#ok<AGROW>
                sizeListeners(ii,:) = event.listener( ancestor, ...
                    'SizeChange', cbSizeChange ); %#ok<AGROW>
            end
            
            % Store listeners
            obj.LocationListeners = locationListeners;
            obj.SizeListeners = sizeListeners;
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function update( obj, source )
            %update  Update location observer
            %
            %  o.update() updates the state of the location observer from
            %  scratch.
            %
            %  o.update(a) updates the state of the location observer in
            %  response to an event on the ancestor a.
            
            % Retrieve ancestors, parents and figure
            ancestors = obj.Ancestors;
            parents = [groot(); ancestors(1:end-1,:)];
            figure = obj.Figure;
            
            if nargin == 1 % recompute from scratch
                
                % Compute units, positions and offsets of all ancestors
                units = get( ancestors, {'Units'} );
                cPositions = get( ancestors, {'Position'} );
                positions = vertcat( cPositions{:} );
                n = numel( ancestors );
                offsets = zeros( [n 2] ); % initialize
                for ii = 1:n
                    pixel = hgconvertunits( figure, positions(ii,:), ...
                        units{ii}, 'pixels', parents(ii) );
                    offsets(ii,:) = pixel(1:2) - 1;
                end
                extent = pixel(3:4);
                
            else % specified modified ancestor
                
                % Compute units, position and offset of modified ancestor
                tf = ancestors == source;
                ancestor = ancestors(tf);
                parent = parents(tf);
                pixel = hgconvertunits( figure, ancestor.Position, ...
                    ancestor.Units, 'pixels', parent );
                offset = pixel(1:2) - 1;
                offsets = obj.Offsets;
                offsets(tf,:) = offset;
                if tf(end) % subject
                    extent = pixel(3:4);
                else
                    extent = obj.Extent;
                end
                
            end
            
            % Compute location
            location = [sum( offsets, 1 ) extent];
            
            % Store properties
            obj.Offsets = offsets;
            obj.Extent = extent;
            obj.Location = location;
            
            % Raise event
            notify( obj, 'LocationChange' )
            
        end % update
        
    end % operations
    
    methods( Access = private )
        
        function onLocationChange( obj, source, ~ )
            
            % Update
            obj.update( source )
            
        end % onLocationChange
        
        function onSizeChange( obj, source, ~ )
            
            % Update
            obj.update( source )
            
        end % onSizeChange
        
    end % event handlers
    
end % classdef