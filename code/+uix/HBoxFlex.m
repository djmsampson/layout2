classdef HBoxFlex < uix.HBox
    
    properties
        Dividers = matlab.graphics.GraphicsPlaceholder.empty( [0 1] )
        AncestryObserver
        AncestryListener
        LocationObserver
        MouseMotionListener
    end
    
    methods
        
        function obj = HBoxFlex( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.HBox( notmypv{:} );
            
            % Create observers
            ancestryObserver = uix.AncestryObserver( obj );
            
            % Store observers
            obj.AncestryObserver = ancestryObserver;
            
            % Create listeners
            ancestryListener = event.listener( ancestryObserver, ...
                'AncestryChange', @obj.onAncestryChange );
            
            % Store listeners
            obj.AncestryListener = ancestryListener;
            
            % Force ancestry change
            obj.onAncestryChange()
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods( Access = protected )
        
        function onChildAdded( obj, source, eventData )
            
            % Add divider if there will be more than one child
            if numel( obj.Contents_ ) > 0
                divider = uicontrol( 'Parent', [], 'Internal', true, ...
                    'Style', 'frame', 'Units', 'pixels' );
                divider.Parent = obj; % create then add
                obj.Dividers(end+1,:) = divider;
            end
            
            % Call superclass method
            onChildAdded@uix.HBox( obj, source, eventData );
            
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData )
            
            % Do nothing if container is being deleted
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            % Remove divider if there is more than one child
            if numel( obj.Contents_ ) > 1
                delete( obj.Dividers(end,:) )
                obj.Dividers(end,:) = [];
            end
            
            % Call superclass method
            onChildRemoved@uix.HBox( obj, source, eventData );
            
        end % onChildRemoved
        
        function onAncestryChange( obj, ~, ~ )
            
            % Create observers
            ancestryObserver = obj.AncestryObserver;
            ancestors = ancestryObserver.Ancestors;
            locationObserver = uix.LocationObserver( ancestors );
            
            % Store observers
            obj.LocationObserver = locationObserver;
            
            % Create listeners
            figure = ancestryObserver.Figure;
            if isempty( figure )
                mouseMotionListener = event.listener.empty( [0 0] );
            else
                mouseMotionListener = event.listener( figure, ...
                    'WindowMouseMotion', @obj.onMouseMotion );
            end
            
            % Store listeners
            obj.MouseMotionListener = mouseMotionListener;
            
        end % onAncestryChange
        
        function onMouseMotion( obj, ~, ~ )
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            point = ROOT.PointerLocation;
            location = obj.LocationObserver.Location;
            over = point(1) >= location(1) && ...
                point(1) < location(1) + location(3) && ...
                point(2) >= location(2) && ...
                point(2) < location(2) + location(4);
            if over
                disp MouseMotion
            end
            
        end
        
    end % event handlers
    
    methods( Access = protected )
        
        function reposition( obj, positions )
            
            % Call superclass method
            reposition@uix.HBox( obj, positions )
            
            % Set divider positions
            dividerPositions = [ ...
                positions(1:end-1,1)+positions(1:end-1,3), ...
                positions(1:end-1,2), ...
                diff( positions(:,1), 1, 1 ) - positions(1:end-1,3), ...
                positions(1:end-1,4)];
            dividerPositions(:,3) = max( dividerPositions(:,3), eps );
            dividers = obj.Dividers;
            for ii = 1:numel( dividers )
                obj.Dividers(ii).Position = dividerPositions(ii,:);
            end
            
        end % reposition
        
    end % methods
    
end % classdef