classdef Divider < hgsetget
    %uix.Divider  Draggable divider
    %
    %  d = uix.Divider() creates a divider.
    %
    %  d = uix.Divider(p1,v1,p2,v2,...) creates a divider and sets
    %  specified property p1 to value v1, etc.
    
    %  Copyright 2009-2013 The MathWorks, Inc.
    %  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $
    
    properties( Dependent )
        Parent % parent
        Units % units [inches|centimeters|characters|normalized|points|pixels]
        Position % position
        Visible % visible [on|off]
    end
    
    properties( AbortSet, SetObservable )
        Color = get( 0, 'DefaultUicontrolBackgroundColor' ) % color
        Orientation = 'vertical' % orientation [vertical|horizontal]
        Markings = 'on' % markings [on|off]
    end
    
    properties( Access = private )
        Control % uicontrol
        PropertyListeners % listeners
        SizeChangeListener % listener
    end
    
    methods
        
        function obj = Divider( varargin )
            %uix.Divider  Draggable divider
            %
            %  d = uix.Divider() creates a divider.
            %
            %  d = uix.Divider(p1,v1,p2,v2,...) creates a dividerand sets
            %  specified property p1 to value v1, etc.
            
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
            %delete  Destructor
            
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
        
        function value = get.Visible( obj )
            
            value = obj.Control.Visible;
            
        end % get.Visible
        
        function set.Visible( obj, value )
            
            obj.Control.Visible = value;
            
        end % set.Visible
        
        function set.Color( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && ...
                isequal( size( value ), [1 3] ) && ...
                all( value >= 0 ) && all( value <= 1 ), ...
                'uix:InvalidArgument', ...
                'Property ''Color'' must be a valid colorspec.' )
            
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
            assert( ischar( value ) && ...
                any( strcmp( value, {'on','off'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Markings'' must be ''on'' or ''off''.' )
            
            % Set
            obj.Markings = value;
            
        end % set.Markings
        
    end % accessors
    
    methods
        
        function onDeleted( obj, ~, ~ )
            %onDeleted  Event handler
            
            % Call destructor
            obj.delete()
            
        end % onDeleted
        
        function onSizeChange( obj, ~, ~ )
            %onSizeChange  Event handler
            
            % Update
            obj.update()
            
        end % onSizeChange
        
        function onColorChange( obj, ~, ~ )
            %onColorChange  Event handler
            
            % Update
            obj.update()
            
        end % onColorChange
        
        function onOrientationChange( obj, ~, ~ )
            %onOrientationChange  Event handler
            
            % Update
            obj.update()
            
        end % onOrientationChange
        
        function onMarkingsChange( obj, ~, ~ )
            %onMarkingsChange  Event handler
            
            % Update
            obj.update()
            
        end % onMarkingsChange
        
    end % event handlers
    
    methods( Access = private )
        
        function update( obj )
            %update  Update divider
            %
            %  d.update() updates the divider markings.
            
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