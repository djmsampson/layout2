classdef Container < matlab.ui.container.internal.UIContainer
    
    properties( Dependent, Access = public )
        Contents
    end
    
    properties( Access = protected )
        Contents_ = matlab.graphics.GraphicsPlaceholder.empty( [0 1] )
        Listeners = cell( [0 1] )
        ChildListeners = cell( [0 1] )
    end
    
    events( NotifyAccess = private )
        ChildAdded
        ChildRemoved
    end
    
    methods
        
        function obj = Container( varargin )
            
            % Call superclass constructor
            obj@matlab.ui.container.internal.UIContainer( varargin{:} );
            
            % Set up listeners
            obj.Listeners{end+1,:} = event.listener( ...
                obj, 'ObjectChildAdded', @obj.onObjectChildAdded );
            obj.Listeners{end+1,:} = event.listener( ...
                obj, 'ObjectChildRemoved', @obj.onObjectChildRemoved );
            obj.Listeners{end+1,:} = event.listener( ...
                obj, 'ChildAdded', @obj.onChildAdded );
            obj.Listeners{end+1,:} = event.listener( ...
                obj, 'ChildRemoved', @obj.onChildRemoved );
            obj.Listeners{end+1,:} = event.listener( ...
                obj, 'SizeChange', @obj.onSizeChanged );
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Contents( obj )
            
            value = obj.Contents_;
            
        end % get.Contents
        
        function set.Contents( obj, value )
            
            % Check
            assert( isequal( size( obj.Contents_ ), size( value ) ) && ...
                all( ismember( obj.Contents_, value ) ), ...
                'uix:InvalidOperation', 'Invalid operation.' )
            
            % Set
            obj.Contents_ = value;
            
            % Redraw
            obj.redraw()
            
        end % set.Contents
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            
            disp redraw
            
        end % redraw
        
    end % protected methods
    
    methods( Access = private )
        
        function onObjectChildAdded( obj, ~, eventData )
            
            child = eventData.Child;
            if ishghandle( child )
                % Raise event
                notify( obj, 'ChildAdded', uix.ChildEvent( child ) )
            elseif isa( child, 'matlab.graphics.primitive.canvas.Canvas' )
                % Add listeners
                obj.ChildListeners{end+1,:} = event.listener( ...
                    child, 'ObjectChildAdded', @obj.onObjectChildAdded );
                obj.ChildListeners{end+1,:} = event.listener( ...
                    child, 'ObjectChildRemoved', @obj.onObjectChildRemoved );
            else
                % Warn
                warning( 'uix:InvalidOperation', ...
                    'Unsupported addition of %s.', class( child ) )
            end
            
        end % onObjectChildAdded
        
        function onObjectChildRemoved( obj, ~, eventData )
            
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            child = eventData.Child;
            if ishghandle( child )
                % Raise event
                notify( obj, 'ChildRemoved', uix.ChildEvent( child ) )
            end
            
        end % onObjectChildRemoved
        
    end % private event handlers
    
    methods( Access = protected )
        
        function onChildAdded( obj, ~, eventData )
            
            % Add to contents
            obj.Contents_(end+1,1) = eventData.Child;
            
            % Call redraw
            obj.redraw()
            
        end % onChildAdded
        
        function onChildRemoved( obj, ~, eventData )
            
            % Do nothing if container is being deleted
            if strcmp( obj.BeingDeleted, 'on' ), return, end
            
            % Remove from contents
            obj.Contents_(find( obj.Contents_ == eventData.Child ),:) = []; %#ok<FNDSB>
            
            % Call redraw
            obj.redraw()
            
        end % onChildRemoved
        
        function onSizeChanged( obj, ~, ~ )
            
            % Call redraw
            obj.redraw()
            
        end % onSizeChanged
        
    end % event handlers
    
end % end