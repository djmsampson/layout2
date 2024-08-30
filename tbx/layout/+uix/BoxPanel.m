classdef BoxPanel < uix.Panel
    %uix.BoxPanel  Box panel
    %
    %  p = uix.BoxPanel(p1,v1,p2,v2,...) constructs a box panel and sets
    %  parameter p1 to value v1, etc.
    %
    %  A box panel is a decorated container with a title box, border, and
    %  buttons to dock and undock, minimize, get help, and close.  A box
    %  panel shows one of its contents and hides the others.
    %
    %  See also: uix.Panel, uipanel, uix.CardPanel

    %  Copyright 2009-2024 The MathWorks, Inc.

    properties( Access = public, Dependent, AbortSet )
        TitleColor % title background color [RGB]
        Minimized % minimized [true|false]
        MinimizeFcn % minimize callback
        Docked % docked [true|false]
        DockFcn % dock callback
        HelpFcn % help callback
        CloseRequestFcn % close request callback
    end

    properties( Dependent, SetAccess = private )
        TitleHeight % title panel height [pixels]
    end

    properties( Access = private )
        TitleBox % title bar box
        TitleText % title text label
        Title_ = '' % cache of title
        TitleAccess = 'public' % 'private' when getting or setting Title, 'public' otherwise
        TitleHeight_ = -1 % cache of title text height (-1 denotes stale cache)
        MinimizeButton % title button
        DockButton % title button
        HelpButton % title button
        CloseButton % title button
        Docked_ = true % backing for Docked
        Minimized_ = false % backing for Minimized
        FigureSelectionListener = event.proplistener.empty( [0 0] ) % listener
    end

    properties( Constant, Access = private )
        NullTitle = char.empty( [2 0] ) % an obscure empty string, the actual panel Title
        BlankTitle = ' ' % a non-empty blank string, the empty uicontrol String
    end

    properties( Access = public, AbortSet )
        MaximizeTooltip = 'Expand this panel' % tooltip string
        MinimizeTooltip = 'Collapse this panel'% tooltip string
        UndockTooltip = 'Undock this panel' % tooltip string
        DockTooltip = 'Dock this panel' % tooltip string
        HelpTooltip = 'Get help on this panel' % tooltip string
        CloseTooltip = 'Close this panel' % tooltip string
    end

    properties( Access = public, Dependent, AbortSet, Hidden )
        MaximizeTooltipString % transitioned to MaximizeTooltip
        MinimizeTooltipString % transitioned to MinimizeTooltip
        UndockTooltipString % transitioned to UndockTooltip
        DockTooltipString % transitioned to DockTooltip
        HelpTooltipString % transitioned to HelpTooltip
        CloseTooltipString % transitioned to CloseTooltip
    end

    methods

        function obj = BoxPanel( varargin )
            %uix.BoxPanel  Box panel constructor
            %
            %  p = uix.BoxPanel() constructs a box panel.
            %
            %  p = uix.BoxPanel(p1,v1,p2,v2,...) sets parameter p1 to value
            %  v1, etc.

            % Define default colors
            foregroundColor = [1 1 1];
            backgroundColor = [0.05 0.25 0.5];

            % Set default colors
            obj.ForegroundColor = foregroundColor;

            % Create panels and decorations
            titleBox = uix.HBox( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'BackgroundColor', backgroundColor );
            titleText = uicontrol( 'Parent', titleBox, ...
                'Style', 'text', 'String', obj.BlankTitle, ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor );

            % Create buttons
            minimizeButton = uicontrol( 'Parent', [], ...
                'Style', 'text', 'HorizontalAlignment', 'center', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'Enable', 'on', ...
                'FontWeight', 'bold' );
            dockButton = uicontrol( 'Parent', [], ...
                'Style', 'text', 'HorizontalAlignment', 'center', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'Enable', 'on', ...
                'FontWeight', 'bold' );
            helpButton = uicontrol( 'Parent', [], ...
                'Style', 'text', 'HorizontalAlignment', 'center', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'Enable', 'on', ...
                'FontWeight', 'bold', 'String', '?', ...
                'TooltipString', obj.HelpTooltip );
            closeButton = uicontrol( 'Parent', [], ...
                'Style', 'text', 'HorizontalAlignment', 'center', ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'Enable', 'on', ...
                'FontWeight', 'bold', 'String', char( 215 ), ...
                'TooltipString', obj.CloseTooltip );

            % Store properties
            obj.Title = obj.NullTitle;
            obj.TitleBox = titleBox;
            obj.TitleText = titleText;
            obj.MinimizeButton = minimizeButton;
            obj.DockButton = dockButton;
            obj.HelpButton = helpButton;
            obj.CloseButton = closeButton;

            % Create listeners
            addlistener( obj, 'BorderWidth', 'PostSet', ...
                @obj.onBorderWidthChanged );
            addlistener( obj, 'BorderType', 'PostSet', ...
                @obj.onBorderTypeChanged );
            addlistener( obj, 'FontAngle', 'PostSet', ...
                @obj.onFontAngleChanged );
            addlistener( obj, 'FontName', 'PostSet', ...
                @obj.onFontNameChanged );
            addlistener( obj, 'FontSize', 'PostSet', ...
                @obj.onFontSizeChanged );
            addlistener( obj, 'FontUnits', 'PostSet', ...
                @obj.onFontUnitsChanged );
            addlistener( obj, 'FontWeight', 'PostSet', ...
                @obj.onFontWeightChanged );
            addlistener( obj, 'ForegroundColor', 'PostSet', ...
                @obj.onForegroundColorChanged );
            addlistener( obj, 'Title', 'PreGet', ...
                @obj.onTitleReturning );
            addlistener( obj, 'Title', 'PostGet', ...
                @obj.onTitleReturned );
            addlistener( obj, 'Title', 'PostSet', ...
                @obj.onTitleChanged );

            % Draw buttons
            obj.redrawButtons()

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

        function value = get.TitleColor( obj )

            value = obj.TitleBox.BackgroundColor;

        end % get.TitleColor

        function set.TitleColor( obj, value )

            % Set
            obj.TitleBox.BackgroundColor = value;
            obj.TitleText.BackgroundColor = value;
            obj.MinimizeButton.BackgroundColor = value;
            obj.DockButton.BackgroundColor = value;
            obj.HelpButton.BackgroundColor = value;
            obj.CloseButton.BackgroundColor = value;

        end % set.TitleColor

        function value = get.CloseRequestFcn( obj )

            value = obj.CloseButton.ButtonDownFcn;

        end % get.CloseRequestFcn

        function set.CloseRequestFcn( obj, value )

            % Set
            obj.CloseButton.ButtonDownFcn = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.CloseRequestFcn

        function value = get.DockFcn( obj )

            value = obj.DockButton.ButtonDownFcn;

        end % get.DockFcn

        function set.DockFcn( obj, value )

            % Set
            obj.DockButton.ButtonDownFcn = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.DockFcn

        function value = get.HelpFcn( obj )

            value = obj.HelpButton.ButtonDownFcn;

        end % get.HelpFcn

        function set.HelpFcn( obj, value )

            % Set
            obj.HelpButton.ButtonDownFcn = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.HelpFcn

        function value = get.MinimizeFcn( obj )

            value = obj.MinimizeButton.ButtonDownFcn;

        end % get.MinimizeFcn

        function set.MinimizeFcn( obj, value )

            % Set
            obj.MinimizeButton.ButtonDownFcn = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.MinimizeFcn

        function value = get.Docked( obj )

            value = obj.Docked_;

        end % get.Docked

        function set.Docked( obj, value )

            % Check
            assert( islogical( value ) && isscalar( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Docked'' must be true or false.' )

            % Set
            obj.Docked_ = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.Docked

        function value = get.Minimized( obj )

            value = obj.Minimized_;

        end % get.Minimized

        function set.Minimized( obj, value )

            % Check
            assert( islogical( value ) && isscalar( value ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Minimized'' must be true or false.' )

            % Set
            obj.Minimized_ = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.Minimized

        function value = get.TitleHeight( obj )

            value = obj.TitleBox.Position(4);

        end % get.TitleHeight

        function set.MaximizeTooltip( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'MaximizeTooltip' );

            % Set
            obj.MaximizeTooltip = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.MaximizeTooltip

        function set.MinimizeTooltip( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'MinimizeTooltip' );

            % Set
            obj.MinimizeTooltip = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.MinimizeTooltip

        function set.DockTooltip( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'DockTooltip' );

            % Set
            obj.DockTooltip = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.DockTooltip

        function set.UndockTooltip( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'UndockTooltip' );

            % Set
            obj.UndockTooltip = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.UndockTooltip

        function set.CloseTooltip( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'CloseTooltip' );

            % Set
            obj.CloseTooltip = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.CloseTooltip

        function set.HelpTooltip( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'HelpTooltip' );

            % Set
            obj.HelpTooltip = value;

            % Mark as dirty
            obj.redrawButtons()

        end % set.HelpTooltip

        function value = get.MaximizeTooltipString( obj )

            value = obj.MaximizeTooltip;

        end % get.MaximizeTooltipString

        function set.MaximizeTooltipString( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'MaximizeTooltipString' );

            % Set
            obj.MaximizeTooltip = value;

        end % set.MaximizeTooltipString

        function value = get.MinimizeTooltipString( obj )

            value = obj.MinimizeTooltip;

        end % get.MinimizeTooltipString

        function set.MinimizeTooltipString( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'MinimizeTooltipString' );

            % Set
            obj.MinimizeTooltip = value;

        end % set.MinimizeTooltipString

        function value = get.DockTooltipString( obj )

            value = obj.DockTooltip;

        end % get.DockTooltip

        function set.DockTooltipString( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'DockTooltipString' );

            % Set
            obj.DockTooltip = value;

        end % set.DockTooltipString

        function value = get.UndockTooltipString( obj )

            value = obj.UndockTooltip;

        end % get.UndockTooltipString

        function set.UndockTooltipString( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'UndockTooltipString' );

            % Set
            obj.UndockTooltip = value;

        end % set.UndockTooltipString

        function value = get.CloseTooltipString( obj )

            value = obj.CloseTooltip;

        end % get.CloseTooltipString

        function set.CloseTooltipString( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'CloseTooltipString' );

            % Set
            obj.CloseTooltip = value;

        end % set.CloseTooltipString

        function value = get.HelpTooltipString( obj )

            value = obj.HelpTooltip;

        end % get.HelpTooltipString

        function set.HelpTooltipString( obj, value )

            % Check
            value = validateScalarStringOrCharacterArray( value, ...
                'HelpTooltipString' );

            % Set
            obj.HelpTooltip = value;

        end % set.HelpTooltipString

    end % accessors

    methods( Access = private )

        function onBorderWidthChanged( obj, ~, ~ )

            % Mark as dirty
            obj.Dirty = true;

        end % onBorderWidthChanged

        function onBorderTypeChanged( obj, ~, ~ )

            % Mark as dirty
            obj.Dirty = true;

        end % onBorderTypeChanged

        function onFontAngleChanged( obj, ~, ~ )

            obj.TitleText.FontAngle = obj.FontAngle;

        end % onFontAngleChanged

        function onFontNameChanged( obj, ~, ~ )

            % Set
            obj.TitleText.FontName = obj.FontName;

            % Mark as dirty
            obj.TitleHeight_ = -1;
            obj.Dirty = true;

        end % onFontNameChanged

        function onFontSizeChanged( obj, ~, ~ )

            % Set
            fontSize = obj.FontSize;
            obj.TitleText.FontSize = fontSize;
            obj.HelpButton.FontSize = fontSize;
            obj.CloseButton.FontSize = fontSize;
            obj.DockButton.FontSize = fontSize;
            obj.MinimizeButton.FontSize = fontSize;

            % Mark as dirty
            obj.TitleHeight_ = -1;
            obj.Dirty = true;

        end % onFontSizeChanged

        function onFontUnitsChanged( obj, ~, ~ )

            fontUnits = obj.FontUnits;
            obj.TitleText.FontUnits = fontUnits;
            obj.HelpButton.FontUnits = fontUnits;
            obj.CloseButton.FontUnits = fontUnits;
            obj.DockButton.FontUnits = fontUnits;
            obj.MinimizeButton.FontUnits = fontUnits;

        end % onFontUnitsChanged

        function onFontWeightChanged( obj, ~, ~ )

            obj.TitleText.FontWeight = obj.FontWeight;

        end % onFontWeightChanged

        function onForegroundColorChanged( obj, ~, ~ )

            foregroundColor = obj.ForegroundColor;
            obj.TitleText.ForegroundColor = foregroundColor;
            obj.MinimizeButton.ForegroundColor = foregroundColor;
            obj.DockButton.ForegroundColor = foregroundColor;
            obj.HelpButton.ForegroundColor = foregroundColor;
            obj.CloseButton.ForegroundColor = foregroundColor;

        end % onForegroundColorChanged

        function onTitleReturning( obj, ~, ~ )

            if strcmp( obj.TitleAccess, 'public' ) && isjsdrawing() == false
                obj.TitleAccess = 'private'; % start
                obj.Title = obj.Title_;
            end

        end % onTitleReturning

        function onTitleReturned( obj, ~, ~ )

            if isjsdrawing() == false
                obj.Title = obj.NullTitle; % unset Title
            end
            obj.TitleAccess = 'public'; % finish

        end % onTitleReturned

        function onTitleChanged( obj, ~, ~ )

            if strcmp( obj.TitleAccess, 'public' ) && isjsdrawing() == false

                % Set
                obj.TitleAccess = 'private'; % start
                title = obj.Title;
                obj.Title_ = title;
                if isempty( title )
                    obj.TitleText.String = obj.BlankTitle;
                else
                    obj.TitleText.String = [' ' title]; % set String to title
                end
                obj.Title = obj.NullTitle; % unset Title
                obj.TitleAccess = 'public'; % finish

                % Mark as dirty
                obj.TitleHeight_ = -1;
                obj.Dirty = true;

            end

        end % onTitleChanged

        function onFigureSelectionChanged( obj, source, eventData )

            % Identify callback
            switch eventData.AffectedObject.SelectionType
                case 'normal' % single left click
                    if isempty( eventData.AffectedObject.CurrentObject ) % none
                        callback = ''; % do nothing
                    else
                        switch eventData.AffectedObject.CurrentObject
                            case obj.CloseButton
                                callback = obj.CloseRequestFcn;
                            case obj.DockButton
                                callback = obj.DockFcn;
                            case obj.HelpButton
                                callback = obj.HelpFcn;
                            case obj.MinimizeButton
                                callback = obj.MinimizeFcn;
                            otherwise % other object
                                callback = ''; % do nothing
                        end
                    end
                otherwise % other interaction
                    callback = ''; % do nothing
            end

            % Call callback
            if ischar( callback ) && isequal( callback, '' )
                % do nothing
            elseif ischar( callback )
                feval( callback, source, eventData ) %#ok<FVAL>
            elseif isa( callback, 'function_handle' )
                callback( source, eventData ) %#ok<NOPRT>
            elseif iscell( callback )
                feval( callback{1}, source, eventData, callback{2:end} )
            end

        end % onFigureSelectionChanged

    end % property event handlers

    methods( Access = protected )

        function redraw( obj )
            %redraw  Redraw
            %
            %  p.redraw() redraws the panel.
            %
            %  See also: redrawButtons

            % Compute positions
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            tX = 1;
            tW = max( bounds(3), 1 );
            tH = obj.TitleHeight_; % title height
            if tH == -1 % cache stale, refresh
                tH = extent( obj.TitleText, 4 ) + 2 * obj.TitleBox.Padding;
                obj.TitleHeight_ = tH; % store
            end
            tY = 1 + bounds(4) - tH;
            p = obj.Padding_;
            cX = 1 + p;
            cW = max( bounds(3) - 2 * p, 1 );
            cH = max( bounds(4) - tH - 2 * p, 1 );
            cY = tY - p - cH;
            contentsPosition = [cX cY cW cH];

            % Redraw contents
            contents = obj.Contents_;
            for ii = 1:numel( contents )
                uix.setPosition( contents(ii), contentsPosition, 'pixels' )
            end
            obj.TitleBox.Position = [tX tY tW tH];

        end % redraw

        function reparent( obj, oldFigure, newFigure )
            %reparent  Reparent container
            %
            %  c.reparent(a,b) reparents the container c from the figure a
            %  to the figure b.

            % Update listeners
            if isempty( newFigure )
                figureSelectionListener = event.listener.empty( [0 0] );
            else
                figureSelectionListener = event.proplistener( ...
                    newFigure, findprop( newFigure, 'CurrentObject' ), ...
                    'PostSet', @obj.onFigureSelectionChanged );
            end
            obj.FigureSelectionListener = figureSelectionListener;

            % Call superclass method
            reparent@uix.Panel( obj, oldFigure, newFigure )

        end % reparent

    end % template methods

    methods( Access = private )

        function redrawButtons( obj )
            %redrawButtons  Redraw buttons
            %
            %  p.redrawButtons() redraws the titlebar buttons.
            %
            %  Buttons use unicode arrow symbols:
            %  https://en.wikipedia.org/wiki/Arrow_%28symbol%29#Arrows_in_Unicode

            % Retrieve button box and buttons
            box = obj.TitleBox;
            titleText = obj.TitleText;
            minimizeButton = obj.MinimizeButton;
            dockButton = obj.DockButton;
            helpButton = obj.HelpButton;
            closeButton = obj.CloseButton;

            % Detach all buttons
            titleText.Parent = [];
            minimizeButton.Parent = [];
            dockButton.Parent = [];
            helpButton.Parent = [];
            closeButton.Parent = [];

            % Attach active buttons
            titleText.Parent = box;
            bW = obj.TitleHeight_ * 2/3; % button width
            minimize = ~isempty( obj.MinimizeFcn );
            if minimize
                minimizeButton.Parent = box;
                box.Widths(end) = bW;
            end
            dock = ~isempty( obj.DockFcn );
            if dock
                dockButton.Parent = box;
                box.Widths(end) = bW;
            end
            help = ~isempty( obj.HelpFcn );
            if help
                helpButton.Parent = box;
                helpButton.TooltipString = obj.HelpTooltip;
                box.Widths(end) = bW;
            end
            close = ~isempty( obj.CloseRequestFcn );
            if close
                closeButton.Parent = box;
                closeButton.TooltipString = obj.CloseTooltip;
                box.Widths(end) = bW;
            end

            % Update icons
            if obj.Minimized_
                minimizeButton.String = char( 9662 );
                minimizeButton.TooltipString = obj.MaximizeTooltip;
            else
                minimizeButton.String = char( 9652 );
                minimizeButton.TooltipString = obj.MinimizeTooltip;
            end
            if obj.Docked_
                dockButton.String = char( 8599 );
                dockButton.TooltipString = obj.UndockTooltip;
            else
                dockButton.String = char( 8600 );
                dockButton.TooltipString = obj.DockTooltip;
            end

        end % redrawButtons

    end % helper methods

end % classdef

function tf = isjsdrawing()
%isjsdrawing  Detect JavaScript drawing, which accesses properties

s = dbstack();
tf = false;
for ii = 1:numel( s )
    n = strsplit( s(ii).name, '.' );
    if strcmp( n{1}, 'WebComponentController' ), tf = true; break; end
end

end % isjsdrawing

function e = extent( c, i )
%extent  Extent of uicontrol
%
%   e = extent(c) returns the extent of the uicontrol c.
%
%   e = extent(c,i) returns the ith element(s) of the extent.
%
%   For Java graphics, this function simply returns the Extent property.
%   For JavaScript graphics, the Extent property is unreliable for large
%   font sizes, and this function is more accurate.

% Get nominal extent
e = c.Extent;

% Correct height for web graphics
f = ancestor( c, 'figure' );
if ~isempty( f ) && isprop( f, 'JavaFrame_I' ) && isempty( f.JavaFrame_I )
    df = figure( 'Visible', 'off' ); % dummy *Java* figure
    dc = uicontrol( 'Parent', df, 'Style', 'text', ...
        'FontSize', c.FontSize, 'String', c.String ); % dummy text
    e(4) = dc.Extent(4); % use Java height
    delete( df ) % clean up
end

% Return
if nargin > 1
    e = e(i);
end

end % extent

function value = validateScalarStringOrCharacterArray( value, propertyName )
%VALIDATESCALARSTRINGORCHARACTERARRAY Verify that the given value is a
%scalar string or a character array.

if isa( value, 'string' ) && isscalar( value ) && ismissing( value )
    value = '';
end % if

try
    value = char( value );
    assert( ismatrix( value ) )
catch
    exc = MException( 'uix:InvalidPropertyValue', ['Property ''', ...
        propertyName, ''' must be a scalar string or a ', ...
        'character array.'] );
    exc.throwAsCaller()
end % try/catch

end % validateScalarStringOrCharacterArray