classdef TabPanel < uix.TabPanel
    %TabPanel  Show one element inside a tabbed panel
    %
    %   obj = uiextras.TabPanel() creates a panel with tabs along one edge
    %   to allow selection between the different child objects contained.
    %
    %   obj = uiextras.TabPanel(param,value,...) also sets one or more
    %   property values.
    %
    %   See the <a href="matlab:doc uiextras.TabPanel">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> p = uiextras.TabPanel( 'Parent', f, 'Padding', 5 );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'r' );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'b' );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'g' );
    %   >> p.TabNames = {'Red', 'Blue', 'Green'};
    %   >> p.SelectedChild = 2;
    %
    %   See also: uiextras.Panel
    %             uiextras.BoxPanel
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 373 $
    %   $Date: 2011-07-14 13:24:10 +0100 (Thu, 14 Jul 2011) $
    
    properties( Hidden, Access = public )
        Callback = '' % deprecated
    end
    
    properties( Hidden, Access = public, Dependent )
        Enable % deprecated
        SelectedChild % deprecated
        TabEnable % deprecated
        TabNames % deprecated
        TabPosition % deprecated
        TabSize % deprecated
    end
    
    properties( Access = private )
        SelectionChangeListener % listener
    end
    
    methods
        
        function obj = TabPanel( varargin )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'uiextras.TabPanel will be removed in a future release.  Please use uix.TabPanel instead.' )
            
            % Call uix constructor
            obj@uix.TabPanel( varargin{:} )
            
            % Auto-parent
            if ~ismember( 'Parent', varargin(1:2:end) )
                obj.Parent = gcf();
            end
            
            % Create listeners
            selectionChangeListener = event.listener( obj, ...
                'SelectionChange', @obj.onSelectionChange );
            
            % Store properties
            obj.SelectionChangeListener = selectionChangeListener;
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Enable( ~ )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''Enable'' will be removed in a future release.' )
            
            % Return
            value = 'on';
            
        end % get.Enable
        
        function set.Enable( ~, value )
            
            % Check
            assert( ischar( value ) && any( strcmp( value, {'on','off'} ) ), ...
                'uiextras:InvalidPropertyValue', ...
                'Property ''Enable'' must be ''on'' or ''off''.' )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''Enable'' will be removed in a future release.' )
            
        end % set.Enable
        
        function value = get.Callback( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''Callback'' will be removed in a future release.  Please use ''SelectionChangeCallback'' instead.' )
            
            % Get
            value = obj.Callback;
            
        end % get.Callback
        
        function set.Callback( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''Callback'' will be removed in a future release.  Please use ''SelectionChangeCallback'' instead.' )
            
            % Check
            if ischar( value ) % string
                % OK
            elseif isa( value, 'function_handle' ) && ...
                    isequal( size( value ), [1 1] ) % function handle
                % OK
            elseif iscell( value ) && ndims( value ) == 2 && ...
                    size( value, 1 ) == 1 && size( value, 2 ) > 0 && ...
                    isa( value{1}, 'function_handle' ) && ...
                    isequal( size( value{1} ), [1 1] ) %#ok<ISMAT> % cell callback
                % OK
            else
                error( 'uiextras:InvalidPropertyValue', ...
                    'Property ''Callback'' must be a valid callback.' )
            end
            
            % Set
            obj.Callback = value;
            
        end % set.Callback
        
        function value = get.SelectedChild( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''SelectedChild'' will be removed in a future release.  Please use ''Selection'' instead.' )
            
            % Get
            value = obj.Selection;
            
        end % get.SelectedChild
        
        function set.SelectedChild( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''SelectedChild'' will be removed in a future release.  Please use ''Selection'' instead.' )
            
            % Set
            obj.Selection = value;
            
        end % set.SelectedChild
        
        function value = get.TabEnable( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''TabEnable'' will be removed in a future release.  Please use ''TabEnables'' instead.' )
            
            % Get
            value = transpose( obj.TabEnables );
            
        end % get.TabEnable
        
        function set.TabEnable( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''TabEnable'' will be removed in a future release.  Please use ''TabEnables'' instead.' )
            
            % Set
            obj.TabEnables = transpose( value );
            
        end % set.TabEnable
        
        function value = get.TabNames( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''TabNames'' will be removed in a future release.  Please use ''TabTitles'' instead.' )
            
            % Get
            value = transpose( obj.TabTitles );
            
        end % get.TabNames
        
        function set.TabNames( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''TabNames'' will be removed in a future release.  Please use ''TabTitles'' instead.' )
            
            % Set
            obj.TabTitles = transpose( value );
            
        end % set.TabNames
        
        function value = get.TabPosition( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''TabPosition'' will be removed in a future release.  Please use ''TabLocation'' instead.' )
            
            % Get
            value = obj.TabLocation;
            
        end % get.TabPosition
        
        function set.TabPosition( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''TabPosition'' will be removed in a future release.  Please use ''TabLocation'' instead.' )
            
            % Set
            obj.TabLocation = value;
            
        end % set.TabPosition
        
        function value = get.TabSize( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''TabSize'' will be removed in a future release.  Please use ''TabWidth'' instead.' )
            
            % Get
            value = obj.TabWidth;
            
        end % get.TabSize
        
        function set.TabSize( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''TabSize'' will be removed in a future release.  Please use ''TabWidth'' instead.' )
            
            % Set
            obj.TabWidth = value;
            
        end % set.TabSize
        
    end % accessors
    
    methods( Access = private )
        
        function onSelectionChange( obj, source, eventData )
            
            % Create legacy event data structure
            oldEventData = struct( 'Source', eventData.Source, ...
                'PreviousChild', eventData.OldValue, ...
                'SelectedChild', eventData.NewValue );
            
            % Call callback
            callback = obj.Callback;
            if ischar( callback ) && isequal( callback, '' )
                % do nothing
            elseif ischar( callback )
                feval( callback, source, oldEventData )
            elseif isa( callback, 'function_handle' )
                callback( source, oldEventData )
            elseif iscell( callback )
                feval( callback{1}, source, oldEventData, callback{2:end} )
            end
            
        end % onSelectionChange
        
    end % event handlers
    
end % classdef