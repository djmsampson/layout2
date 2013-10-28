classdef TabPanel < uix.Container
    
    properties( Dependent, AbortSet )
        TabNames
    end
    
    properties
        Group
        SelectionListener
    end
    
    methods
        
        function obj = TabPanel( varargin )
            
            % Call superclass constructor
            obj@uix.Container()
            
            % Create tab group
            group = matlab.ui.container.TabGroup( 'Internal', true, ...
                'Parent', obj, 'Units', 'normalized', ...
                'Position', [0 0 1 1] );
            
            % Create listener
            selectionListener = event.listener( group, ...
                'SelectionChange', @obj.onSelectionChange );
            
            % Store properties
            obj.Group = group;
            obj.SelectionListener = selectionListener;
            
            % Set properties
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.TabNames( obj )
            
            value = get( obj.Group.Children, {'Title'} );
            
        end % get.TabNames
        
        function set.TabNames( obj, value )
            
            % Check
            tabs = obj.Group.Children;
            assert( iscellstr( value ) && ...
                isequal( size( value ), size( tabs ) ), ...
                'uix.InvalidPropertyValue', ...
                'Size of ''TabNames'' must match number of tabs.' )
            
            % Set
            for ii = 1:numel( value )
                tabs(ii).Title = value{ii};
            end
            
        end % set.TabNames
        
    end % accessors
    
    methods( Access = protected )
        
        function addChild( obj, child )
            
            % Add tab
            [~] = uitab( 'Parent', obj.Group );
            
            % Call superclass method
            addChild@uix.Container( obj, child )
            
        end % addChild
        
        function removeChild( obj, child )
            
            % Remove current tab
            delete( obj.Group.SelectedTab )
            
            % Call superclass method
            removeChild@uix.Container( obj, child )
            
        end % removeChild
        
        function reorder( obj, indices )
            
            % Reorder tab group children
            obj.Group.Children = obj.Group.Children( indices );
            
            % Call superclass method
            reorder@uix.Container( obj, indices )
            
        end % reorder
        
        function redraw( obj )
            
            % Compute positions
            group = obj.Group;
            tab = group.SelectedTab;
            if isempty( tab ), return, end
            % drawnow() % force update
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                tab.Position, tab.Units, 'pixels', group );
            padding = obj.Padding_;
            xSizes = uix.calcPixelSizes( bounds(3), -1, 1, padding, 0 );
            ySizes = uix.calcPixelSizes( bounds(4), -1, 1, padding, 0 );
            position = [padding+1 padding+1 xSizes ySizes];
            
            % Set positions and visibility
            selection = find( group.SelectedTab == group.Children );
            children = obj.Contents_;
            for ii = 1:numel( children )
                child = children(ii);
                if ii == selection
                    child.Visible = 'on';
                    child.Units = 'pixels';
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        child.( child.ActivePositionProperty ) = position;
                        child.ContentsVisible = 'on';
                    else
                        child.Position = position;
                    end
                else
                    child.Visible = 'off';
                    if isa( child, 'matlab.graphics.axis.Axes' )
                        child.ContentsVisible = 'off';
                    end
                end
            end
            
        end % redraw
        
    end % template methods
    
    methods( Access = private )
        
        function onSelectionChange( obj, ~, ~ )
            
            % Redraw
            obj.redraw()
            
        end % onSelectionChange
        
    end % event handlers
    
end % classdef