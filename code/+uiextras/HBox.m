classdef HBox < uix.HBox
    %uiextras.HBox  Arrange elements in a single horizontal row
    %
    %   obj = uiextras.HBox() creates a new horizontal box layout with
    %   all parameters set to defaults. The output is a new layout object
    %   that can be used as the parent for other user-interface components.
    %
    %   obj = uiextras.HBox(param,value,...) also sets one or more
    %   parameter values.
    %
    %   See the <a href="matlab:doc uiextras.HBox">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> b = uiextras.HBox( 'Parent', f );
    %   >> uicontrol( 'Parent', b, 'Background', 'r' )
    %   >> uicontrol( 'Parent', b, 'Background', 'b' )
    %   >> uicontrol( 'Parent', b, 'Background', 'g' )
    %   >> set( b, 'Sizes', [-1 100 -2], 'Spacing', 5 );
    %
    %   >> f = figure();
    %   >> b1 = uiextras.VBox( 'Parent', f );
    %   >> b2 = uiextras.HBox( 'Parent', b1, 'Padding', 5, 'Spacing', 5 );
    %   >> uicontrol( 'Style', 'frame', 'Parent', b1, 'Background', 'r' )
    %   >> uicontrol( 'Parent', b2, 'String', 'Button1' )
    %   >> uicontrol( 'Parent', b2, 'String', 'Button2' )
    %   >> set( b1, 'Sizes', [30 -1] );
    %
    %   See also: uiextras.VBox
    %             uiextras.HBoxFlex
    %             uiextras.Grid
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 374 $ $Date: 2012-12-20 09:18:15 +0000 (Thu, 20 Dec 2012) $
    
    properties( Hidden, Access = public, Dependent )
        Sizes % deprecated
        MinimumSizes % deprecated
    end
    
    methods
        
        function obj = HBox( varargin )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'uiextras.HBox is deprecated.  Please use uix.HBox instead.' )
            
            % Do
            obj@uix.HBox( varargin{:} )
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Sizes( obj )
            
            % Warn
            warning( 'uix:Deprecated', ...
                'Property ''Sizes'' is deprecated.  Use ''Widths'' instead.' )
            
            % Get
            value = transpose( obj.Widths );
            
        end % get.Sizes
        
        function set.Sizes( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''Sizes'' is deprecated.  Use ''Widths'' instead.' )
            
            % Set
            obj.Widths = transpose( value );
            
        end % set.Sizes
        
        function value = get.MinimumSizes( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''MinimumSizes'' is deprecated.  Use ''MinimumWidths'' instead.' )
            
            % Get
            value = transpose( obj.MinimumWidths );
            
        end % get.MinimumSizes
        
        function set.MinimumSizes( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''MinimumSizes'' is deprecated.  Use ''MinimumWidths'' instead.' )
            
            % Get
            obj.MinimumWidths = transpose( value );
            
        end % set.MinimumSizes
        
    end % accessors
    
end % classdef