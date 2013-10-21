classdef Container < matlab.ui.container.internal.UIContainer
    
    properties( Dependent, Access = public )
        Contents
    end
    
    properties( Access = protected )
        Contents_ = gobjects( [0 1] )
    end
    
    properties( Dependent, Access = protected )
        Dirty
    end
    
    properties( Access = private )
        Dirty_ = false
        AncestryObserver
        AncestryListener
        OldAncestors
        ChildObserver
        ChildAddedListener
        ChildRemovedListener
        SizeChangeListener
        ActivePositionPropertyListeners = cell( [0 1] )
    end
    
    methods
        
        function obj = Container( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@matlab.ui.container.internal.UIContainer( notmypv{:} );
            
            % Create child listeners
            ancestryObserver = uix.AncestryObserver( obj );
            ancestryListener = event.listener( ancestryObserver, ...
                'AncestryChange', @obj.onAncestryChange );
            ancestors = ancestryObserver.Ancestors;
            childObserver = uix.ChildObserver( obj );
            childAddedListener = event.listener( ...
                childObserver, 'ChildAdded', @obj.onChildAdded );
            childRemovedListener = event.listener( ...
                childObserver, 'ChildRemoved', @obj.onChildRemoved );
            
            % Create resize listener
            sizeChangeListener = event.listener( ...
                obj, 'SizeChange', @obj.onSizeChange );
            
            % Store listeners
            obj.AncestryObserver = ancestryObserver;
            obj.AncestryListener = ancestryListener;
            obj.OldAncestors = ancestors;
            obj.ChildObserver = childObserver;
            obj.ChildAddedListener = childAddedListener;
            obj.ChildRemovedListener = childRemovedListener;
            obj.SizeChangeListener = sizeChangeListener;
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
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
        
        function value = get.Dirty( obj )
            
            value = obj.Dirty_;
            
        end % get.Dirty
        
        function set.Dirty( obj, value )
            
            if value
                if obj.isDrawable()
                    obj.redraw()
                else
                    obj.Dirty_ = true;
                end
            end
            
        end % set.Dirty
        
    end % accessors
    
    methods( Access = private, Sealed )
        
        function onAncestryChange( obj, ~, ~ )
            
            % Retrieve old ancestors from cache
            oldAncestors = obj.OldAncestors;
            
            % Retrieve new ancestors from observer
            ancestryObserver = obj.AncestryObserver;
            newAncestors = ancestryObserver.Ancestors;
            
            % Call template method
            obj.transplant( oldAncestors, newAncestors )
            
            % Redraw if possible and if dirty
            if obj.Dirty_ && obj.isDrawable()
                obj.redraw()
                obj.Dirty_ = false;
            end
            
            % Update cache
            obj.OldAncestors = newAncestors;
            
        end % onAncestryChange
        
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
            obj.Contents_(end+1,1) = child;
            
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
            obj.Contents_(obj.Contents_==child) = [];
            
            % Remove listeners
            tf = obj.Contents_ == child;
            obj.ActivePositionPropertyListeners(tf,:) = [];
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % removeChild
        
        function transplant( obj, oldAncestors, newAncestors ) %#ok<INUSD>
            
        end % transplant
        
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
            
            ancestors = obj.AncestryObserver.Ancestors;
            tf = ~isempty( ancestors ) && ...
                isa( ancestors(1), 'matlab.ui.Figure' );
            
        end % isDrawable
        
    end % template methods
    
end % classdef