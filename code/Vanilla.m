classdef Vanilla < matlab.ui.container.internal.UIContainer
    
    properties( Dependent, GetAccess = public, SetAccess = private )
        Contents
    end
    
    properties( Access = public, AbortSet )
        Enable = 'on'
    end
    
    properties( Access = public, Dependent, AbortSet )
        Padding % space around contents, in pixels
    end
    
    properties( Access = protected )
        Contents_ = gobjects( [0 1] ) % backing for Contents
        Padding_ = 0 % backing for Padding
    end
    
    properties( Dependent, Access = protected )
        Dirty
    end
    
    properties( Access = private )
        Dirty_ = false
        AncestryObserver
        AncestryListeners
        OldAncestors
        ChildObserver
        ChildAddedListener
        ChildRemovedListener
        SizeChangeListener
    end
    
    methods
        
        function obj = Vanilla()
            
            % Call superclass constructor
            obj@matlab.ui.container.internal.UIContainer()
            
            % Create observers and listeners
            ancestryObserver = uix.AncestryObserver( obj );
            ancestryListeners = [ ...
                event.listener( ancestryObserver, ...
                'AncestryPreChange', @obj.onAncestryPreChange ); ...
                event.listener( ancestryObserver, ...
                'AncestryPostChange', @obj.onAncestryPostChange )];
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
        
        function set.Enable( ~, value )
            
            % Check
            assert( ischar( value ) && any( strcmp( value, {'on';'off'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Enable'' must be ''on'' or ''off''.' )
            
            % Warn
            warning( 'uix:Unimplemented', ...
                'Property ''Enable'' is not implemented.' )
            
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
        
        function onChildAdded( obj, ~, eventData )
            
            % Call template method
            obj.addChild( eventData.Child )
            
        end % onChildAdded
        
        function onChildRemoved( obj, ~, eventData )
            
            % Do nothing if container is being deleted
            % if strcmp( obj.BeingDeleted, 'on' ), return, end
            
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
    
    methods( Access = protected )
        
        function addChild( obj, child )
            
            % Add to contents
            obj.Contents_(end+1,1) = child;
            
%             % Add listeners
%             if isa( child, 'matlab.graphics.axis.Axes' )
%                 obj.ActivePositionPropertyListeners{end+1,:} = ...
%                     event.proplistener( child, ...
%                     findprop( child, 'ActivePositionProperty' ), ...
%                     'PostSet', @obj.onActivePositionPropertyChange );
%             else
%                 obj.ActivePositionPropertyListeners{end+1,:} = [];
%             end
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Remove from contents
            contents = obj.Contents_;
            tf = contents == child;
            obj.Contents_(tf,:) = [];
            
%             % Remove listeners
%             obj.ActivePositionPropertyListeners(tf,:) = [];
            
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
            
%             % Refresh visibility observer and listener
%             visibilityObserver = uix.VisibilityObserver( [newAncestors; obj] );
%             visibilityListener = event.listener( visibilityObserver, ...
%                 'VisibilityChange', @obj.onVisibilityChange );
%             
%             % Store observer and listener
%             obj.VisibilityObserver = visibilityObserver;
%             obj.VisibilityListener = visibilityListener;
            
        end % reparent
        
        function redraw( obj )
            
        end % redraw
        
        function tf = isDrawable( obj )
            %isDrawable  Test for drawability
            %
            %  c.isDrawable() is true if the container c is drawable, and
            %  false otherwise.  To be drawable, a container must be rooted
            %  and visible.
            
            ancestors = obj.AncestryObserver.Ancestors;
            tf = ~isempty( ancestors ) && ...
                isa( ancestors(1), 'matlab.ui.Figure' );
            
        end % isDrawable
        
    end % template methods
    
end % classdef