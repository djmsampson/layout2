classdef Divider < hgsetget
    
    properties( Dependent )
        Parent
        Units
        Position
        Visible
    end
    
    properties( AbortSet, SetObservable )
        Color = get( 0, 'DefaultUicontrolBackgroundColor' )
        Orientation = 'vertical'
        Markings = 'on'
    end
    
    properties( Access = private )
        Control
        PropertyListeners
        SizeChangeListener
    end
    
    methods
        
        function obj = Divider( varargin )
            
            % Create control
            control = matlab.ui.control.StyleControl( ...
                'Style', 'checkbox', 'Internal', true, ...
                'Enable', 'inactive', 'DeleteFcn', @obj.onDeleted );
            
            % Store control
            obj.Control = control;
            
            % Set properties
            if nargin > 0
                set( obj, varargin{:} );
            end
            
            % Force update
            obj.update()
            
            % Create listeners
            sizeChangeListener = event.listener( control, 'SizeChange', ...
                @obj.onSizeChange );
            colorListener = event.proplistener( obj, ...
                findprop( obj, 'Color' ), 'PostSet', ...
                @obj.onColorChange );
            orientationListener = event.proplistener( obj, ...
                findprop( obj, 'Orientation' ), 'PostSet', ...
                @obj.onOrientationChange );
            markingsListener = event.proplistener( obj, ...
                findprop( obj, 'Markings' ), 'PostSet', ...
                @obj.onMarkingsChange );
            
            % Store listeners
            obj.SizeChangeListener = sizeChangeListener;
            obj.PropertyListeners = [colorListener; ...
                orientationListener; markingsListener];
            
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
            
            % Set
            obj.Control.Position = value;
            
        end % set.Position
        
        function value = get.Visible( obj )
            
            value = obj.Control.Visible;
            
        end % get.Visible
        
        function set.Visible( obj, value )
            
            obj.Control.Visible = value;
            
        end % set.Visible
        
        function set.Color( obj, value )
            
            % Check
            % TODO
            
            % Set
            obj.Color = value;
            
        end
        
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
        
        function onSizeChange( obj, ~, ~ )
            
            % Update
            obj.update()
            
        end % onSizeChange
        
        function onColorChange( obj, ~, ~ )
            
            % Update
            obj.update()
            
        end % onColorChange
        
        function onOrientationChange( obj, ~, ~ )
            
            % Update
            obj.update()
            
        end % onOrientationChange
        
        function onMarkingsChange( obj, ~, ~ )
            
            % Update
            obj.update()
            
        end % onMarkingsChange
        
        
        
    end % event handlers
    
    methods( Access = private )
        
        function update( obj )
            
            control = obj.Control;
            position = control.Position;
            color = obj.Color;
            control.ForegroundColor = color;
            control.BackgroundColor = color;
            control.CData = repmat( reshape( color, [1 1 3] ), ...
                floor( position([4 3]) ) - [1 1] );
            
        end % update
        
    end % methods
    
end % classdef