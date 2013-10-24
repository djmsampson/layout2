classdef BoxPanel < uix.BoxPanel
    %uiextras.BoxPanel  Show one element inside a box panel
    %
    %   obj = uiextras.BoxPanel() creates a box-styled panel object with
    %   automatic management of the contained widget or layout. The
    %   properties available are largely the same as the builtin UIPANEL
    %   object. Where more than one child is added, the currently visible
    %   child is determined using the SelectedChild property.
    %
    %   obj = uiextras.BoxPanel(param,value,...) also sets one or more
    %   property values.
    %
    %   See the <a href="matlab:doc uiextras.BoxPanel">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> p = uiextras.BoxPanel( 'Parent', f, 'Title', 'A BoxPanel', 'Padding', 5 );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'r' )
    %
    %   >> f = figure();
    %   >> p = uiextras.BoxPanel( 'Parent', f, 'Title', 'A BoxPanel', 'Padding', 5 );
    %   >> b = uiextras.HBox( 'Parent', p, 'Spacing', 5 );
    %   >> uicontrol( 'Style', 'listbox', 'Parent', b, 'String', {'Item 1','Item 2'} );
    %   >> uicontrol( 'Style', 'frame', 'Parent', b, 'Background', 'b' );
    %   >> set( b, 'Sizes', [100 -1] );
    %   >> p.FontSize = 12;
    %   >> p.FontWeight = 'bold';
    %   >> p.HelpFcn = @(x,y) disp('Help me!');
    %
    %   See also: uiextras.Panel
    %             uiextras.TabPanel
    %             uiextras.HBoxFlex
    
    %   Copyright 2009-2013 The MathWorks, Inc.
    %   $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $
    
    properties( Hidden, Access = public, Dependent )
        ForegroundColor % deprecated
        TitleColor % deprecated
        IsDocked % deprecated
        IsMinimized % deprecated
        SelectedChild % deprecated
    end
    
    methods
        
        function obj = BoxPanel( varargin )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'uiextras.BoxPanel will be removed in a future release.  Please use uix.BoxPanel instead.' )
            
            % Do
            obj@uix.BoxPanel( varargin{:} )
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.ForegroundColor( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''ForegroundColor'' will be removed in a future release.  Please use ''TitleForegroundColor'' instead.' )
            
            % Get
            value = obj.TitleForegroundColor;
            
        end % get.ForegroundColor
        
        function set.ForegroundColor( ~, ~ )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''ForegroundColor'' will be removed in a future release.  Please use ''TitleForegroundColor'' instead.' )
            
            % Set
            obj.TitleForegroundColor = value;
            
        end % set.ForegroundColor
        
        function value = get.TitleColor( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''TitleColor'' will be removed in a future release.  Please use ''TitleBackgroundColor'' instead.' )
            
            % Get
            value = obj.TitleBackgroundColor;
            
        end % get.TitleColor
        
        function set.TitleColor( ~, ~ )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''TitleColor'' will be removed in a future release.  Please use ''TitleBackgroundColor'' instead.' )
            
            % Set
            obj.TitleBackgroundColor = value;
            
        end % set.TitleColor
        
        function value = get.IsDocked( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''IsDocked'' will be removed in a future release.  Please use ''Docked'' instead.' )
            
            % Get
            value = obj.Docked;
            
        end % get.IsDocked
        
        function set.IsDocked( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''IsDocked'' will be removed in a future release.  Please use ''Docked'' instead.' )
            
            % Get
            obj.Docked = value;
            
        end % set.IsDocked
        
        function value = get.IsMinimized( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''IsMinimized'' will be removed in a future release.  Please use ''Minimized'' instead.' )
            
            % Get
            value = obj.Minimized;
            
        end % get.IsMinimized
        
        function set.IsMinimized( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''IsMinimized'' will be removed in a future release.  Please use ''Minimized'' instead.' )
            
            % Get
            obj.Minimized = value;
            
        end % set.IsMinimized
        
        function value = get.SelectedChild( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''SelectedChild'' will be removed in a future release.' )
            
            % Get
            if isempty( obj.Contents_ )
                value = [];
            else
                value = 1;
            end
            
        end % get.SelectedChild
        
        function set.SelectedChild( ~, ~ )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''SelectedChild'' will be removed in a future release.' )
            
        end % set.SelectedChild
        
    end % accessors
    
end % classdef