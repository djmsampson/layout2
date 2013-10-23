classdef VBoxFlex < uix.VBoxFlex
    %uiextras.VBoxFlex  A dynamically resizable vertical layout
    %
    %   obj = uiextras.VBoxFlex() creates a new dynamically resizable
    %   vertical box layout with all parameters set to defaults. The output
    %   is a new layout object that can be used as the parent for other
    %   user-interface components.
    %
    %   obj = uiextras.VBoxFlex(param,value,...) also sets one or more
    %   parameter values.
    %
    %   See the <a href="matlab:doc uiextras.VBoxFlex">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure( 'Name', 'uiextras.VBoxFlex example' );
    %   >> b = uiextras.VBoxFlex( 'Parent', f );
    %   >> uicontrol( 'Parent', b, 'Background', 'r' )
    %   >> uicontrol( 'Parent', b, 'Background', 'b' )
    %   >> uicontrol( 'Parent', b, 'Background', 'g' )
    %   >> uicontrol( 'Parent', b, 'Background', 'y' )
    %   >> set( b, 'Sizes', [-1 100 -2 -1], 'Spacing', 5 );
    %
    %   See also: uiextras.HBoxFlex
    %             uiextras.VBox
    %             uiextras.Grid
    
    %   Copyright 2009-2013 The MathWorks, Inc.
    %   $Revision: 366 $ $Date: 2011-02-10 15:48:11 +0000 (Thu, 10 Feb 2011) $
    
    properties( Hidden, Access = public, Dependent )
        Sizes % deprecated
        MinimumSizes % deprecated
    end
    
    methods
        
        function obj = VBoxFlex( varargin )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'uiextras.VBoxFlex will be removed in a future release.  Please use uix.VBoxFlex instead.' )
            
            % Do
            obj@uix.VBoxFlex( varargin{:} )
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Sizes( obj )
            
            % Warn
            warning( 'uix:Deprecated', ...
                'Property ''Sizes'' will be removed in a future release.  Use ''Heights'' instead.' )
            
            % Get
            value = transpose( obj.Heights );
            
        end % get.Sizes
        
        function set.Sizes( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''Sizes'' will be removed in a future release.  Use ''Heights'' instead.' )
            
            % Set
            obj.Heights = transpose( value );
            
        end % set.Sizes
        
        function value = get.MinimumSizes( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''MinimumSizes'' will be removed in a future release.  Use ''MinimumHeights'' instead.' )
            
            % Get
            value = transpose( obj.MinimumHeights );
            
        end % get.MinimumSizes
        
        function set.MinimumSizes( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''MinimumSizes'' will be removed in a future release.  Use ''MinimumHeights'' instead.' )
            
            % Get
            obj.MinimumHeights = transpose( value );
            
        end % set.MinimumSizes
        
    end % accessors
    
end % classdef