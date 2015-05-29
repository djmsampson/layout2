classdef Panel < matlab.ui.container.Panel & uix.mixin.Panel
    %uix.Panel  Standard panel
    %
    %  b = uix.Panel(p1,v1,p2,v2,...) constructs a standard panel and sets
    %  parameter p1 to value v1, etc.
    %
    %  A card panel is a standard panel (uipanel) that shows one its
    %  contents and hides the others.
    %
    %  See also: uix.CardPanel, uix.BoxPanel, uipanel
    
    %  Copyright 2009-2014 The MathWorks, Inc.
    %  $Revision$ $Date$
    
    methods
        
        function obj = Panel( varargin )
            %uix.Panel  Standard panel constructor
            %
            %  p = uix.Panel() constructs a standard panel.
            %
            %  p = uix.Panel(p1,v1,p2,v2,...) sets parameter p1 to value
            %  v1, etc.
            
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
            
            % Set positions and visibility
            children = obj.Contents_;
            selection = obj.Selection_;
            for ii = 1:numel( children )
                child = children(ii);
                if ii == selection
                    if obj.G1218142
                        warning( 'uix:G1218142', ...
                            'Selected child of %s is not visible due to bug G1218142.  The child will become visible at the next redraw.', ...
                            class( obj ) )
                        obj.G1218142 = false;
                    else
                        child.Visible = 'on';
                    end
                    child.Units = 'pixels';
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        switch child.ActivePositionProperty
                            case 'position'
                                child.Position = position;
                            case 'outerposition'
                                child.OuterPosition = position;
                            otherwise
                                error( 'uix:InvalidState', ...
                                    'Unknown value ''%s'' for property ''ActivePositionProperty'' of %s.', ...
                                    child.ActivePositionProperty, class( child ) )
                        end
                        child.ContentsVisible = 'on';
                    else
                        child.Position = position;
                    end
                else
                    child.Visible = 'off';
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        child.ContentsVisible = 'off';
                    end
                    % As a remedy for g1100294, move off-screen too
                    if isa( child, 'matlab.graphics.axis.Axes' ) ...
                            && strcmp(child.ActivePositionProperty, 'outerposition')
                        child.OuterPosition(1) = -child.OuterPosition(3)-20;
                    else
                        child.Position(1) = -child.Position(3)-20;
                    end
                end
            end
            
        end % redraw
        
    end % template methods
    
end % classdef