classdef VisibilityObserver < handle
    
    properties( Access = private )
        Object
        VisiblePreSetListeners = event.listener.empty( [0 1] )
        VisiblePostSetListeners = event.listener.empty( [0 1] )
        ParentPreSetListeners = event.listener.empty( [0 1] )
        ParentPostSetListeners = event.listener.empty( [0 1] )
        OldVisible
    end
    
    events( NotifyAccess = private )
        VisibilityChanged
    end
    
    methods
        
        function obj = VisibilityObserver( object )
            
            % Check
            assert( ishghandle( object ) && ...
                isequal( size( object ), [1 1] ) && ...
                ~isa( object, 'matlab.ui.Figure' ) && ...
                ~isequal( object, groot() ), 'uix.InvalidArgument', ...
                'Object must be a graphics object.' )
            
            % Store properties
            obj.Object = object;
            
            % Set up
            obj.setup()
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function setup( obj )
            
            % Identify ancestors
            object = obj.Object;
            parents = object; % initialize
            visibles = {object.Visible}; % initialize
            while true
                parent = parents(end,:).Parent;
                if isempty( parent )
                    rooted = false;
                elseif isa( parent, 'matlab.ui.Root' )
                    rooted = true;
                    break
                else
                    parents(end+1,:) = parent; %#ok<AGROW>
                    visibles{end+1,:} = parent.Visible; %#ok<AGROW>
                end
            end
            
            % Create listeners
            for ii = 1:numel( parents )
                parent = parents(ii);
                parentPreSetListeners(ii,:) = event.proplistener( ...
                    parent, findprop( parent, 'Parent' ), 'PreSet', ...
                    @obj.onParentPreSet ); %#ok<AGROW>
                parentPostSetListeners(ii,:) = event.proplistener( ...
                    parent, findprop( parent, 'Parent' ), 'PostSet', ...
                    @obj.onParentPostSet ); %#ok<AGROW>
                visiblePreSetListeners(ii,:) = event.proplistener( ...
                    parent, findprop( parent, 'Visible' ), 'PreSet', ...
                    @obj.onVisiblePreSet ); %#ok<AGROW>
                visiblePostSetListeners(ii,:) = event.proplistener( ...
                    parent, findprop( parent, 'Visible' ), 'PostSet', ...
                    @obj.onVisiblePostSet ); %#ok<AGROW>
            end
            obj.ParentPreSetListeners = parentPreSetListeners;
            obj.ParentPostSetListeners = parentPostSetListeners;
            obj.VisiblePreSetListeners = visiblePreSetListeners;
            obj.VisiblePostSetListeners = visiblePostSetListeners;
            
            % Reset old visibility
            obj.OldVisible = rooted && all( strcmp( visibles, 'on' ) );
            
        end % setup
        
        function tf = isVisible( obj )
            
            % Identify ancestors
            object = obj.Object;
            parents = object; % initialize
            visibles = {object.Visible}; % initialize
            while true
                parent = parents(end,:).Parent;
                if isempty( parent )
                    rooted = false;
                elseif isa( parent, 'matlab.ui.Root' )
                    rooted = true;
                    break
                else
                    parents(end+1,:) = parent; %#ok<AGROW>
                    visibles{end+1,:} = parent.Visible; %#ok<AGROW>
                end
            end
            
            % Compute visibility
            tf = rooted && all( strcmp( visibles, 'on' ) );
            
        end % isVisible
        
    end % operations
    
    methods( Access = private )
        
        function onParentPreSet( obj, ~, ~ )
            
            obj.OldVisible = obj.isVisible();
            
        end % onParentPreSet
        
        function onParentPostSet( obj, ~, ~ )
            
            % Raise event
            oldVisible = obj.OldVisible;
            newVisible = obj.isVisible();
            if ~isequal( oldVisible, newVisible )
                notify( obj, 'VisibilityChanged', uix.VisibleEvent( newVisible ) )
            end
            
            % Reset
            obj.setup()
            
        end % onParentPostSet
        
        function onVisiblePreSet( obj, ~, ~ )
            
            obj.OldVisible = obj.isVisible();
            
        end % onParentPreSet
        
        function onVisiblePostSet( obj, ~, ~ )
            
            % Raise event
            oldVisible = obj.OldVisible;
            newVisible = obj.isVisible();
            if ~isequal( oldVisible, newVisible )
                notify( obj, 'VisibilityChanged', uix.VisibilityEvent( newVisible ) )
            end
            
        end % onParentPostSet
        
    end % event handlers
    
end % classdef