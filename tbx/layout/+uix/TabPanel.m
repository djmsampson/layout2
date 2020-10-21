classdef TabPanel < matlab.mixin.SetGet %uix.Container & uix.mixin.Panel % Removed this inheritance as it seems to clash with uitab
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
    
    %  Copyright 2009-2016 The MathWorks, Inc.
    %  $Revision: 1790 $ $Date: 2019-03-03 23:07:34 +0000 (Sun, 03 Mar 2019) $
    
   
    properties
        SelectionChangedFcn = '' % selection change callback
        Tag (1,1) string % Arbitrary user settable tag to add to layout.
    end
    
    properties ( Dependent )
        Selection(1, 1) {mustBeInteger, mustBeNonnegative}
        TabEnables (1,:) cell {mustBeMember(TabEnables,{'on','off'})}% tab enable states
        ForegroundColor (1,3) {mustBeInRange(ForegroundColor,0,1)}
        Children % The tabgroup children
        Contents % Tabgroup children in their left to right order - this is redundant with uitab but kept for compatability.
    end % properties ( Dependent )
    
    properties( Access = private, Dependent)
        Tabs
    end
        properties( Access = public, Dependent, SetObservable)
        Parent
    end
    
    properties( Access = public, Dependent, AbortSet )
        TabLocation % tab location [top|bottom]
        TabTitles (1,:) string % tab titles
        TabContextMenus % tab context menus
    end
    
    properties( Access = private )
        TabEnables_ % Backing for dependent property TabEnables
        ForegroundColor_ = get( 0, 'DefaultUicontrolForegroundColor' ) % backing for ForegroundColor
        ParentBackgroundColor = get( 0, 'DefaultUicontrolForegroundColor' ) % default parent background color
        TabListeners = event.listener.empty( [0 1] ) % tab listeners
        TabLocation_ = 'top' % backing for TabPosition
        TabHeight = -1 % cache of tab height (-1 denotes stale cache)
        BackgroundColorListener % listener
        SelectionChangedListener % listener
        ParentListener % listener
        ParentBackgroundColorListener % listener
        Dirty
        Dividers % tab dividers WILL BE REMOVED
    end
    
    
    properties % ( Access = private ) % Make private when done
        TabGroup(1, 1) matlab.ui.container.TabGroup
    end
    
    % Legacy properties to check against for backwards compatability
    properties ( Constant , Access = private ) 
       OldPanelProperties = ["BackgroundColor","BeingDeleted","Contents","DeleteFcn","FontAngle","FontName","FontSize","FontUnits","FontWeight","ForegroundColor","HighlightColor","ShadowColor","Padding","Parent","Position","Selection","SelectionChangedFcn","TabContextMenus","TabEnables","TabTitles","TabWidth","Tag","Type","Units","Visible"];
       OldUiControlArguments = ["HorizontalAlignment","ListboxTop","Max","Min","SliderStep","String","Style","Value","Position","BackgroundColor","CData","Callback","Children","Tooltip","ForegroundColor","Enable","Extent","Visible","Parent","HandleVisibility","ButtonDownFcn","ContextMenu","BusyAction","BeingDeleted","Interruptible","CreateFcn","DeleteFcn","Type","Tag","UserData","KeyPressFcn","KeyReleaseFcn","FontUnits","FontSize","FontName","FontAngle","FontWeight","Units","InnerPosition","OuterPosition"];
    end % (Constant,Hidden) Backwards compatability checks
       
    properties ( Constant, Hidden ) % Temporarily removed functionality due to webgraphics
        TabWidth = -1 % tab width
        TabWidth_ = -1 % backing for TabWidth
        FontAngle = get( 0, 'DefaultUicontrolFontAngle' ) % font angle
        FontAngle_ = get( 0, 'DefaultUicontrolFontAngle' ) % backing for FontAngle
        FontName = get( 0, 'DefaultUicontrolFontName' ) % font name
        FontName_ = get( 0, 'DefaultUicontrolFontName' ) % backing for FontName
        FontSize = get( 0, 'DefaultUicontrolFontSize' ) % font size
        FontSize_ = get( 0, 'DefaultUicontrolFontSize' ) % backing for FontSize
        FontWeight = get( 0, 'DefaultUicontrolFontWeight' ) % font weight
        FontWeight_ = get( 0, 'DefaultUicontrolFontWeight' ) % backing for FontWeight
        FontUnits = get( 0, 'DefaultUicontrolFontUnits' ) % font weight
        FontUnits_ = get( 0, 'DefaultUicontrolFontUnits' ) % font weight
        HighlightColor = [0,0,0] % border highlight color [RGB]
        ShadowColor = [0.7,0.7,0.7] % border shadow color [RGB]
        HighlightColor_ = [1 1 1] % backing for HighlightColor
        ShadowColor_ = [0.7 0.7 0.7] % backing for ShadowColor
        FontNames = listfonts() % all available font names
        Tint = 0.85 % tint factor for unselected tabs
    end % Removed properties
    
    events
        SelectionChanged
    end
    
    methods
        
        function obj = TabPanel( varargin )
            %uix.TabPanel  Tab panel constructor
            %
            %  p = uix.TabPanel() constructs a tab panel.
            %
            %  p = uix.TabPanel(P) constructs a tab panel with parent P
            %
            % p = uix.TabPanel(p1,v1,p2,v2,...) constructs a tab panel with
            % parent P then sets parameter p1 to value P2
            %
            %  p = uix.TabPanel(p1,v1,p2,v2,...) sets parameter p1 to value
            %  v1, etc. Parent can be a name value pair
            
            
           
            % If odd number of inputs, first is parent, add the name for consistency
            if mod(numel(varargin),2) == 1
                varargin=['parent',varargin];
            end
            
            % Create the tab group, the only consitent property is the selection changed callback
                tabGroup = matlab.ui.container.TabGroup( ...
                    'SelectionChangedFcn', @obj.onSelectionChanged );
           
            % Validate arguments against properties of the current releases uitabgroup
            % If a property fails to validate, check it against legacy properties
            % If it validates against a legacy property, skip that name-value
            % Pair and give a warning instead of an error
            uiTabProps = properties(tabGroup);
            idx = zeros(size(varargin),"logical");
            
            for k = 1:numel(idx)/2
                try
                    % Validate potential typos
                    varargin{2*k-1} = validatestring(varargin{2*k-1},uiTabProps);
                    % If successfully validated, logically index them in
                    idx(2*k-1)=1;
                    idx(2*k)=1;
                catch
                    try
                        % If unsuccessful try validation against legacy arguments
                        oldArgument = validatestring(varargin{2*k-1},obj.OldPanelProperties);
                        % If successfully validated against a legacy
                        % argument, warn but don't include.
                        warning("The property '" +oldArgument + "' is no longer supported and will be ignored.")
                    catch
                        % If it doesnt validate against any argument old or
                        % new, error.
                        error("uix:InvalidArgument","'" + varargin{2*k-1} + "' is not a valid argument name.")
                    end
                end
            end
            
            varargin=varargin(idx); % Filter the varargin to have the non rejected properties.
            
            % Because we checked and removed the parent, the remaining
            % entries should all be name then value
            
            % TODO: Do we need these???
            % Create listeners
            %backgroundColorListener = event.proplistener( obj, ...
            %    findprop( obj, 'BackgroundColor' ), 'PostSet', ...
            %    @obj.onBackgroundColorChanged );
            %selectionChangedListener = event.listener( obj, ...
            %    'SelectionChanged', @obj.onSelectionChanged );
            %parentListener = event.proplistener( obj, ...
            %    findprop( obj, 'Parent' ), 'PostSet', ...
            %    @obj.onParentChanged );
            
            % Store properties
            obj.TabGroup = tabGroup;
            %obj.BackgroundColorListener = backgroundColorListener;
            %obj.SelectionChangedListener = selectionChangedListener;
            %obj.ParentListener = parentListener;
            
           
            % Set properties
            try
                if numel(varargin) > 0 % Make sure we havnet already dealt with all of the arguments
                    %uix.set is also an option
                    set( obj.TabGroup, varargin{:} );
                end % if
            catch e
                delete( obj )
                e.throwAsCaller()
            end
                       
        end % constructor
        
          % Backwards compatability by overloading uicontrol
        function tab=uicontrol(varargin)
            try
                tab=addTab(varargin{:});
            catch ME
                ME.throwAsCaller;
                % Alternative way to force the correct uix error id
                %error("uix:InvalidPropertyValue",ME.message);
            end
        end % uicontrol
        
        
        % Overload uitab so that it works to be intuative for new users.
        function tab=uitab(varargin)
            try
                tab=addTab(varargin{:});
            catch ME
                ME.throwAsCaller;
                % Alternative way to force the correct uix error id
                % error("uix:InvalidPropertyValue",ME.message);
            end
        end % uitab
        
    end % structors
    
    methods
        
        function value = get.Parent(obj)
           value = obj.TabGroup.Parent; 
        end
        
        function set.Parent(obj,value)
           obj.TabGroup.Parent = value;           
        end
        
        function value = get.Children( obj )
            
            value = obj.TabGroup.Children;
            
        end % get.Children
        
        function set.Children(obj,value)
             obj.TabGroup.Children=value;
        end
      
        
        % Currently this is a workaround for Children
        function value=get.Tabs(obj)
            value = obj.TabGroup.Children;
        end % get.Tabs
        
        function set.Tabs(obj,value)
            obj.TabGroup.Children = value;
        end % set.Tabs
        
        function set.Selection(obj,value)
            % Get old tab to pass to onSelectionChanged
            eventData.OldValue = obj.TabGroup.SelectedTab;
            
            if isempty(obj.TabGroup.Children) % Are there any tabs?
                error("uix:InvalidPropertyValue","No tabs have been added to the tab panel.")
            end
            
            numTabs = length( obj.TabGroup.Children );
            assert( (value <= numTabs) && (value > 0),"uix:InvalidPropertyValue", "Selection must be in the range 1 to " + numTabs + " (the number of tabs)." )
            obj.TabGroup.SelectedTab = obj.TabGroup.Children(value);
           
            % Get new tab to pass to onSelectionChanged
            eventData.NewValue = obj.TabGroup.SelectedTab;
            
            % Call the changed tab function.
            obj.onSelectionChanged([],eventData)
        end
        
        function value=get.Selection(obj)
            
            if isempty(obj.TabGroup.Children)
                value = 0;
            else
                value = find( obj.TabGroup.Children == obj.TabGroup.SelectedTab );
            end % if
            
        end % get.Selection
        
        function value=get.Contents(obj)
           value = obj.TabGroup.Children;
        end % get.Contents
        
        function set.Contents(obj,value)
            obj.TabGroup.Children=value;
        end % set.Contents  
        
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
        
        function set.ForegroundColor(obj,value)
            obj.ForegroundColor_ = value;
            idx = obj.TabEnables == "on";
            set(obj.TabGroup.Children(idx),"ForegroundColor",value)
        end
        
        function value=get.ForegroundColor(obj)
           value = obj.ForegroundColor_; 
        end
      
        
        function value = get.TabEnables( obj )
            if isempty(obj.TabEnables_)
                value = repmat({'on'},1,numel(obj.TabGroup.Children));
            else
                value = obj.TabEnables_;
            end
        end % get.TabEnables
        
        function set.TabEnables( obj, value )
                        
            assert(numel(value) == numel(obj.TabGroup.Children),"uix:InvalidParameter","TabEnables must have one entry for each tab.")
            
            obj.TabEnables_ = value;
            
            for k = 1:numel(obj.TabGroup.Children)
                if value(k) == "on"
                    obj.TabGroup.Children(k).ForegroundColor = obj.ForegroundColor;
                else
                    obj.TabGroup.Children(k).ForegroundColor = [0.6,0.6,0.6];
                end
            end
            
        end % set.TabEnables
        
        function value = get.TabLocation( obj )
            
            value = obj.TabLocation_;
            
        end % get.TabLocation
        
        function set.TabLocation( obj, value )
            
            % Check
            assert( ischar( value ) && ...
                any( strcmp( value, {'top','bottom'} ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabLocation'' should be ''top'' or ''bottom''.' )
            
            % Set
            obj.TabLocation_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.TabLocation
        
        
        function value = get.TabTitles( obj )
            
            %value = string(get( obj.TabGroup.Children, {'Title'} ));
            value = get( obj.TabGroup.Children, {'Title'} )';
            
        end % get.TabTitles
        
        function set.TabTitles( obj, value )
            
            % Check the number of titles is correct
            
            assert( numel(value) == numel(obj.TabGroup.Children),...
                'uix:InvalidPropertyValue', ...
                'Property "TabTitles" should be an array of strings, one per tab.' )
            
            
            
            % Set
            for ii = 1:numel( obj.TabGroup.Children )
                obj.TabGroup.Children(ii).Title = value(ii);
            end
            
            % Mark as dirty
            obj.TabHeight = -1;
            obj.Dirty = true;
            
        end % set.TabTitles
        
        function value = get.TabContextMenus( obj )
            
            tabs = obj.Tabs;
            n = numel( tabs );
            value = cell( [n 1] );
            for ii = 1:n
                value{ii} = tabs(ii).UIContextMenu;
            end
            
        end % get.TabContextMenus
        
        function set.TabContextMenus( obj, value )
            
            tabs = obj.Tabs;
            n = numel( tabs );
            for ii = 1:n
                tabs(ii).UIContextMenu = value{ii};
            end
            
        end % set.TabContextMenus
        
        %       % Temporarily a constant property due to webgraphics
        %       function value = get.TabWidth( obj )
        %
        %             value = obj.TabWidth_;
        %
        %         end % get.TabWidth
        
        
        %         % Temporarily a constant property due to webgraphics
        %         function set.TabWidth( obj, value )
        %
        %             % Check
        %             assert( isa( value, 'double' ) && isscalar( value ) && ...
        %                 isreal( value ) && ~isinf( value ) && ...
        %                 ~isnan( value ) && value ~= 0, ...
        %                 'uix:InvalidPropertyValue', ...
        %                 'Property ''TabWidth'' must be a non-zero scalar.' )
        %
        %             % Set
        %             obj.TabWidth_ = value;
        %
        %             % Mark as dirty
        %             obj.Dirty = true;
        %
        %         end % set.TabWidth
        
        %         % Temporarily a constant property due to webgraphics
        %         function value = get.FontAngle( obj )
        %
        %             value = obj.FontAngle_;
        %
        %         end % get.FontAngle
        %
        %         % Temporarily a constant property due to webgraphics
        %         function set.FontAngle( obj, value )
        %
        %             % Check
        %             assert( ischar( value ) && any( strcmp( value, {'normal','italic','oblique'} ) ), ...
        %                 'uix:InvalidPropertyValue', ...
        %                 'Property ''FontAngle'' must be ''normal'', ''italic'' or ''oblique''.' )
        %
        %             % Set
        %             obj.FontAngle_ = value;
        %
        %             % Update existing tabs
        %             tabs = obj.Tabs;
        %             n = numel( tabs );
        %             for ii = 1:n
        %                 tab = tabs(ii);
        %                 tab.FontAngle = value;
        %             end
        %
        %             % Mark as dirty
        %             obj.TabHeight = -1;
        %             obj.Dirty = true;
        %
        %         end % set.FontAngle
        
        %         % Temporarily a constant property due to webgraphics
        %         function value = get.FontName( obj )
        %
        %             value = obj.FontName_;
        %
        %         end % get.FontName
        %
        %         % Temporarily a constant property due to webgraphics
        %         function set.FontName( obj, value )
        %
        %             % Check
        %             assert( ischar( value ) && any( strcmp( value, obj.FontNames ) ), ...
        %                 'uix:InvalidPropertyValue', ...
        %                 'Property ''FontName'' must be a valid font name.' )
        %
        %             % Set
        %             obj.FontName_ = value;
        %
        %             % Update existing tabs
        %             tabs = obj.Tabs;
        %             n = numel( tabs );
        %             for ii = 1:n
        %                 tab = tabs(ii);
        %                 tab.FontName = value;
        %             end
        %
        %             % Mark as dirty
        %             obj.TabHeight = -1;
        %             obj.Dirty = true;
        %
        %         end % set.FontName
        
        %         % Temporarily a constant property due to webgraphics
        %         function value = get.FontSize( obj )
        %
        %             value = obj.FontSize_;
        %
        %         end % get.FontSize
        %
        %         % Temporarily a constant property due to webgraphics
        %         function set.FontSize( obj, value )
        %
        %             % Check
        %             assert( isa( value, 'double' ) && isscalar( value ) && ...
        %                 isreal( value ) && ~isinf( value ) && ...
        %                 ~isnan( value ) && value > 0, ...
        %                 'uix:InvalidPropertyValue', ...
        %                 'Property ''FontSize'' must be a positive scalar.' )
        %
        %             % Set
        %             obj.FontSize_ = value;
        %
        %             % Update existing tabs
        %             tabs = obj.Tabs;
        %             n = numel( tabs );
        %             for ii = 1:n
        %                 tab = tabs(ii);
        %                 tab.FontSize = value;
        %             end
        %
        %             % Mark as dirty
        %             obj.TabHeight = -1;
        %             obj.Dirty = true;
        %
        %         end % set.FontSize
        %
        %         % Temporarily a constant property due to webgraphics
        %         function value = get.FontWeight( obj )
        %
        %             value = obj.FontWeight_;
        %
        %         end % get.FontWeight
        
        %         % Temporarily a constant property due to webgraphics
        %         function set.FontWeight( obj, value )
        %
        %             % Check
        %             assert( ischar( value ) && any( strcmp( value, {'normal','bold'} ) ), ...
        %                 'uix:InvalidPropertyValue', ...
        %                 'Property ''FontWeight'' must be ''normal'' or ''bold''.' )
        %
        %             % Set
        %             obj.FontWeight_ = value;
        %
        %             % Update existing tabs
        %             tabs = obj.Tabs;
        %             n = numel( tabs );
        %             for ii = 1:n
        %                 tab = tabs(ii);
        %                 tab.FontWeight = value;
        %             end
        %
        %             % Mark as dirty
        %             obj.TabHeight = -1;
        %             obj.Dirty = true;
        %
        %         end % set.FontWeight
        %
        %         % Temporarily a constant property due to webgraphics
        %         function value = get.FontUnits( obj )
        %
        %             value = obj.FontUnits_;
        %
        %         end % get.FontUnits
        %
        %         % Temporarily a constant property due to webgraphics
        %         function set.FontUnits( obj, value )
        %
        %             % Check
        %             assert( ischar( value ) && ...
        %                 any( strcmp( value, {'inches','centimeters','points','pixels'} ) ), ...
        %                 'uix:InvalidPropertyValue', ...
        %                 'Property ''FontUnits'' must be ''inches'', ''centimeters'', ''points'' or ''pixels''.' )
        %
        %             % Compute size in new units
        %             oldUnits = obj.FontUnits_;
        %             oldSize = obj.FontSize_;
        %             newUnits = value;
        %             newSize = oldSize * convert( oldUnits ) / convert( newUnits );
        %
        %             % Set size and units
        %             obj.FontSize_ = newSize;
        %             obj.FontUnits_ = newUnits;
        %
        %             % Update existing tabs
        %             tabs = obj.Tabs;
        %             n = numel( tabs );
        %             for ii = 1:n
        %                 tab = tabs(ii);
        %                 tab.FontUnits = newUnits;
        %             end
        %
        %             % Mark as dirty
        %             obj.TabHeight = -1;
        %             obj.Dirty = true;
        %
        %             function factor = convert( units )
        %                 %convert  Compute conversion factor to points
        %                 %
        %                 %  f = convert(u) computes the conversion factor from units
        %                 %  u to points.  For example, convert('inches') since 1
        %                 %  inch equals 72 points.
        %
        %                 persistent SCREEN_PIXELS_PER_INCH
        %                 if isequal( SCREEN_PIXELS_PER_INCH, [] ) % uninitialized
        %                     SCREEN_PIXELS_PER_INCH = get( 0, 'ScreenPixelsPerInch' );
        %                 end
        %
        %                 switch units
        %                     case 'inches'
        %                         factor = 72;
        %                     case 'centimeters'
        %                         factor = 72 / 2.54;
        %                     case 'points'
        %                         factor = 1;
        %                     case 'pixels'
        %                         factor = 72 / SCREEN_PIXELS_PER_INCH;
        %                 end
        %
        %             end % convert
        %
        %       end % set.FontUnits
        
        
    end % accessors
    
    methods( Access = protected )
        
%         function redraw( obj )
%             
%             % Compute positions
%             bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
%                 [0 0 1 1], 'normalized', 'pixels', obj );
%             w = ceil( bounds(1) + bounds(3) ) - floor( bounds(1) ); % width
%             h = ceil( bounds(2) + bounds(4) ) - floor( bounds(2) ); % height
%             p = obj.Padding_; % padding
%             tabs = obj.Tabs;
%             n = numel( tabs ); % number of tabs
%             tH = obj.TabHeight; % tab height
%             if tH == -1 % cache stale, refresh
%                 if n > 0
%                     cTabExtents = get( tabs, {'Extent'} );
%                     tabExtents = vertcat( cTabExtents{:} );
%                     tH = max( tabExtents(:,4) );
%                 end
%                 tH = max( tH, obj.TabMinimumHeight ); % apply minimum
%                 tH = ceil( tH ); % round up
%                 obj.TabHeight = tH; % store
%             end
%             cH = max( [h - 2 * p - tH, 1] ); % contents height
%             switch obj.TabLocation_
%                 case 'top'
%                     cY = 1 + p; % contents y
%                     tY = cY + cH + p; % tab y
%                 case 'bottom'
%                     tY = 1; % tab y
%                     cY = tY + tH + p; % contents y
%             end
%             cX = 1 + p; % contents x
%             cW = max( [w - 2 * p, 1] ); % contents width
%             tW = obj.TabWidth_; % tab width
%             dW = obj.DividerWidth; % tab divider width
%             if tW < 0 && n > 0 % relative
%                 tW = max( ( w - (n+1) * dW ) / n, 1 );
%             end
%             tW = ceil( tW ); % round up
%             for ii = 1:n
%                 tabs(ii).Position = [1 + (ii-1) * tW + ii * dW, tY, tW, tH];
%             end
%             obj.Dividers.Position = [0 tY w+1 tH];
%             contentsPosition = [cX cY cW cH];
%             
%             % Redraw tabs
%             obj.redrawTabs()
%             
%             % Redraw contents
%             selection = obj.Selection_;
%             if selection ~= 0 && strcmp( obj.TabEnables{selection}, 'on' )
%                 uix.setPosition( obj.Contents_(selection), contentsPosition, 'pixels' )
%             end
%             
%         end % redraw
        
%         function addChild( obj, child )
%             %addChild  Add child
%             %
%             %  c.addChild(d) adds the child d to the container c.
%             
%             % Create new tab
%             n = numel( obj.Tabs );
%             tab = matlab.ui.control.UIControl( 'Internal', true, ...
%                 'Parent', obj, 'Style', 'text', 'Enable', 'inactive', ...
%                 'Units', 'pixels', 'FontUnits', obj.FontUnits_, ...
%                 'FontSize', obj.FontSize_, 'FontName', obj.FontName_, ...
%                 'FontAngle', obj.FontAngle_, 'FontWeight', obj.FontWeight_, ...
%                 'ForegroundColor', obj.ForegroundColor_, ...
%                 'String', sprintf( 'Page %d', n + 1 ) );
%             tabListener = event.listener( tab, 'ButtonDown', @obj.onTabClicked );
%             obj.Tabs(n+1,:) = tab;
%             obj.TabListeners(n+1,:) = tabListener;
%             
%             % Mark as dirty
%             obj.TabHeight = -1;
%             
%             % Check for bug
%             if verLessThan( 'MATLAB', '8.5' ) && strcmp( child.Visible, 'off' )
%                 obj.G1218142 = true;
%             end
%             
%             % Select new content
%             oldSelection = obj.Selection_;
%             if numel( obj.Contents_ ) == 0
%                 newSelection = 1;
%                 obj.Selection_ = newSelection;
%             else
%                 newSelection = oldSelection;
%             end
%             
%             % Call superclass method
%             addChild@uix.mixin.Container( obj, child )
%             
%             % Show selected child
%             obj.showSelection()
%             
%             % Notify selection change
%             if oldSelection ~= newSelection
%                 obj.notify( 'SelectionChanged', ...
%                     uix.SelectionData( oldSelection, newSelection ) )
%             end
%             
%         end % addChild
        
%         function removeChild( obj, child )
%             %removeChild  Remove child
%             %
%             %  c.removeChild(d) removes the child d from the container c.
%             
%             % Find index of removed child
%             contents = obj.Contents_;
%             index = find( contents == child );
%             
%             % Remove tab
%             delete( obj.Tabs(index) )
%             obj.Tabs(index,:) = [];
%             obj.TabListeners(index,:) = [];
%             
%             % Call superclass method
%             removeChild@uix.mixin.Panel( obj, child )
%             
%         end % removeChild
        
%         function reorder( obj, indices )
%             %reorder  Reorder contents
%             %
%             %  c.reorder(i) reorders the container contents using indices
%             %  i, c.Contents = c.Contents(i).
%             
%             % Reorder
%             obj.Tabs = obj.Tabs(indices,:);
%             obj.TabListeners = obj.TabListeners(indices,:);
%             
%             % Call superclass method
%             reorder@uix.mixin.Panel( obj, indices )
%             
%         end % reorder
        
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
            %             %showSelection  Show selected child, hide the others
            %             %
            %             %  c.showSelection() shows the selected child of the container
            %             %  c, and hides the others.
            %
            %             % Call superclass method
            %             showSelection@uix.mixin.Panel( obj )
            %
            %             % If not enabled, hide selected contents too
            %             selection = obj.Selection_;
            %             if selection ~= 0 && strcmp( obj.TabEnables{selection}, 'off' )
            %                 child = obj.Contents_(selection);
            %                 child.Visible = 'off';
            %                 if isa( child, 'matlab.graphics.axis.Axes' )
            %                     child.ContentsVisible = 'off';
            %                 end
            %                 % As a remedy for g1100294, move off-screen too
            %                 margin = 1000;
            %                 if isa( child, 'matlab.graphics.axis.Axes' ) ...
            %                         && strcmp(child.ActivePositionProperty, 'outerposition' )
            %                     child.OuterPosition(1) = -child.OuterPosition(3)-margin;
            %                 else
            %                     child.Position(1) = -child.Position(3)-margin;
            %                 end
            %             end
            %
            
            selection = min(obj.Selection,1);
            
            obj.TabGroup.Selection = obj.TabGroup.Children(selection);
            
        end % showSelection
        
    end % template methods
    
    methods( Access = private )
        
        % This is the function that uicontrol and uitab map to
        function tb=addTab(varargin)
            
            if mod(numel(varargin),2) == 1
                % Add the parent name at the start for consistency.
                varargin = ['parent',varargin];
                                
            end   

                % Find the parent argument
                parentIdx = find(lower(string(varargin(1:2:end))) == "parent");
                % Extract the tabgroup from the tabpanel
                obj = varargin{2*parentIdx};
                varargin{2*parentIdx}=obj.TabGroup;

            
            
            % Create a tab panel
            tb=matlab.ui.container.Tab;
            
            % This checks against incorrect or unsupported properties in
            % uitab and ignores them, warns against them being ignored.
            % names = varargin(1:2:end);
            uiTabProps = properties(tb);
            idx = zeros(size(varargin),"logical");

            for k = 1:numel(idx)/2
                try
                    % Validate potential typos
                    varargin{2*k-1} = validatestring(varargin{2*k-1},uiTabProps);
                    % If successfully validated, change the contains to
                    % true;
                    idx(2*k-1)=1;
                    idx(2*k)=1;
                catch
                    try
                        oldArgument = validatestring(varargin{2*k-1},obj.OldUiControlArguments);
                        % If unsuccessful validation return the warning that it
                        % is being ignored.
                        warning("The property '" +oldArgument + "' is no longer supported and will be ignored.")
                    catch
                        error("uix:InvalidArgument","'" + varargin{2*k-1} + "' is not a valid argument name.")
                    end
                end
            end
            
            varargin=varargin(idx); % Filter the varargin to have the non rejected properties.
            
            set(tb,varargin{:});
        end % addTab
        
        function contentsIntoTabs(obj,value)
            for k = 1:numel(value)
                obj.TabGroup.Children(k).Children=value{k};
            end
        end
        
        
%         function redrawTabs( obj )
%             %redrawTabs  Redraw tabs
%             %
%             %  p.redrawTabs() redraws the tabs.
%             
%             % Get relevant properties
%             selection = obj.Selection_;
%             tabs = obj.Tabs;
%             t = numel( tabs );
%             dividers = obj.Dividers;
%             
%             % Handle no tabs as a special case
%             if t == 0
%                 dividers.Visible = 'off'; % hide
%                 return
%             end
%             
%             % Repaint tabs
%             backgroundColor = obj.BackgroundColor;
%             for ii = 1:t
%                 tab = tabs(ii);
%                 if ii == selection
%                     tab.BackgroundColor = backgroundColor;
%                 else
%                     tab.BackgroundColor = obj.Tint * backgroundColor;
%                 end
%             end
%             
%             % Repaint dividers
%             d = t + 1;
%             dividerNames = repmat( 'F', [d 2] ); % initialize
%             dividerNames(1,1) = 'E'; % end
%             dividerNames(end,2) = 'E'; % end
%             if selection ~= 0
%                 dividerNames(selection,2) = 'T'; % selected
%                 dividerNames(selection+1,1) = 'T'; % selected
%             end
%             tH = obj.TabHeight;
%             assert( tH >= obj.TabMinimumHeight, 'uix:InvalidState', ...
%                 'Cannot redraw tabs with invalid TabHeight.' )
%             tW = obj.Tabs(1).Position(3);
%             dW = obj.DividerWidth;
%             allCData = zeros( [tH 0 3] ); % initialize
%             map = [obj.ShadowColor; obj.BackgroundColor; ...
%                 obj.Tint * obj.BackgroundColor; obj.HighlightColor;...
%                 obj.ParentBackgroundColor];
%             for ii = 1:d
%                 % Select mask
%                 iMask = obj.DividerMask.( dividerNames(ii,:) );
%                 % Resize
%                 iData = repmat( iMask(5,:), [tH 1] );
%                 iData(1:4,:) = iMask(1:4,:);
%                 iData(end-3:end,:) = iMask(end-3:end,:);
%                 % Convert to RGB
%                 cData = ind2rgb( iData+1, map );
%                 % Orient
%                 switch obj.TabLocation_
%                     case 'bottom'
%                         cData = flipud( cData );
%                 end
%                 % Insert
%                 allCData(1:tH,(ii-1)*(dW+tW)+(1:dW),:) = cData; % center
%                 if ii > 1 % extend left under transparent uicontrol edge
%                     allCData(1:tH,(ii-1)*(dW+tW),:) = cData(:,1,:);
%                 end
%                 if ii < d % extend right under transparent uicontrol edge
%                     allCData(1:tH,(ii-1)*(dW+tW)+dW+1,:) = cData(:,end,:);
%                 end
%             end
%             dividers.CData = allCData; % paint
%             dividers.BackgroundColor = obj.ParentBackgroundColor;
%             dividers.Visible = 'on'; % show
%             
%         end % redrawTabs
        
    end % helper methods
    
    methods( Access = private )
        
        function onTabClicked( obj, source, ~ )
            
            % Update selection
            oldSelection = obj.Selection_;
            newSelection = find( source == obj.Tabs );
            if oldSelection == newSelection, return, end % abort set
            obj.Selection_ = newSelection;
            
            % Show selected child
            obj.showSelection()
            
            % Mark as dirty
            obj.Dirty = true;
            
            % Notify selection change
            obj.notify( 'SelectionChanged', ...
                uix.SelectionData( oldSelection, newSelection ) )
            
        end % onTabClicked
        
        function onBackgroundColorChanged( obj, ~, ~ )
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onBackgroundColorChanged
        
        function onSelectionChanged( obj, ~ , eventData )
                        
            % If the tab is enabled deny the swap
            if obj.TabEnables{obj.TabGroup.Children==eventData.NewValue}=="off"
                obj.Selection = find(eventData.OldValue==obj.TabGroup.Children);
            else
                % If the change is allowed, send out notification of change
                notify(obj,"SelectionChanged")
            end
        end % onSelectionChanged
        
        function onParentChanged( obj, ~, ~ )
            
            % Update ParentBackgroundColor and ParentBackgroundColor
            if isprop( obj.Parent, 'BackgroundColor' )
                prop = 'BackgroundColor';
            elseif isprop( obj.Parent, 'Color' )
                prop = 'Color';
            else
                prop = [];
            end
            
            if ~isempty( prop )
                obj.ParentBackgroundColorListener = event.proplistener( obj.Parent, ...
                    findprop( obj.Parent, prop ), 'PostSet', ...
                    @( src, evt ) obj.updateParentBackgroundColor( prop ) );
            else
                obj.ParentBackgroundColorListener = [];
            end
            
            obj.updateParentBackgroundColor( prop );
            
        end % onParentChanged
        
        function updateParentBackgroundColor( obj, prop )
            
            if isempty( prop )
                obj.ParentBackgroundColor = obj.BackgroundColor;
            else
                obj.ParentBackgroundColor = obj.Parent.(prop);
            end
            
            % Mark as dirty
            obj.Dirty = true;
            
        end
        
    end % event handlers
    
    methods( Access = private, Static )
        
        function mask = getDividerMask()
            %getDividerMask  Get divider image data
            %
            %  m = uix.TabPanel.getDividerMask() returns the image masks
            %  for tab panel dividers.  Mask entries are 0 (shadow), 1
            %  (background), 2 (tint) and 3 (highlight).
            
            mask.EF = indexColor( uix.loadIcon( 'tab_NoEdge_NotSelected.png' ) );
            mask.ET = indexColor( uix.loadIcon( 'tab_NoEdge_Selected.png' ) );
            mask.FE = indexColor( uix.loadIcon( 'tab_NotSelected_NoEdge.png' ) );
            mask.FF = indexColor( uix.loadIcon( 'tab_NotSelected_NotSelected.png' ) );
            mask.FT = indexColor( uix.loadIcon( 'tab_NotSelected_Selected.png' ) );
            mask.TE = indexColor( uix.loadIcon( 'tab_Selected_NoEdge.png' ) );
            mask.TF = indexColor( uix.loadIcon( 'tab_Selected_NotSelected.png' ) );
            
            function mask = indexColor( rgbMap )
                %indexColor  Returns a map of index given an RGB map
                %
                %  mask = indexColor( rgbMap ) returns a mask of color
                %  index based on the supplied rgbMap.
                %  black  : 0
                %  red    : 1
                %  yellow : 2
                %  white  : 3
                %  blue   : 4
                mask = nan( size( rgbMap, 1 ),size( rgbMap, 2 ) );
                % Black
                colorIndex = isColor( rgbMap, [0 0 0] );
                mask(colorIndex) = 0;
                % Red
                colorIndex = isColor( rgbMap, [1 0 0] );
                mask(colorIndex) = 1;
                % Yellow
                colorIndex = isColor( rgbMap, [1 1 0] );
                mask(colorIndex) = 2;
                % White
                colorIndex = isColor( rgbMap, [1 1 1] );
                mask(colorIndex) = 3;
                % Blue
                colorIndex = isColor( rgbMap, [0 0 1] );
                mask(colorIndex) = 4;
                % Nested
                function boolMap = isColor( map, color )
                    %isColor  Return a map of boolean where map is equal to color
                    boolMap = all( bsxfun( @eq, map, permute( color, [1 3 2] ) ), 3 );
                end
            end
            
        end % getDividerMask
        
    end % static helper methods
    
end % classdef