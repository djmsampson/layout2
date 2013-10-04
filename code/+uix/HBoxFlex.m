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
        ActiveDivider = 0
        ButtonDownLocation = [NaN NaN]
        OldDividerPosition = [NaN NaN NaN NaN]
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
            
            % Restack
            obj.restack()
            
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
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            [tf, loc] = obj.isMouseOverDivider();
            if tf
                obj.ActiveDivider = loc;
                obj.ButtonDownLocation = ROOT.PointerLocation;
                obj.OldDividerPosition = obj.Dividers(loc).Position;
            end
            
        end % onMousePress
        
        function onMouseRelease( obj, ~, ~ )
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            loc = obj.ActiveDivider;
            if loc == 0, return, end
            startLocation = obj.ButtonDownLocation;
            finishLocation = ROOT.PointerLocation;
            delta = finishLocation(1) - startLocation(1);
            obj.Dividers(obj.ActiveDivider).Position = ...
                obj.OldDividerPosition + [delta 0 0 0];
            obj.ActiveDivider = 0;
            obj.ButtonDownLocation = [NaN NaN];
            obj.OldDividerPosition = [NaN NaN NaN NaN];
            
        end % onMouseRelease
        
        function onMouseMotion( obj, ~, ~ )
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            if obj.ActiveDivider == 0
                
                isOver = obj.isMouseOverDivider();
                wasOver = obj.Over;
                if wasOver ~= isOver
                    figure = obj.AncestryObserver.Figure;
                    if isOver % enter
                        obj.OldPointer = figure.Pointer;
                        figure.Pointer = 'left';
                    else % leave
                        figure.Pointer = obj.OldPointer;
                        obj.OldPointer = 'unset';
                    end
                    obj.Over = isOver;
                end
                
            else
                
                startLocation = obj.ButtonDownLocation;
                finishLocation = ROOT.PointerLocation;
                delta = finishLocation(1) - startLocation(1);
                obj.Dividers(obj.ActiveDivider).Position = ...
                    obj.OldDividerPosition + [delta 0 0 0];
                
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
        
        function [tf, loc] = isMouseOverDivider( obj )
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
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
            index = find( overs, 1, 'first' );
            if isempty( index )
                tf = false;
                loc = 0;
            else
                tf = true;
                loc = index;
            end
            
        end % isMouseOverDivider
        
        function restack( obj )
            
            childAddedListener = obj.ChildAddedListener;
            childRemovedListener = obj.ChildRemovedListener;
            childAddedListener.Enabled = false;
            childRemovedListener.Enabled = false;
            dividers = obj.Dividers;
            for ii = 1:numel( dividers )
                divider = dividers(ii);
                divider.Parent = [];
                divider.Parent = obj;
            end
            childAddedListener.Enabled = true;
            childRemovedListener.Enabled = false;
            
        end
        
    end % methods
    
end % classdef