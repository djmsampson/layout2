classdef HBoxFlex < uix.HBox
    
    properties
        Dividers = uix.Divider.empty( [0 1] )
        AncestryObserver
        AncestryListener
        LocationObserver
        MousePressListener
        MouseReleaseListener
        MouseMotionListener
        Over = false
        Dragging = false
        ActiveDivider = uix.Divider.empty( [0 0] )
        OldPointer = 'unset'
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
                divider = uix.Divider( 'Parent', obj, ...
                    'Orientation', 'vertical', 'Markings', 'on' );
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
                mousePressListener = event.listener.empty( [0 0] );
                mouseReleaseListener = event.listener.empty( [0 0] );
                mouseMotionListener = event.listener.empty( [0 0] );
            else
                mousePressListener = event.listener( figure, ...
                    'WindowMousePress', @obj.onMousePress );
                mouseReleaseListener = event.listener( figure, ...
                    'WindowMouseRelease', @obj.onMouseRelease );
                mouseMotionListener = event.listener( figure, ...
                    'WindowMouseMotion', @obj.onMouseMotion );
            end
            
            % Store listeners
            obj.MousePressListener = mousePressListener;
            obj.MouseReleaseListener = mouseReleaseListener;
            obj.MouseMotionListener = mouseMotionListener;
            
        end % onAncestryChange
        
        function onMousePress( obj, ~, ~ )
            
            disp MousePress
            
        end % onMousePress
        
        function onMouseRelease( obj, ~, ~ )
            
            disp MouseRelease
            
        end % onMouseRelease
        
        function onMouseMotion( obj, ~, ~ )
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            if obj.Dragging
                
                disp Dragging!
                
            else
                
                point = ROOT.PointerLocation - ...
                    obj.LocationObserver.Location(1:2) + [1 1];
                cPositions = get( obj.Dividers, {'Position'} );
                positions = vertcat( cPositions{:} );
                if isempty( positions )
                    overs = true( size( positions ) );
                else
                    overs = point(1) >= positions(:,1) & ...
                        point(1) < positions(:,1) + positions(:,3) & ...
                        point(2) >= positions(:,2) & ...
                        point(2) < positions(:,2) + positions(:,4);
                end
                isOver = any( overs );
                wasOver = obj.Over;
                if wasOver ~= isOver
                    figure = obj.AncestryObserver.Figure;
                    if isOver % enter
                        obj.OldPointer = figure.Pointer;
                        figure.Pointer = 'hand';
                    else % leave
                        figure.Pointer = obj.OldPointer;
                        obj.OldPointer = 'unset';
                    end
                    obj.Over = isOver;
                end
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