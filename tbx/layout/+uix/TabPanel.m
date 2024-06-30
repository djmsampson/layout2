classdef TabPanel < uix.Container & uix.mixin.Container
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
        Selection % selection
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

    properties( Access = public, Dependent, Hidden )
        FontAngle % font angle
        FontName % font name
        FontSize % font size
        FontWeight % font weight
        FontUnits % font weight
        HighlightColor % border highlight color [RGB]
        ShadowColor % border shadow color [RGB]
        TabWidth % tab width
    end % deprecated

    events( NotifyAccess = private )
        SelectionChanged % selection changed
    end

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
                'SelectionChangedFcn', @obj.onTabSelected, ...
                'SizeChangedFcn', @obj.onTabGroupSizeChanged );
            if isprop( tabGroup, 'AutoResizeChildren' )
                tabGroup.AutoResizeChildren = 'off';
            end

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

        function value = get.Selection( obj )

            tabGroup = obj.TabGroup;
            value = find( tabGroup.Children == tabGroup.SelectedTab );
            if isempty( value ), value = 0; end

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

            % Show and hide
            contents = obj.Contents_;
            obj.hideChild( contents(oldValue) )
            obj.showChild( contents(newValue) )

            % Mark as dirty
            obj.Dirty = true;

        end % set.Selection

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
            assert( isequal( numel( value ), numel( tabs ) ) && ...
                all( ismember( value, {'on','off'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabEnables'' should be a cell array of strings ''on'' or ''off'', one per tab.' )

            % Set
            obj.TabEnables_ = value;

            % Redraw tabs
            obj.redrawTabs()

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
            assert( isequal( numel( value ), numel( tabs ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabTitles'' should be a cell array of strings, one per tab.' )

            % Set
            for ii = 1:numel( tabs )
                tabs(ii).Title = value{ii};
            end

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
                numel( value ) == numel( tabs ) && ...
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
            if ischar( value ) || isa( value, 'string' ) % string
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

            % Check for enabled contents
            selection = obj.Selection;
            if selection == 0, return, end % no contents

            % Compute positions
            g = obj.TabGroup;
            f = ancestor( g, 'figure' );
            gb = hgconvertunits( f, [0 0 1 1], 'normalized', 'pixels', g );
            t = g.SelectedTab;
            tb = hgconvertunits( f, [0 0 1 1], 'normalized', 'pixels', t );
            pa = obj.Padding_;
            switch g.TabLocation
                case 'top'
                    m = (gb(3)-tb(3))/2;
                    cp = tb + [m m 0 0] + pa * [1 1 -2 -2];
                case 'bottom'
                    m = (gb(3)-tb(3))/2;
                    cp = tb + [m gb(4)-tb(4)-m 0 0] + pa * [1 1 -2 -2]; % TODO
                case 'left'
                    m = (gb(4)-tb(4))/2;
                    cp = tb + [gb(3)-tb(3)-m m 0 0] + pa * [1 1 -2 -2]; % TODO
                case 'right'
                    m = (gb(4)-tb(4))/2;
                    cp = tb + [m m 0 0] + pa * [1 1 -2 -2];
            end

            % Redraw contents
            uix.setPosition( obj.Contents_(selection), cp, 'pixels' )

        end % redraw

        function addChild( obj, child )
            %addChild  Add child
            %
            %  c.addChild(d) adds the child d to the container c.

            % Call superclass method
            addChild@uix.mixin.Container( obj, child )

            % Create new tab
            tabGroup = obj.TabGroup;
            tabs = tabGroup.Children;
            n = numel( tabs );
            tab = uitab( 'Parent', tabGroup, ...
                'Title', sprintf( 'Tab %d', n+1 ), ...
                'ForegroundColor', obj.ForegroundColor, ...
                'BackgroundColor', obj.BackgroundColor );
            if isprop( tab, 'AutoResizeChildren' )
                tab.AutoResizeChildren = 'off';
            end
            tab.SizeChangedFcn = @obj.onTabSizeChanged;
            obj.TabEnables_(n+1,:) = {'on'};

            % Show and hide
            if obj.Contents_(obj.Selection) == child
                obj.showChild( child )
            else
                obj.hideChild( child )
            end

        end % addChild

        function removeChild( obj, child )
            %removeChild  Remove child
            %
            %  c.removeChild(d) removes the child d from the container c.

            % Capture old state
            oldContents = obj.Contents_;
            oldSelection = obj.Selection;

            % Call superclass method
            removeChild@uix.mixin.Container( obj, child )

            % Remove tab
            index = find( oldContents == child );
            tabGroup = obj.TabGroup;
            delete( tabGroup.Children(index) )
            obj.TabEnables_(index,:) = [];

            % Show
            if index == oldSelection
                newContents = obj.Contents_;
                newSelection = obj.Selection;
                if newSelection ~= 0
                    obj.showChild( newContents(newSelection) )
                end
            end

        end % removeChild

        function reorder( obj, indices )
            %reorder  Reorder contents
            %
            %  c.reorder(i) reorders the container contents using indices
            %  i, c.Contents = c.Contents(i).

            % Call superclass method
            reorder@uix.mixin.Container( obj, indices )

            % Reorder
            tabGroup = obj.TabGroup;
            tabGroup.Children = tabGroup.Children(indices,:);
            obj.TabEnables_ = obj.TabEnables_(indices,:);

        end % reorder

        function reparent( obj, oldFigure, newFigure )
            %reparent  Reparent container
            %
            %  c.reparent(a,b) reparents the container c from the figure a
            %  to the figure b.

            % Call superclass method
            reparent@uix.mixin.Container( obj, oldFigure, newFigure )

            % Move context menus to new figure
            if ~isequal( oldFigure, newFigure )
                contextMenus = vertcat( obj.TabContextMenus{:} );
                set( contextMenus, 'Parent', newFigure );
            end

        end % reparent

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

        function onTabSelected( obj, ~, eventData )
            %onTabSelected  Event handler for interactive tab selection
            %
            %  onTabSelected shows the child of the selected tab and
            %  prevents selection of disabled tabs.

            % Find old and new selections
            tabGroup = obj.TabGroup;
            oldSelection = find( tabGroup.Children == eventData.OldValue );
            newSelection = find( tabGroup.Children == eventData.NewValue );

            if strcmp( obj.TabEnables_{newSelection}, 'off' )

                % Revert
                tabGroup.SelectedTab = eventData.OldValue;

            else

                % Raise event
                notify( obj, 'SelectionChanged', ...
                    uix.SelectionChangedData( oldSelection, newSelection ) )

                % Show and hide
                contents = obj.Contents_;
                obj.hideChild( contents(oldSelection) )
                obj.showChild( contents(newSelection) )

                % Mark as dirty
                obj.Dirty = true;

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
            %onSelectionChanged  Event handler for selection
            %
            %  onSelectionChanged calls the SelectionChangedFcn when a
            %  SelectionChanged event is raised.

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

        function onTabSizeChanged( obj, tab, ~ )
            %onTabSizeChanged  Event handler for tab resize

            % Ignore unselected tabs
            if obj.TabGroup.SelectedTab ~= tab, return, end

            % Mark as dirty
            obj.Dirty = true;

        end % onTabSizeChanged

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