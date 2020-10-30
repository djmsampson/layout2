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
        SelectionChangedFcn='' % selection change callback
        DeleteFcn=''
        Tag % Arbitrary user settable tag to add to layout.
        BeingDeleted
    end
    
    properties ( Dependent )
        Selection
        TabEnables
        ForegroundColor
        Children % Points to the tabgroup children
        Contents % Tabgroup children in their left to right order - this is redundant with uitab but kept for compatability.
    end % properties ( Dependent )
    
    properties( Access = public, Dependent, SetObservable)
        Parent
    end % properties ( Access = public, Dependent, SetObservable)
    
    properties( Access = public, Dependent, AbortSet = true)
        TabTitles % tab titles
        TabContextMenus % tab context menus
        Visible
    end % properties( Access = public, Dependent, AbortSet = true)
    
    properties( Access = private )
        TabEnables_ % Backing for dependent property TabEnables
        ForegroundColor_ = get( 0, 'DefaultUicontrolForegroundColor' ) % backing for ForegroundColor
    end % ( Access = private )
    
    % Listeners - potentially redundant
    properties( Access = private )
        BackgroundColorListener % listener *unused*
        SelectionChangedListener % listener *unused*
        ParentListener % listener *unused*
        ParentBackgroundColorListener % listener
    end
    
    properties % ( Access = private ) % Make private when done
        TabGroup
    end
    
    % Legacy properties to check against for backwards compatability
    properties ( Constant , Access = private )
        OldPanelProperties = {'BackgroundColor','BeingDeleted','Contents','DeleteFcn','FontAngle','FontName','FontSize','FontUnits','FontWeight','ForegroundColor','HighlightColor','ShadowColor','Padding','Parent','Position','Selection','SelectionChangedFcn','TabContextMenus','TabEnables','TabTitles','TabWidth','Tag','Type','Units','Visible'};
        OldUiControlArguments = {'HorizontalAlignment','ListboxTop','Max','Min','SliderStep','String','Style','Value','Position','BackgroundColor','CData','Callback','Children','Tooltip','ForegroundColor','Enable','Extent','Visible','Parent','HandleVisibility','ButtonDownFcn','ContextMenu','BusyAction','BeingDeleted','Interruptible','CreateFcn','DeleteFcn','Type','Tag','UserData','KeyPressFcn','KeyReleaseFcn','FontUnits','FontSize','FontName','FontAngle','FontWeight','Units','InnerPosition','OuterPosition'};
        RemovedProperties = {'Padding','TabWidth','FontAngle','FontName','FontSize','FontWeight','FontUnits','HighlightColor','ShadowColor','TabLocation','Type'}
    end % (Constant,Hidden) Backwards compatability checks
    
    properties % Temporarily removed functionality due to uitab
        TabWidth =  0 % Used to default to -1 for changing size, as size is now auto done set it to 0 % tab width
        FontAngle = get( 0, 'DefaultUicontrolFontAngle' ) % font angle
        FontName = get( 0, 'DefaultUicontrolFontName' ) % font name
        FontSize = get( 0, 'DefaultUicontrolFontSize' ) % font size
        FontWeight = get( 0, 'DefaultUicontrolFontWeight' ) % font weight
        FontUnits = get( 0, 'DefaultUicontrolFontUnits' ) % font weight
        HighlightColor = [0,0,0] % border highlight color [RGB]
        ShadowColor = [0.7,0.7,0.7] % border shadow color [RGB]
        TabLocation = 'top'% tab location [top|bottom]
        Padding = 0
        BackgroundColor = get( 0, 'DefaultUicontrolForegroundColor' ) % default parent background color
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
            
            
            % This block validates the arguments and finds incorrect inputs
            % It also warns about legacy properties
            
            % Get the TabPanel properties, remove the ones that are there
            % to cover legacy arguments
            currentPropsIdx = cellfun(@(x) ~any(strcmpi(x,obj.RemovedProperties)),properties(obj));
            currentProps = properties(obj);
            currentProps = currentProps(currentPropsIdx)';
            
            
            % Create the tab group, the only consitent property is the selection changed callback
            tabGroup = matlab.ui.container.TabGroup( ...
                'SelectionChangedFcn', @obj.onSelectionChanged );
            
            % Store
            obj.TabGroup = tabGroup;
            
            % Check the version dependent properties of the tab group
            % Add any properties that will get passed to uitabgroup
            % Note if any of the removed properties get added back in
            % This will automatically disable their warnings.
            currentProps=unique([currentProps,properties(obj.TabGroup)']);
                      
            % Get the input arguments to compare.
            inputProps = varargin(1:2:end);
            
            % String validation to check against current properties
            idx = false(size(inputProps));
            for k =1:numel(inputProps)
                try
                    inputProps{k} = validatestring(inputProps{k},currentProps);
                    idx(k)=1;
                catch
                end
            end
            
            % Those which couldnt be validated are validated against
            % legcacy properties, resulting in an error if that validation
            % fails.
            notCurrentProps = inputProps(~idx);
            
            for k = 1:numel(notCurrentProps)
                try
                    oldProp = validatestring(notCurrentProps{k},unique([obj.OldPanelProperties,obj.RemovedProperties]));
                    warning off backtrace
                    warning(['The property ''' , oldProp , ''' is no longer supported and will be ignored.']);
                    warning on backtrace
                catch ME
                    delete( obj )
                    ME.throwAsCaller;
                    %error('uix:InvalidArgument',ME.message)
                end
            end
            

            
            
            % These blocks do not perform argument validation
            % Instead they use validatestrings to determine if they should
            % be assigned to TabPanel or uitabgroup
            
            % Common arguments are preferentially sent to the TabPanel class
            % so its set methods transfer legacy inputs to the uitabgroup
            idx = false(size(varargin));
            tabPanelProps = properties(obj);
            for k = 1:numel(idx)/2
                try
                    % Validate potential typos
                    varargin{2*k-1} = validatestring(varargin{2*k-1},tabPanelProps);
                    % If successfully validated, logically index them in
                    idx(2*k-1)=1;
                    idx(2*k)=1;
                catch
                    % Nothing required here because we pre-validated
                    % all the argument names.
                    % Any incorrect values will be messaged at the setting
                    % stage.
                end
            end
            
            uitabgroupVarargin = varargin(~idx); % Save these, some may apply to TabPabel and not uitabgroup
            varargin=varargin(idx); % Filter the varargin to have the non rejected properties.
            
            % The remaining properties are checked to see if they are
            % uitabgroup properties or legacy ones - again any false
            % arguments have already been mentioned.
            uiTabProps = properties(tabGroup);
            idx = false(size(uitabgroupVarargin));
            
            for k = 1:numel(idx)/2
                try
                    % Validate potential typos
                    uitabgroupVarargin{2*k-1} = validatestring(uitabgroupVarargin{2*k-1},uiTabProps);
                    % If successfully validated, logically index them in
                    idx(2*k-1)=1;
                    idx(2*k)=1;
                catch
                    % Nothing required here because we pre-validated
                    % all the argument names.
                    % Any incorrect values will be messaged at the setting
                    % stage.
                end
            end
            
            % Filter out the legacy properties.
            uitabgroupVarargin = uitabgroupVarargin(idx);
            
            % Set properties to the tabgroup
            try
                if numel(varargin) > 0 % Make sure we havnet already dealt with all of the arguments
                    set( obj, varargin{:} );
                end % if
                if numel(uitabgroupVarargin) > 0 % Make sure we havnet already dealt with all of the arguments
                    set( obj.TabGroup, uitabgroupVarargin{:} );
                end % if
            catch e
                delete( obj )
                e.throwAsCaller()
            end
            
        end % constructor
        
        function delete(obj)
            delete(obj.TabGroup) % Delete the relevant graphics object
            delete(obj) % Now delete the class
        end
        
        % Backwards compatability by overloading uicontrol
        function tab=uicontrol(varargin)
            try
                tab=addTab(varargin{:});
            catch ME
                ME.throwAsCaller;
                % Alternative way to force a uix error id
                %error('uix:InvalidPropertyValue',ME.message);
            end
        end % uicontrol
        
        % Overload uitab so that it works to be intuative for new users.
        function tab=uitab(varargin)
            try
                tab=addTab(varargin{:});
            catch ME
                ME.throwAsCaller;
                % Alternative way to force a uix error id
                % error('uix:InvalidPropertyValue',ME.message);
            end
        end % uitab
        
    end % structors
    
    methods % accessors
        
        function value = get.Parent(obj)
            value = obj.TabGroup.Parent;
        end % get.Parent
        
        
        function set.Parent(obj,value)
            obj.TabGroup.Parent = value;
        end % set.Parent
        
        
        function value = get.Children( obj )
            value = obj.TabGroup.Children;
        end % get.Children
        
        
        function set.Children(obj,value)
            obj.TabGroup.Children=value;
        end % set.Children
        
        
        function set.Selection(obj,value)
            
            % Even if there are no tabs, selection should be an integer and zero or above
            % isinteger checks class, so instead check using mod division.
            assert((value >= 0) & (mod(value,1)<eps) ,'uix:InvalidPropertyValue','''Selection'' should be a positive integer.')
            
            % Are there any tabs?
            assert(~isempty(obj.TabGroup.Children),'uix:InvalidPropertyValue','No tabs have been added to the tab panel.')
            
            % Get old tab to pass to onSelectionChanged
            eventData.OldValue = obj.TabGroup.SelectedTab;
            numTabs = numel( obj.Children );
            % Make sure you arent selecting a non existing tab.
            assert( (value <= numTabs) && (value > 0),'uix:InvalidPropertyValue', ['''Selection'' must be in the range 1 to ' , num2str(numTabs) , ' (the number of tabs).'] )
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
        
        function set.BeingDeleted(obj,value)
            assert(isrow(value) & ischar(value),'uix:InvalidPropertyValue','BeingDeleted should be a character array with value ''on'' or ''off''.')
            assert(any(strcmpi(value,{'on','off'})),'uix:InvalidPropertyValue','BeingDeleted should have a value of ''on'' or ''off''.')
            obj.BeingDeleted = value;
        end
        
        function set.Tag(obj,value)
            % Should be a row of characters
            % Is it realistic to expect and convert column input??
            assert(isrow(value) & ischar(value),'uix:InvalidPropertyValue','The property Tag should be a character array.')
            obj.Tag = value;
        end
        
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
        
        
        % Should this be something we can have on a per tab basis?
        function set.ForegroundColor(obj,value)
            
            % Check
            assert( isnumeric( value ) && isequal( size( value ), [1 3] ) && ...
                all( isreal( value ) ) && all( value >= 0 ) && all( value <= 1 ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''ForegroundColor'' must be an RGB triple.' )
            
            obj.ForegroundColor_ = value;
            idx = strcmpi(obj.TabEnables,'on');
            set(obj.TabGroup.Children(idx),'ForegroundColor',value)
        end
        
        
        function value=get.ForegroundColor(obj)
            value = obj.ForegroundColor_;
        end % get.ForegroundColor
        
        
        function value = get.TabEnables( obj )
            if isempty(obj.TabEnables_)
                value = repmat({'on'},1,numel(obj.TabGroup.Children));
            else
                value = obj.TabEnables_;
            end
        end % get.TabEnables
        
        
        function set.TabEnables( obj, value )
            
            
            % For those who can't tell a column from a row...
            if isrow( value )
                value = transpose( value );
            end
            
            % Check
            assert( iscellstr( value ) && ...
                isequal( size( value ), size( obj.TabGroup.Children ) ) && ...
                all( strcmp( value, 'on' ) | strcmp( value, 'off' ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabEnables'' should be a cell array of strings ''on'' or ''off'', one per tab.' )
            
            % Validate size
            assert(numel(value) == numel(obj.TabGroup.Children),'uix:InvalidParameter','TabEnables must have one entry for each tab.')
            % Set the backer, used to implement uitab disabling
            obj.TabEnables_ = value;
            % Update text color depending on tab enabled state.
            for k = 1:numel(obj.TabGroup.Children)
                if strcmpi(value(k),'on')
                    obj.TabGroup.Children(k).ForegroundColor = obj.ForegroundColor;
                else
                    obj.TabGroup.Children(k).ForegroundColor = [0.6,0.6,0.6];
                end
            end
        end % set.TabEnables
        
        
        function value = get.TabLocation( obj )
            value = obj.TabLocation_;
        end % get.TabLocation
        
        
        function value = get.TabTitles( obj )
            value = get( obj.TabGroup.Children, {'Title'} )';
        end % get.TabTitles
        
        
        function set.TabTitles( obj, value )
            
            
            % For those who can't tell a column from a row...
            if isrow( value )
                value = transpose( value );
            end
            
            % Check
            assert( iscellstr( value ) && ...
                isequal( size( value ), size( obj.TabGroup.Children ) ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''TabTitles'' should be a cell array of strings, one per tab.' )
            
           % Set
           for k = 1:numel( obj.TabGroup.Children )
                obj.TabGroup.Children(k).Title = value{k};
            end
        end % set.TabTitles
        
        
        function value = get.TabContextMenus( obj )
            tabs = obj.Children;
            value = cell( [n 1] );
            for ii = 1:numel( tabs )
                value{ii} = tabs(ii).UIContextMenu;
            end
        end % get.TabContextMenus
        
        
        function set.TabContextMenus( obj, value )
            tabs = obj.Children;
            for ii = 1:numel( tabs )
                tabs(ii).UIContextMenu = value{ii};
            end
        end % set.TabContextMenus
        
        function value=get.Visible(obj)
            value = obj.TabGroup.Visible;
        end
        
        function set.Visible(obj,value)
            obj.TabGroup.Visible=value;
        end
        
    end % accessors
    
    % Set end of class for null accessor functions for removed properties
    
    methods( Access = private ) % addTab
        
        % This is the function that uicontrol and uitab map to
        function tb=addTab(varargin)
            
            if mod(numel(varargin),2) == 1
                % Add the parent name at the start for consistency.
                varargin = ['parent',varargin];
            end
            
            % Find the parent argument
            parentIdx = find(strcmpi(varargin(1:2:end),'parent'));
            % Point it towards the tab group
            obj = varargin{2*parentIdx};
            varargin{2*parentIdx}=obj.TabGroup;
            
            % Create a tab panel
            tb=matlab.ui.container.Tab;
            
            % This checks against incorrect or unsupported properties in
            % uitab and ignores them, warns against them being ignored.
            uiTabProps = properties(tb);
            
            idx = false(size(varargin));
            
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
                        warning off backtrace
                        warning(['The property ''',oldArgument , ''' is no longer supported and will be ignored.'])
                        warning on backtrace
                    catch ME
                        error('uix:InvalidArgument',ME.message)
                    end
                end
            end
            
            varargin=varargin(idx); % Filter the varargin to have the non rejected properties.
            
            set(tb,varargin{:});
            
            % If no color specified for the tab itself, go with the panel
            % default.
            if ~any(strcmpi(varargin(1:2:end),'ForegroundColor'))
               tb.ForegroundColor = obj.ForegroundColor; 
            end
            
        end % addTab
        
    end % helper methods
    
    methods( Access = private )
        
        function onSelectionChanged( obj, ~ , eventData )
            % If the tab is enabled deny the swap
            if strcmpi(obj.TabEnables{obj.TabGroup.Children==eventData.NewValue},'off')
                obj.Selection = find(eventData.OldValue==obj.TabGroup.Children);
            else
                % If the change is allowed, send out notification of change
                notify(obj,'SelectionChanged')
                obj.SelectionChangedFcn;
            end
        end % onSelectionChanged
        
    end % event handlers
    
    % To prevent errors in old properties
    % The set and get functions still work
    % But the set functions no longer do anything.
    methods % Null setters
        % Print warnings?
        function set.TabWidth(~,~)
        end
        
        function set.FontAngle(~,~)
        end
        
        function set.FontName(~,~)
        end
        
        function set.FontSize(~,~)
        end
        
        function set.FontWeight(~,~)
        end
        
        function set.FontUnits(~,~)
        end
        
        function set.BackgroundColor(~,~)
        end
        
        function set.HighlightColor(~,~)
        end
        
        function set.ShadowColor(~,~)
        end
        
        function set.TabLocation(~,~)
        end
        
        function set.Padding(~,~)
        end
        
    end % Null set functions
    
end % classdef