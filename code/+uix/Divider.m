classdef Divider < hgsetget
    
    properties( Dependent )
        Parent
        Units
        Position
    end
    
    properties
        Orientation = 'vertical'
        Markings = 'on'
    end
    
    properties( Access = private )
        Control
    end
    
    methods
        
        function obj = Divider( varargin )
            
            % Create control
            control = matlab.ui.control.StyleControl( ...
                'Style', 'frame', 'Internal', true, ...
                'DeleteFcn', @obj.onDeleted );
            
            % Store control
            obj.Control = control;
            
            % Set properties
            if nargin > 0
                set( obj, varargin{:} );
            end
            
        end % constructor
        
        function delete( obj )
            
            control = obj.Control;
            if ishghandle( control ) && ~strcmp( control, 'BeingDeleted' )
                control.delete()
            end
            
        end % destructor
        
    end % structors
    
    methods
        
        function value = get.Parent( obj )
            
            value = obj.Control.Parent;
            
        end % get.Parent
        
        function set.Parent( obj, value )
            
            obj.Control.Parent = value;
            
        end % set.Parent
        
        function value = get.Units( obj )
            
            value = obj.Control.Units;
            
        end % get.Units
        
        function set.Units( obj, value )
            
            obj.Control.Units = value;
            
        end % set.Units
        
        function value = get.Position( obj )
            
            value = obj.Control.Position;
            
        end % get.Position
        
        function set.Position( obj, value )
            
            obj.Control.Position = value;
            
        end % set.Position
        
        function set.Orientation( obj, value )
            
            % Check
            assert( ischar( value ) && ismember( value, ...
                {'horizontal','vertical'} ) )
            
            % Set
            obj.Orientation = value;
            
        end % set.Orientation
        
        function set.Markings( obj, value )
            
            % Check
            assert( ischar( value ) && ismember( value, {'on','off'} ) )
            
            % Set
            obj.Markings = value;
            
        end % set.Markings
        
    end % accessors
    
    methods
        
        function onDeleted( obj, ~, ~ )
            
            % Call destructor
            obj.delete()
            
        end % onDeleted
        
    end
end % classdef