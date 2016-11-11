classdef Viewport < uix.Container & uix.mixin.Panel
    %uix.Viewport  Scrolling panel
    %
    %  b = uix.Viewport(p1,v1,p2,v2,...) constructs a scrolling panel and
    %  sets parameter p1 to value v1, etc.
    %
    %  A scrolling panel is a standard container (uicontainer) that shows
    %  one its contents and hides the others.
    %
    %  See also: uix.Panel, uix.BoxPanel, uix.TabPanel, uicontainer
    
    %  Copyright 2009-2016 The MathWorks, Inc.
    %  $Revision: 1165 $ $Date: 2015-12-06 03:09:17 -0500 (Sun, 06 Dec 2015) $
    
    methods
        
        function obj = Viewport( varargin )
            %uix.Viewport  Scrolling panel constructor
            %
            %  p = uix.Viewport() constructs a scrolling panel.
            %
            %  p = uix.Viewport(p1,v1,p2,v2,...) sets parameter p1 to
            %  value v1, etc.
            
            % Set properties
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods( Access = protected )
        
        function redraw( obj )
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            padding = obj.Padding_;
            xSizes = uix.calcPixelSizes( bounds(3), -1, 1, padding, 0 );
            ySizes = uix.calcPixelSizes( bounds(4), -1, 1, padding, 0 );
            position = [padding+1 padding+1 xSizes ySizes];
            
            % Redraw contents
            obj.redrawContents( position )
            
        end % redraw
        
    end % template methods
    
end % classdef