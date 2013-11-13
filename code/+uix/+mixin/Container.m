classdef Container < handle
    
    properties( Dependent, Access = public )
        Contents % contents in layout order
    end
    
    properties( Dependent, Access = public, AbortSet, SetObservable )
        Enable % enable or disable the contents
    end
    
    properties( Access = public, Dependent, AbortSet )
        Padding % space around contents, in pixels
    end
    
    properties( Access = protected )
        Contents_ = gobjects( [0 1] ) % backing for Contents
        Padding_ = 0 % backing for Padding
    end
    
    properties( Dependent, Access = protected )
        Dirty % needs redraw
    end
    
    properties( Access = private )
        Dirty_ = false % backing for Dirty
        Enable_ = 'on' % backing for Enable
        AncestryObserver % observer
        AncestryListeners % listeners
        OldAncestors % old state
        VisibilityObserver % observer
        VisibilityListener % listeners
        EnableObserver % observer
        EnableListener % listener
        OldEnables = cell( [0 1] ) % old state
        ChildObserver % observer
        ChildAddedListener % listener
        ChildRemovedListener % listener
        SizeChangeListener % listener
        ActivePositionPropertyListeners = cell( [0 1] ) % listeners
    end
    
    methods
        
        function obj = Container()
            %uix.mixin.Container  Initialize
            %
            %  uix.mixin.Container() initializes the container during
            %  construction.
            
            % Create observers and listeners
            ancestryObserver = uix.AncestryObserver( obj );
            ancestryListeners = [ ...
                event.listener( ancestryObserver, ...
                'AncestryPreChange', @obj.onAncestryPreChange ); ...
                event.listener( ancestryObserver, ...
                'AncestryPostChange', @obj.onAncestryPostChange )];
            visibilityObserver = uix.VisibilityObserver( obj );
            visibilityListener = event.listener( visibilityObserver, ...
                'VisibilityChange', @obj.onVisibilityChange );
            enableObserver = uix.EnableObserver( obj );
            enableListener = event.listener( enableObserver, ...
                'EnableChange', @obj.onEnableChange );
            childObserver = uix.ChildObserver( obj );
            childAddedListener = event.listener( ...
                childObserver, 'ChildAdded', @obj.onChildAdded );
            childRemovedListener = event.listener( ...
                childObserver, 'ChildRemoved', @obj.onChildRemoved );
            sizeChangeListener = event.listener( ...
                obj, 'SizeChange', @obj.onSizeChange );
            
            % Store observers and listeners
            obj.AncestryObserver = ancestryObserver;
            obj.AncestryListeners = ancestryListeners;
            obj.VisibilityObserver = visibilityObserver;
            obj.VisibilityListener = visibilityListener;
            obj.EnableObserver = enableObserver;
            obj.EnableListener = enableListener;
            obj.ChildObserver = childObserver;
            obj.ChildAddedListener = childAddedListener;
            obj.ChildRemovedListener = childRemovedListener;
            obj.SizeChangeListener = sizeChangeListener;
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Contents( obj )
            
            value = obj.Contents_;
            
        end % get.Contents
        
        function set.Contents( obj, value )
            
            % Check
            [tf, indices] = ismember( value, obj.Contents_ );
            assert( isequal( size( obj.Contents_ ), size( value ) ) && ...
                numel( value ) == numel( unique( value ) ) && all( tf ), ...
                'uix:InvalidOperation', ...
                'Property ''Contents'' may only be set to a permutation of itself.' )
            
            % Call reorder
            obj.reorder( indices )
            
        end % set.Contents
        
        function value = get.Enable( obj )
            
            value = obj.Enable_;
            
        end % get.Enable
        
        function set.Enable( obj, value )
            
            % Check
            assert( ischar( value ) && any( strcmp( value, {'on';'off'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Enable'' must be ''on'' or ''off''.' )
            
            % Set
            obj.Enable_ = value;
            
        end % set.Enable
        
        function value = get.Padding( obj )
            
            value = obj.Padding_;
            
        end % get.Padding
        
        function set.Padding( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Padding'' must be a non-negative scalar.' )
            
            % Set
            obj.Padding_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Padding
        
        function value = get.Dirty( obj )
            
            value = obj.Dirty_;
            
        end % get.Dirty
        
        function set.Dirty( obj, value )
            
            if value
                if obj.isDrawable() % drawable
                    obj.redraw() % redraw now
                else % not drawable
                    obj.Dirty_ = true; % flag for future redraw
                end
            end
            
        end % set.Dirty
        
    end % accessors
    
    methods( Access = private, Sealed )
        
        function onAncestryPreChange( obj, ~, ~ )
            
            % Retrieve ancestors from observer
            ancestryObserver = obj.AncestryObserver;
            oldAncestors = ancestryObserver.Ancestors;
            
            % Store ancestors in cache
            obj.OldAncestors = oldAncestors;
            
            % Call template method
            obj.unparent( oldAncestors )
            
        end % onAncestryPreChange
        
        function onAncestryPostChange( obj, ~, ~ )
            
            % Retrieve old ancestors from cache
            oldAncestors = obj.OldAncestors;
            
            % Retrieve new ancestors from observer
            ancestryObserver = obj.AncestryObserver;
            newAncestors = ancestryObserver.Ancestors;
            
            % Call template method
            obj.reparent( oldAncestors, newAncestors )
            
            % Redraw if possible and if dirty
            if obj.Dirty_ && obj.isDrawable()
                obj.redraw()
                obj.Dirty_ = false;
            end
            
            % Reset cache
            obj.OldAncestors = [];
            
        end % onAncestryPostChange
        
        function onVisibilityChange( obj, ~, ~ )
            
            % Redraw if possible and if dirty
            if obj.Dirty_ && obj.isDrawable()
                obj.redraw()
                obj.Dirty_ = false;
            end
            
        end % onVisibilityChange
        
        function onEnableChange( obj, ~, ~ )
            
            c = obj.Contents_;
            tf = arrayfun( @(x)isa(x,'matlab.ui.control.StyleControl'), c );
            if obj.EnableObserver.Enable % restore enable state
                oldEnables = obj.OldEnables;
                for ii = 1:numel( c )
                    if tf(ii)
                        c(ii).Enable = oldEnables{ii};
                    end
                end
                obj.OldEnables = repmat( {'unset'}, size( c ) );
            else % snapshot enable state and disable
                enables = repmat( {'unset'}, size( c  ) );
                enables(tf) = get( c(tf), {'Enable'} );
                obj.OldEnables = enables;
                set( c(tf), 'Enable', 'off' )
            end
            
        end % onEnableChange
        
        function onChildAdded( obj, ~, eventData )
            
            % Call template method
            obj.addChild( eventData.Child )
            
        end % onChildAdded
        
        function onChildRemoved( obj, ~, eventData )
            
            % Do nothing if container is being deleted
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            % Call template method
            obj.removeChild( eventData.Child )
            
        end % onChildRemoved
        
        function onSizeChange( obj, ~, ~ )
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onSizeChange
        
        function onActivePositionPropertyChange( obj, ~, ~ )
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onActivePositionPropertyChange
        
    end % event handlers
    
    methods( Abstract, Access = protected )
        
        redraw( obj )
        
    end % abstract template methods
    
    methods( Access = protected )
        
        function addChild( obj, child )
            
            % Add to contents
            obj.Contents_(end+1,:) = child;
            
            % Add to enables
            if obj.Enable_
                obj.OldEnables{end+1,:} = 'unset';
            elseif isa( child, 'matlab.ui.control.StyleControl' )
                obj.OldEnables{end+1,:} = child.Enable;
            else
                obj.OldEnables{end+1,:} = 'unset';
            end
            
            % Add listeners
            if isa( child, 'matlab.graphics.axis.Axes' )
                obj.ActivePositionPropertyListeners{end+1,:} = ...
                    event.proplistener( child, ...
                    findprop( child, 'ActivePositionProperty' ), ...
                    'PostSet', @obj.onActivePositionPropertyChange );
            else
                obj.ActivePositionPropertyListeners{end+1,:} = [];
            end
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Remove from contents
            contents = obj.Contents_;
            tf = contents == child;
            obj.Contents_(tf,:) = [];
            
            % Remove from enables
            obj.OldEnables(tf,:) = [];
            
            % Remove listeners
            obj.ActivePositionPropertyListeners(tf,:) = [];
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % removeChild
        
        function unparent( obj, oldAncestors ) %#ok<INUSD>
            %unparent  Unparent container
            %
            %  c.unparent(a) unparents the container c from the ancestors
            %  a.
            
        end % unparent
        
        function reparent( obj, oldAncestors, newAncestors ) %#ok<INUSL>
            %reparent  Reparent container
            %
            %  c.reparent(a,b) reparents the container c from the ancestors
            %  a to the ancestors b.
            
            % Refresh observers and listeners
            visibilityObserver = uix.VisibilityObserver( [newAncestors; obj] );
            visibilityListener = event.listener( visibilityObserver, ...
                'VisibilityChange', @obj.onVisibilityChange );
            enableObserver = uix.EnableObserver( [newAncestors; obj] );
            enableListener = event.listener( enableObserver, ...
                'EnableChange', @obj.onEnableChange );
            
            % Store observers and listeners
            obj.VisibilityObserver = visibilityObserver;
            obj.VisibilityListener = visibilityListener;
            obj.EnableObserver = enableObserver;
            obj.EnableListener = enableListener;
            
        end % reparent
        
        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).
            
            % Reorder contents
            obj.Contents_ = obj.Contents_(indices,:);
            
            % Reorder listeners
            obj.ActivePositionPropertyListeners = ...
                obj.ActivePositionPropertyListeners(indices,:);
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % reorder
        
        function tf = isDrawable( obj )
            %isDrawable  Test for drawability
            %
            %  c.isDrawable() is true if the container c is drawable, and
            %  false otherwise.  To be drawable, a container must be rooted
            %  and visible.
            
            ancestors = obj.AncestryObserver.Ancestors;
            visible = obj.VisibilityObserver.Visible;
            tf = visible && ~isempty( ancestors ) && ...
                isa( ancestors(1), 'matlab.ui.Figure' );
            
        end % isDrawable
        
    end % template methods
    
end % classdef