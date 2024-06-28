classdef CardPanel < uix.Container & uix.mixin.Container
    %uix.CardPanel  Card panel
    %
    %  b = uix.CardPanel(p1,v1,p2,v2,...) constructs a card panel and sets
    %  parameter p1 to value v1, etc.
    %
    %  A card panel is a standard container (uicontainer) that shows one
    %  its contents and hides the others.
    %
    %  See also: uix.Panel, uix.BoxPanel, uix.TabPanel, uicontainer
    
    %  Copyright 2009-2024 The MathWorks, Inc.

    properties( Access = public, Dependent, AbortSet )
        Selection % selection
    end

    properties
        SelectionChangedFcn = '' % selection change callback
    end

    events( NotifyAccess = private )
        SelectionChanged % selection changed
    end
    
    methods
        
        function obj = CardPanel( varargin )
            %uix.CardPanel  Card panel constructor
            %
            %  p = uix.CardPanel() constructs a card panel.
            %
            %  p = uix.CardPanel(p1,v1,p2,v2,...) sets parameter p1 to
            %  value v1, etc.
            
            % Set properties
            try
                uix.set( obj, varargin{:} )
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
        end % constructor
        
    end % structors

    methods

        function value = get.Selection( obj )

            value = obj.Selection_;

        end % get.Selection

        function set.Selection( obj, newValue )

            % Select
            oldValue = obj.Selection;
            tabGroup = obj.TabGroup;
            try
                assert( isscalar( newValue ) )
                tabGroup.SelectedTab = tabGroup.Children(newValue);
            catch
                error( 'uix:InvalidPropertyValue', ...
                    'Property ''Selection'' must be between 1 and the number of tabs.' )
            end

            % Raise event
            notify( obj, 'SelectionChanged', ...
                uix.SelectionChangedData( oldValue, newValue ) )

            % Show selection
            obj.showSelection()

            % Mark as dirty
            obj.Dirty = true;

        end % set.Selection


    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw
            
            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            padding = obj.Padding_;
            xSizes = uix.calcPixelSizes( bounds(3), -1, 1, padding, 0 );
            ySizes = uix.calcPixelSizes( bounds(4), -1, 1, padding, 0 );
            position = [padding+1 padding+1 xSizes ySizes];
            
            % Redraw contents
            selection = obj.Selection_;
            if selection ~= 0
                uix.setPosition( obj.Contents_(selection), position, 'pixels' )
            end
            
        end % redraw
        
    end % template methods
    
end % classdef