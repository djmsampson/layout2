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
        Selection_ = 0 % backing for Selection
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

            % Check
            try
                validateattributes( newValue, {'numeric'}, ...
                    {'scalar','integer','positive'} )
                assert( newValue <= numel( obj.Contents_ ) ) % 0 AbortSet
            catch
                error( 'uix:InvalidPropertyValue', ...
                    'Property ''Selection'' must be between 1 and the number of contents.' )
            end

            % Set
            oldValue = obj.Selection_;
            obj.Selection_ = newValue;

            % Raise event
            notify( obj, 'SelectionChanged', ... )
                uix.SelectionChangedData( oldValue, newValue ) )

            % Hide old selection
            obj.hideChild( obj.Contents_(oldValue) )

            % Show new selection
            obj.showChild( obj.Contents_(newValue) )

            % Mark as dirty
            obj.Dirty = true;

        end % set.Selection

    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw

            % Return if no contents
            selection = obj.Selection_;
            if selection == 0, return, end
            
            % Compute positions
            b = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            p = obj.Padding_;
            w = uix.calcPixelSizes( b(3), -1, 1, p, 0 );
            h = uix.calcPixelSizes( b(4), -1, 1, p, 0 );
            position = [1+p 1+p w h];
            
            % Redraw contents
            uix.setPosition( obj.Contents_(selection), position, 'pixels' )
            
        end % redraw

        function addChild( obj, child )
            %addChild  Add child
            %
            %  c.addChild(d) adds the child d to the container c.

            % Hide old selection
            oldSelection = obj.Selection_;
            oldContents = obj.Contents_;
            if oldSelection ~= 0
                obj.hideChild( oldContents(oldSelection) )
            end

            % Call superclass method
            addChild@uix.mixin.Container( obj, child )

            % Select new child
            newContents = obj.Contents_;
            newSelection = find( newContents == child );
            obj.Selection_ = newSelection;

            % Show new selection
            obj.showChild( child )

            % Mark as dirty
            obj.Dirty = true;

        end % addChild

        function removeChild( obj, child )
            %removeChild  Remove child
            %
            %  c.removeChild(d) removes the child d from the container c.

            % Compute new selection
            contents = obj.Contents_;
            index = find( contents == child );
            oldSelection = obj.Selection_;
            if index < oldSelection
                newSelection = oldSelection - 1;
            elseif index > oldSelection
                newSelection = oldSelection;
            else % index == oldSelection
                newSelection = min( oldSelection, numel( contents ) - 1 );
            end

            % Hide old selection
            obj.hideChild( contents(oldSelection) )

            % Call superclass method
            removeChild@uix.mixin.Container( obj, child )

            % Select
            obj.Selection_ = newSelection;

            % Show new selection
            if newSelection ~= 0
                obj.showChild( obj.Contents_(newSelection) )
            end

            % Mark as dirty
            obj.Dirty = true;

        end % removeChild

        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).

            % Call superclass method
            reorder@uix.mixin.Container( obj, indices )

            % Update selection
            oldSelection = obj.Selection_;
            if oldSelection ~= 0
                newSelection = find( indices == oldSelection );
                obj.Selection_ = newSelection;
            end

        end % reorder
        
    end % template methods
    
end % classdef