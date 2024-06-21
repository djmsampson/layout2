classdef TabPanel < uix.Container & uix.mixin.Panel
    %uix.TabPanel  Tab panel
    %
    %  p = uix.TabPanel(p1,v1,p2,v2,...) constructs a tab panel and sets
    %  parameter p1 to value v1, etc.
    %
    %  A tab panel shows one of its contents and hides the others according
    %  to which tab is selected.
    %
    %  From R2014b, MATLAB provides uitabgroup and uitab as standard
    %  components.  Consider using uitabgroup and uitab for new code if
    %  these meet your requirements.
    %
    %  See also: uitabgroup, uitab, uix.CardPanel

    %  Copyright 2009-2024 The MathWorks, Inc.

    properties( Access = public, Dependent, AbortSet )
        ForegroundColor % tab text color [RGB]
        TabContextMenus % tab context menus
        TabEnables % tab enable states
        TabLocation % tab location [top|bottom|left|right]
        TabTitles % tab titles
    end

    properties
        SelectionChangedFcn = '' % selection change callback
    end

    properties( Access = private )
        TabGroup % tab group
        BackgroundColorListener % listener
        SelectionChangedListener % listener
        ForegroundColor_ = get( 0, 'DefaultUicontrolForegroundColor' ) % backing for ForegroundColor
        TabEnables_ = cell( 0, 1 ) % backing for TabEnables
        TabSize = -1 % tab height or width, -1 for unknown
    end

    properties( Access = private, Constant )
        DummyControl = matlab.ui.control.UIControl() % dummy uicontrol
        FontAngle_ = get( 0, 'DefaultUicontrolFontAngle' ) % backing for FontAngle
        FontName_ = get( 0, 'DefaultUicontrolFontName' ) % backing for FontName
        FontSize_ = get( 0, 'DefaultUicontrolFontSize' ) % backing for FontSize
        FontWeight_ = get( 0, 'DefaultUicontrolFontWeight' ) % backing for FontWeight
        FontUnits_ = get( 0, 'DefaultUicontrolFontUnits' ) % backing for FontUnits
        HighlightColor_ = [1 1 1] % backing for HighlightColor
        ShadowColor_ = [0.7 0.7 0.7] % backing for ShadowColor
    end

    properties( Access = public, Dependent, AbortSet, Hidden )
        FontAngle % font angle
        FontName % font name
        FontSize % font size
        FontWeight % font weight
        FontUnits % font weight
        HighlightColor % border highlight color [RGB]
        ShadowColor % border shadow color [RGB]
        TabWidth % tab width
    end % deprecated

    methods

        function obj = TabPanel( varargin )
            %uix.TabPanel  Tab panel constructor
            %
            %  p = uix.TabPanel() constructs a tab panel.
            %
            %  p = uix.TabPanel(p1,v1,p2,v2,...) sets parameter p1 to value
            %  v1, etc.

            % Create tab group
            tabGroup = matlab.ui.container.TabGroup( ...
                'Internal', true, 'Parent', obj, ...
                'Units', 'normalized', 'Position', [0 0 1 1], ...
                'SelectionChangedFcn', @obj.onTabSelected );

            % Store properties
            obj.TabGroup = tabGroup;

            % Create listeners
            backgroundColorListener = event.proplistener( obj, ...
                findprop( obj, 'BackgroundColor' ), 'PostSet', ...
                @obj.onBackgroundColorChanged );
            selectionChangedListener = event.listener( obj, ...
                'SelectionChanged', @obj.onSelectionChanged );

            % Store listeners
            obj.BackgroundColorListener = backgroundColorListener;
            obj.SelectionChangedListener = selectionChangedListener;

            % Force tab group to be maximized
            addlistener( tabGroup, 'SizeChanged', @obj.onTabGroupSizeChanged );

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

        function value = get.ForegroundColor( obj )

            value = obj.ForegroundColor_;

        end % get.ForegroundColor

        function set.ForegroundColor( obj, value )

            % Check
            try
                obj.DummyControl.ForegroundColor = value; % RGB or special
                value = obj.DummyControl.ForegroundColor; % RGB
            catch
                error( 'uix:InvalidPropertyValue', ...
                    'Property ''ForegroundColor'' should be a colorspec.' )
            end

            % Set
            obj.ForegroundColor_ = value;

            % Redraw tabs
            obj.redrawTabs()

        end % set.ForegroundColor

        function value = get.TabEnables( obj )

            value = obj.TabEnables_;

        end % get.TabEnables

        function set.TabEnables( obj, value )

            % Convert
            try
                value = cellstr( value );
            catch
                error( 'uix:InvalidPropertyValue', ...
                    'Property ''TabEnables'' should be a cell array of strings ''on'' or ''off'', one per tab.' )
            end

            % Reshape
            value = reshape( value, [], 1 );

            % Check
            tabs = obj.TabGroup.Children;
            assert( isequal( size( value ), size( tabs ) ) && ...
                all( ismember( value, {'on','off'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabEnables'' should be a cell array of strings ''on'' or ''off'', one per tab.' )

            % Set
            obj.TabEnables_ = value;

            % Redraw tabs
            obj.redrawTabs()

            % Show selected child
            obj.showSelection()

        end % set.TabEnables

        function value = get.TabLocation( obj )

            value = obj.TabGroup.TabLocation;

        end % get.TabLocation

        function set.TabLocation( obj, value )

            % Convert
            try
                value = char( value );
            catch
                error( 'uix:InvalidPropertyValue', ...
                    'Property ''TabLocation'' should be ''top'', ''bottom'', ''left'' or ''right''.' )
            end

            % Check
            assert( ismember( value, {'top','bottom','left','right'} ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabLocation'' should be ''top'', ''bottom'', ''left'' or ''right''.' )

            % Set
            obj.TabGroup.TabLocation = value;

            % Unset tab size
            obj.TabSize = -1;

            % Mark as dirty
            obj.Dirty = true;

        end % set.TabLocation

        function value = get.TabTitles( obj )

            value = get( obj.TabGroup.Children, {'Title'} );

        end % get.TabTitles

        function set.TabTitles( obj, value )

            % Convert
            try
                value = cellstr( value );
            catch
                error( 'uix:InvalidPropertyValue', ...
                    'Property ''TabTitles'' should be a cell array of strings, one per tab.' )
            end

            % Reshape
            value = reshape( value, [], 1 );

            % Check
            tabs = obj.TabGroup.Children;
            assert( isequal( size( value ), size( tabs ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabTitles'' should be a cell array of strings, one per tab.' )

            % Set
            for ii = 1:numel( tabs )
                tabs(ii).Title = value{ii};
            end

            % Unset tab size
            obj.TabSize = -1;

            % Mark as dirty
            obj.Dirty = true;

        end % set.TabTitles

        function value = get.TabContextMenus( obj )

            value = get( obj.TabGroup.Children, {'UIContextMenu'} );

        end % get.TabContextMenus

        function set.TabContextMenus( obj, value )

            % Reshape
            value = reshape( value, [], 1 );

            % Check
            tabs = obj.TabGroup.Children;
            assert( iscell( value ) && ...
                isequal( size( value ), size( tabs ) ) && ...
                all( cellfun( @iscontextmenu, value(:) ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabContextMenus'' should be a cell array of context menus, one per tab.' )

            % Set
            for ii = 1:numel( tabs )
                tabs(ii).UIContextMenu = value{ii};
            end

        end % set.TabContextMenus

        function set.SelectionChangedFcn( obj, value )

            % Check
            if ischar( value ) % string
                % OK
            elseif isa( value, 'function_handle' ) && ...
                    isequal( size( value ), [1 1] ) % function handle
                % OK
            elseif iscell( value ) && ndims( value ) == 2 && ...
                    size( value, 1 ) == 1 && size( value, 2 ) > 0 && ...
                    isa( value{1}, 'function_handle' ) && ...
                    isequal( size( value{1} ), [1 1] ) %#ok<ISMAT> % cell callback
                % OK
            else
                error( 'uix:InvalidPropertyValue', ...
                    'Property ''SelectionChangedFcn'' must be a valid callback.' )
            end

            % Set
            obj.SelectionChangedFcn = value;

        end % set.SelectionChangedFcn

    end % accessors

    methods

        function value = get.FontAngle( obj )

            value = obj.FontAngle_;

        end % get.FontAngle

        function set.FontAngle( obj, ~ )

            warning( 'uix:Deprecated', ...
                'Property ''FontAngle'' of %s is deprecated.', ...
                class( obj ) )

        end % set.FontAngle

        function value = get.FontName( obj )

            value = obj.FontName_;

        end % get.FontName

        function set.FontName( obj, ~ )

            warning( 'uix:Deprecated', ...
                'Property ''FontName'' of %s is deprecated.', ...
                class( obj ) )

        end % set.FontName

        function value = get.FontSize( obj )

            value = obj.FontSize_;

        end % get.FontSize

        function set.FontSize( obj, ~ )

            warning( 'uix:Deprecated', ...
                'Property ''FontSize'' of %s is deprecated.', ...
                class( obj ) )

        end % set.FontSize

        function value = get.FontWeight( obj )

            value = obj.FontWeight_;

        end % get.FontWeight

        function set.FontWeight( obj, ~ )

            warning( 'uix:Deprecated', ...
                'Property ''FontWeight'' of %s is deprecated.', ...
                class( obj ) )

        end % set.FontWeight

        function value = get.FontUnits( obj )

            value = obj.FontUnits_;

        end % get.FontUnits

        function set.FontUnits( obj, ~ )

            warning( 'uix:Deprecated', ...
                'Property ''FontUnits'' of %s is deprecated.', ...
                class( obj ) )

        end % set.FontUnits

        function value = get.HighlightColor( obj )

            value = obj.HighlightColor_;

        end % get.HighlightColor

        function set.HighlightColor( obj, ~ )

            warning( 'uix:Deprecated', ...
                'Property ''ForegroundColor'' of %s is deprecated.', ...
                class( obj ) )

        end % set.HighlightColor

        function value = get.ShadowColor( obj )

            value = obj.ShadowColor_;

        end % get.ShadowColor

        function set.ShadowColor( obj, ~ )

            warning( 'uix:Deprecated', ...
                'Property ''ShadowColor'' of %s is deprecated.', ...
                class( obj ) )

        end % set.ShadowColor

        function value = get.TabWidth( ~ )

            value = -1;

        end % get.TabWidth

        function set.TabWidth( obj, ~ )

            warning( 'uix:Deprecated', ...
                'Property ''TabWidth'' of %s is deprecated.', ...
                class( obj ) )

        end % set.TabWidth

    end % deprecated accessors

    methods( Access = protected )

        function redraw( obj )
            %redraw  Redraw

            % Get selection
            selection = obj.Selection_;
            if selection == 0, return, end

            % Update tab size
            s = obj.TabSize; % retrieve
            if s == -1 % unknown
                g = obj.TabGroup;
                t = g.SelectedTab;
                f = ancestor( g, 'figure' );
                drawnow() % force redraw
                gb = hgconvertunits( f, [0 0 1 1], ...
                    'normalized', 'pixels', g ); % tab group bounds
                tb = hgconvertunits( f, [0 0 1 1], ...
                    'normalized', 'pixels', t ); % tab bounds
                switch g.TabLocation
                    case 'top'
                        s = gb(4) - tb(4) - 3;
                    case 'bottom'
                        s = gb(4) - tb(4) - 2;
                    case 'left'
                        s = gb(3) - tb(3) - 2;
                    case 'right'
                        s = gb(3) - tb(3) - 3;
                end
                obj.TabSize = s; % store
            end

            % Compute positions
            b = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj ); % tab
            p = obj.Padding_; % padding
            switch obj.TabGroup.TabLocation
                case 'top'
                    x = 3 + p;
                    y = 3 + p;
                    w = b(3) - 2 * p - 3;
                    h = b(4) - s - 2 * p - 2;
                case 'bottom'
                    x = 3 + p;
                    y = 1 + s + p;
                    w = b(3) - 2 * p - 3;
                    h = b(4) - s - 2 * p - 2;
                case 'left'
                    x = 1 + s + p;
                    y = 3 + p;
                    w = b(3) - s - 2 * p - 2;
                    h = b(4) - 2 * p - 4;
                case 'right'
                    x = 3 + p;
                    y = 3 + p;
                    w = b(3) - s - 2 * p - 2;
                    h = b(4) - 2 * p - 4;
            end
            w = max( ceil( w ), 1 );
            h = max( ceil( h ), 1 );
            contentsPosition = [x y w h];

            % Redraw contents
            selection = obj.Selection_;
            if selection ~= 0 && strcmp( obj.TabEnables_{selection}, 'on' )
                uix.setPosition( obj.Contents_(selection), contentsPosition, 'pixels' )
            end

        end % redraw

        function addChild( obj, child )
            %addChild  Add child
            %
            %  c.addChild(d) adds the child d to the container c.

            % Create new tab
            tabGroup = obj.TabGroup;
            tabs = tabGroup.Children;
            n = numel( tabs );
            uitab( 'Parent', tabGroup, 'Title', sprintf( 'Tab %d', n+1 ), ...
                'ForegroundColor', obj.ForegroundColor, ...
                'BackgroundColor', obj.BackgroundColor );
            obj.TabEnables_(n+1,:) = {'on'};

            % Call superclass method
            addChild@uix.mixin.Panel( obj, child )

        end % addChild

        function removeChild( obj, child )
            %removeChild  Remove child
            %
            %  c.removeChild(d) removes the child d from the container c.

            % Find index of removed child
            contents = obj.Contents_;
            index = find( contents == child );

            % Remove tab
            delete( obj.TabGroup.Children(index) )
            obj.TabEnables_(index,:) = [];

            % Call superclass method
            removeChild@uix.mixin.Panel( obj, child )

        end % removeChild

        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).

            % Reorder
            obj.TabGroup.Children = obj.TabGroup.Children(indices,:);

            % Call superclass method
            reorder@uix.mixin.Panel( obj, indices )

        end % reorder

        function reparent( obj, oldFigure, newFigure )
            %reparent  Reparent container
            %
            %  c.reparent(a,b) reparents the container c from the figure a
            %  to the figure b.

            if ~isequal( oldFigure, newFigure )
                contextMenus = obj.TabContextMenus;
                for ii = 1:numel( contextMenus )
                    contextMenu = contextMenus{ii};
                    if ~isempty( contextMenu )
                        contextMenu.Parent = newFigure;
                    end
                end
            end

            % Call superclass method
            reparent@uix.mixin.Panel( obj, oldFigure, newFigure )

        end % reparent

        function showSelection( obj )
            %showSelection  Show selected child, hide the others
            %
            %  c.showSelection() shows the selected child of the container
            %  c, and hides the others.

            % Call superclass method
            showSelection@uix.mixin.Panel( obj )

            % If not enabled, hide selected contents too
            selection = obj.Selection_;
            if selection ~= 0 && strcmp( obj.TabEnables{selection}, 'off' )
                child = obj.Contents_(selection);
                child.Visible = 'off';
                if isa( child, 'matlab.graphics.axis.Axes' )
                    child.ContentsVisible = 'off';
                end
                % As a remedy for g1100294, move off-screen too
                margin = 1000;
                if isa( child, 'matlab.graphics.axis.Axes' ) ...
                        && strcmp(child.ActivePositionProperty, 'outerposition' )
                    child.OuterPosition(1) = -child.OuterPosition(3)-margin;
                else
                    child.Position(1) = -child.Position(3)-margin;
                end
            end

        end % showSelection

    end % template methods

    methods( Access = private )

        function redrawTabs( obj )
            %redrawTabs  Redraw tabs

            enableColor = obj.ForegroundColor_;
            disableColor = enableColor + 0.75 * ([1 1 1] - enableColor);
            tf = strcmp( obj.TabEnables_, 'on' );
            tabs = obj.TabGroup.Children;
            set( tabs(tf), 'ForegroundColor', enableColor )
            set( tabs(~tf), 'ForegroundColor', disableColor )

        end % redrawTabs

    end % helper methods

    methods( Access = private )

        function onTabSelected( obj, ~, ~ )
            %onTabSelected  Event handler for interactive tab selection
            %
            %  onTabSelected shows the child of the selected tab and
            %  prevents selection of disabled tabs.

            % Update selection
            oldSelection = obj.Selection_;
            tabGroup = obj.TabGroup;
            newSelection = find( tabGroup.SelectedTab == obj.TabGroup.Children );
            if oldSelection == newSelection
                % no op
            elseif strcmp( obj.TabEnables_{newSelection}, 'off' )
                tabGroup.SelectedTab = tabGroup.Children(oldSelection); % revert
            else
                obj.Selection = newSelection; % update selection
            end

        end % onTabSelected

        function onBackgroundColorChanged( obj, ~, ~ )
            %onBackgroundColorChanged  Event handler for background color
            %
            %  onBackgroundColorChanged synchronizes the background color
            %  of each tab with that of the panel.

            % Set all tab background colors
            set( obj.TabGroup.Children, 'BackgroundColor', obj.BackgroundColor )

        end % onBackgroundColorChanged

        function onSelectionChanged( obj, source, eventData )
            %onSelectionChanged  Event handler for programmatic selection
            %
            %  onSelectionChanged updates the tab selection when the panel
            %  selection changes.

            % Select tab
            selection = obj.Selection_;
            if selection ~= 0
                obj.TabGroup.SelectedTab = obj.TabGroup.Children(selection);
            end

            % Call callback
            callback = obj.SelectionChangedFcn;
            if ischar( callback ) && isequal( callback, '' )
                % do nothing
            elseif ischar( callback )
                feval( callback, source, eventData )
            elseif isa( callback, 'function_handle' )
                callback( source, eventData )
            elseif iscell( callback )
                feval( callback{1}, source, eventData, callback{2:end} )
            end

        end % onSelectionChanged

        function onTabGroupSizeChanged( ~, tabGroup, ~ )
            %onTabGroupSizeChanged  Remedial event handler
            %
            %  onTabGroupSizeChanged keeps the uitabgroup maximized within
            %  its container, despite the best efforts of
            %  matlab.ui.internal.WebTabGroupController et al.

            tabGroup.Position = [0 0 1 1]; % maximized

        end % onTabGroupSizeChanged

    end % event handlers

end % classdef

function tf = iscontextmenu( o )
%iscontextmenu  Test for context menu
%
%  tf = iscontextmenu(o) returns true if o is a valid UIContextMenu value,
%  that is, a scalar context menu or an empty graphics placeholder

if isa( o, 'matlab.ui.container.ContextMenu' ) && isscalar( o ) % context menu
    tf = true;
elseif isequal( o, gobjects( 0 ) ) % graphics placeholder
    tf = true;
else % something else
    tf = false;
end

end % iscontextmenu