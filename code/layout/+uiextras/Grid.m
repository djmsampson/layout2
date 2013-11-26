classdef Grid < uix.Grid
    %uiextras.Grid  Container with contents arranged in a grid
    %
    %   obj = uiextras.Grid() creates a new new grid layout with all
    %   properties set to defaults. The number of rows and columns to use
    %   is determined from the number of elements in the RowSizes and
    %   ColumnSizes properties respectively. Child elements are arranged
    %   down column one first, then column two etc. If there are
    %   insufficient columns then a new one is added. The output is a new
    %   layout object that can be used as the parent for other
    %   user-interface components. The output is a new layout object that
    %   can be used as the parent for other user-interface components.
    %
    %   obj = uiextras.Grid(param,value,...) also sets one or more
    %   parameter values.
    %
    %   See the <a href="matlab:doc uiextras.Grid">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> g = uiextras.Grid( 'Parent', f, 'Spacing', 5 );
    %   >> uicontrol( 'Style', 'frame', 'Parent', g, 'Background', 'r' )
    %   >> uicontrol( 'Style', 'frame', 'Parent', g, 'Background', 'b' )
    %   >> uicontrol( 'Style', 'frame', 'Parent', g, 'Background', 'g' )
    %   >> uiextras.Empty( 'Parent', g )
    %   >> uicontrol( 'Style', 'frame', 'Parent', g, 'Background', 'c' )
    %   >> uicontrol( 'Style', 'frame', 'Parent', g, 'Background', 'y' )
    %   >> set( g, 'ColumnSizes', [-1 100 -2], 'RowSizes', [-1 100] );
    %
    %   See also: uiextras.GridFlex
    
    %   Copyright 2009-2013 The MathWorks, Inc.
    %   $Revision$ $Date$
    
    properties( Hidden, Access = public, Dependent )
        Enable % deprecated
        RowSizes % deprecated
        ColumnSizes % deprecated
    end
    
    methods
        
        function obj = Grid( varargin )
            
            % TODO Warn
            % warning( 'uiextras:Deprecated', ...
            %     'uiextras.Grid will be removed in a future release.  Please use uix.Grid instead.' )
            
            % Call uix constructor
            obj@uix.Grid( varargin{:} )
            
            % Auto-parent
            if ~ismember( 'Parent', varargin(1:2:end) )
                obj.Parent = gcf();
            end
            
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
        
        function value = get.RowSizes( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''RowSizes'' will be removed in a future release.  Please use ''Heights'' instead.' )
            
            % Get
            value = transpose( obj.Heights );
            
        end % get.RowSizes
        
        function set.RowSizes( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''RowSizes'' will be removed in a future release.  Please use ''Heights'' instead.' )
            
            % Set
            obj.Heights = value;
            
        end % set.RowSizes
        
        function value = get.ColumnSizes( obj )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''ColumnSizes'' will be removed in a future release.  Please use ''Widths'' instead.' )
            
            % Get
            value = transpose( obj.Widths );
            
        end % get.ColumnSizes
        
        function set.ColumnSizes( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''ColumnSizes'' will be removed in a future release.  Please use ''Widths'' instead.' )
            
            % Get
            obj.Widths = value;
            
        end % set.ColumnSizes
        
    end % accessors
    
end % classdef