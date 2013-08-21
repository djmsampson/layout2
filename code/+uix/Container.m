classdef Container < matlab.ui.container.internal.UIContainer
    
    properties( Dependent, Access = public )
        Contents
    end
    
    properties( Access = protected )
        Contents_ = matlab.graphics.GraphicsPlaceholder.empty( [0 1] )
    end
    
    methods
        
        function obj = Container( varargin )
            
            % Call superclass constructor
            obj@matlab.ui.container.internal.UIContainer( varargin{:} );
            
            % Set up listeners
            addlistener( obj, 'ObjectChildAdded', @obj.iOnChildAdded );
            addlistener( obj, 'ObjectChildRemoved', @obj.iOnChildRemoved );
            addlistener( obj, 'SizeChange', @obj.onSizeChanged );
            
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
        
        function iOnChildAdded( obj, source, eventData )
            
            child = eventData.Child;
            if ishghandle( child )
                % Call event handler
                obj.onChildAdded( source, eventData )
            else
                % Add listeners
                addlistener( child, 'ObjectChildAdded', @obj.iOnChildAdded );
                addlistener( child, 'ObjectChildRemoved', @obj.iOnChildRemoved );
            end
            
        end % iOnChildAdded
        
        function iOnChildRemoved( obj, source, eventData )
            
            if ishghandle( eventData.Child )
                % Call event handler
                obj.onChildRemoved( source, eventData )
            end
            
        end % iOnChildRemoved
        
    end % private services
    
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