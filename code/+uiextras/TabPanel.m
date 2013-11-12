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
    
    properties( Hidden, Access = public, Dependent )
        SelectedChild % deprecated
        TabEnable % deprecated
        TabNames % deprecated
        TabPosition % deprecated
        TabSize % deprecated
    end
    
    methods
        
        function obj = TabPanel( varargin )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'uiextras.TabPanel will be removed in a future release.  Please use uix.TabPanel instead.' )
            
            % Do
            obj@uix.TabPanel( varargin{:} )
            
        end % constructor
        
    end % structors
    
    methods
        
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
    
end % classdef