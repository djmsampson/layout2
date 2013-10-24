classdef ( Sealed ) Panel < matlab.ui.container.Panel
    
    properties( Dependent, Access = public )
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
    
    properties( Access = private )
        ChildObserver
        ChildAddedListener
        ChildRemovedListener
        ActivePositionPropertyListeners = cell( [0 1] )
    end
    
    methods
        
        function obj = Panel( varargin )
            
            % Check inputs
            uix.pvchk( varargin )
            
            % Call superclass constructor
            obj@matlab.ui.container.Panel()
            
            % Create observers and listeners
            childObserver = uix.ChildObserver( obj );
            childAddedListener = event.listener( ...
                childObserver, 'ChildAdded', @obj.onChildAdded );
            childRemovedListener = event.listener( ...
                childObserver, 'ChildRemoved', @obj.onChildRemoved );
            
            % Store observers and listeners
            obj.ChildObserver = childObserver;
            obj.ChildAddedListener = childAddedListener;
            obj.ChildRemovedListener = childRemovedListener;
            
            % Set properties
            if nargin > 0
                set( obj, varargin{:} )
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
            
            % Redraw
            obj.redraw()
            
        end % set.Padding
        
    end % accessors
    
    methods( Access = private )
    
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
        
        function onActivePositionPropertyChange( obj, ~, ~ )
            
            % Redraw
            obj.redraw()
            
        end % onActivePositionPropertyChange
        
    end % event handlers
    
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
            
            % Redraw
            obj.redraw()
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Remove from contents
            contents = obj.Contents_;
            tf = contents == child;
            obj.Contents_(tf,:) = [];
            
            % Remove listeners
            obj.ActivePositionPropertyListeners(tf,:) = [];
            
            % Redraw
            obj.redraw()
            
        end % removeChild
        
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
            
            % Redraw
            obj.redraw()
            
        end % reorder
        
        function redraw( obj )
            
            % Set positions and visibility
            children = obj.Contents_;
            selection = numel( children );
            for ii = 1:selection
                child = children(ii);
                if ii == selection
                    child.Visible = 'on';
                    child.Units = 'normalized';
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        child.( child.ActivePositionProperty ) = [0 0 1 1];
                        child.ContentsVisible = 'on';
                    else
                        child.Position = [0 0 1 1];
                    end
                else
                    child.Visible = 'off';
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        child.ContentsVisible = 'off';
                    end
                end
            end
            
        end % redraw
        
    end % template methods
    
end % classdef