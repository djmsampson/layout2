classdef VBox < uix.VBox
    %uiextras.VBox  Arrange elements vertically in a single column
    %
    %   obj = uiextras.VBox() creates a new vertical box layout with all
    %   parameters set to defaults. The output is a new layout object that
    %   can be used as the parent for other user-interface components.
    %
    %   obj = uiextras.VBox(param,value,...) also sets one or more
    %   parameter values.
    %
    %   See the <a href="matlab:doc uiextras.VBox">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> b = uiextras.VBox( 'Parent', f );
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
    %   See also: uiextras.HBox
    %             uiextras.VBoxFlex
    %             uiextras.Grid
    
    %  Copyright 2009-2013 The MathWorks, Inc.
    %  $Revision: 366 $ $Date: 2011-02-10 15:48:11 +0000 (Thu, 10 Feb 2011) $
    
    properties( Hidden, Access = public, Dependent )
        Sizes % deprecated
        MinimumSizes % deprecated
    end
    
    methods
        
        function obj = VBox( varargin )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'uiextras.VBox is deprecated.  Please use uix.VBox instead.' )
            
            % Do
            obj@uix.VBox( varargin{:} )
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.Sizes( obj )
            
            % Warn
            warning( 'uix:Deprecated', ...
                'Property ''Sizes'' is deprecated.  Use ''Heights'' instead.' )
            
            % Get
            value = transpose( obj.Heights );
            
        end % get.Sizes
        
        function set.Sizes( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''Sizes'' is deprecated.  Use ''Heights'' instead.' )
            
            % Set
            obj.Heights = transpose( value );
            
        end % set.Sizes
        
        function value = get.MinimumSizes( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''MinimumSizes'' is deprecated.  Use ''MinimumHeights'' instead.' )
            
            % Get
            value = transpose( obj.MinimumHeights );
            
        end % get.MinimumSizes
        
        function set.MinimumSizes( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''MinimumSizes'' is deprecated.  Use ''MinimumHeights'' instead.' )
            
            % Get
            obj.MinimumHeights = transpose( value );
            
        end % set.MinimumSizes
        
    end % accessors
    
end % classdef