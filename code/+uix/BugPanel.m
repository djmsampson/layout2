classdef BugPanel < uix.Panel
    
    properties( Access = public, Dependent, AbortSet )
        TitleBarColor
        TitleBarPadding
    end
    
    properties % ( Access = private )
        TitleBox
        TitleText
        TitleBarColor_ = get( 0, 'DefaultUipanelBackgroundColor' )
        TitleBarPadding_ = 2
        ParentListener
        TitleListener
        SizeListener
    end
    
    methods
        
        function obj = BugPanel( varargin )
            
            % Call superclass constructor
            obj@uix.Panel()
            
            titleBox = matlab.ui.container.Panel( ...
                'Parent', obj.Parent, ...
                'Units', 'pixels', ...
                'BackgroundColor', [0.94 0.94 0.94], ...
                'BorderType', obj.BorderType, ...
                'BorderWidth', obj.BorderWidth, ...
                'HighlightColor', obj.HighlightColor, ...
                'ShadowColor', obj.ShadowColor, ...
                'Title', '', ...
                'Visible', 'off' );
            titleText = matlab.ui.container.Panel( ...
                'Parent', obj.Parent, ...
                'Units', 'pixels', ...
                'BackgroundColor', obj.BackgroundColor, ...
                'BorderType', 'none', ...
                'FontAngle', obj.FontAngle, ...
                'FontName', obj.FontName, ...
                'FontSize', obj.FontSize, ...
                'FontUnits', obj.FontUnits, ...
                'FontWeight', obj.FontWeight, ...
                'Title', obj.Title, ...
                'TitlePosition', obj.TitlePosition, ...
                'Visible', 'off' );
            
            % Store properties
            obj.TitleBox = titleBox;
            obj.TitleText = titleText;
            
            % Create listeners
            parentListener = event.proplistener( obj, ...
                findprop( obj, 'Parent' ), 'PostSet', ...
                @obj.onParentChange );
            titleListener = event.proplistener( obj, ...
                findprop( obj, 'Title' ), 'PostSet', ...
                @obj.onTitleChange );
            
            % Store properties
            obj.ParentListener = parentListener;
            obj.TitleListener = titleListener;
            
            % Set properties
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
        function delete( obj )
            
            % Dispose of title box
            titleText = obj.TitleBox;
            if ishghandle( titleText ) && ~strcmp( titleText, 'off' )
                delete( titleText )
            end
            
            % Dispose of title text
            titleText = obj.TitleText;
            if ishghandle( titleText ) && ~strcmp( titleText, 'off' )
                delete( titleText )
            end
            
        end % destructor
        
    end % structors
    
    methods
        
        function value = get.TitleBarColor( obj )
            
            value = obj.TitleBox.BackgroundColor;
            
        end % get.TitleBarColor
        
        function set.TitleBarColor( obj, value )
            
            obj.TitleBox.BackgroundColor = value;
            
        end % set.TitleBarColor
        
        function value = get.TitleBarPadding( obj )
            
            value = obj.TitleBarPadding_;
            
        end % get.TitleBarPadding
        
        function set.TitleBarPadding( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''TitleBarPadding'' must be a non-negative scalar.' )
            
            % Set
            obj.TitleBarPadding_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.TitleBarPadding
        
    end % accessors
    
    methods( Access = protected )
        
        function redraw( obj )
            
            % Compute positions
            figure = ancestor( obj, 'figure' );
            outerBounds = hgconvertunits( figure, ...
                obj.Position, obj.Units, 'pixels', obj.Parent );
            innerBounds = hgconvertunits( figure, ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            titlePosition = obj.TitlePosition;
            borderType = obj.BorderType;
            borderWidth = obj.BorderWidth;
            switch borderType
                case 'none'
                    borderFactor = 0;
                case 'line'
                    borderFactor = 1;
                otherwise
                    borderFactor = 2;
            end
            switch titlePosition
                case {'lefttop','centertop','righttop'}
                    margin = [1 1] * borderWidth * borderFactor;
                otherwise
                    margin = [0 outerBounds(4) - innerBounds(4)] + ...
                        borderWidth * borderFactor * [1 -1];
            end
            
            % Set positions of decorations
            titleTextHeight = outerBounds(4) - innerBounds(4) - ...
                borderWidth * borderFactor;
            titlePadding = obj.TitleBarPadding_;
            titleBoxHeight = titleTextHeight + 2 * titlePadding + ...
                2 * borderWidth * borderFactor;
            switch titlePosition
                case {'lefttop','centertop','righttop'}
                    titleBoxPosition = [outerBounds(1), ...
                        outerBounds(2) + outerBounds(4) - titleBoxHeight, ...
                        outerBounds(3), titleBoxHeight];
                otherwise
                    titleBoxPosition = [outerBounds(1:3), titleBoxHeight];
            end
            titleTextPosition = titleBoxPosition + ...
                titlePadding * [0 1 0 -2] + ...
                borderWidth * borderFactor * [1 1 -2 -2];
            
            % Set properties
            titleBox = obj.TitleBox;
            if all( titleBoxPosition(3:4) > 0 ) && ~isempty( obj.Title )
                titleBox.Position = titleBoxPosition;
                titleBox.Visible = 'on';
            else
                titleBox.Visible = 'off';
            end
            titleText = obj.TitleText;
            if all( titleTextPosition(3:4) > 0 ) && ~isempty( obj.Title )
                titleText.Position = titleTextPosition;
                titleText.Visible = 'on';
            else
                titleText.Visible = 'off';
            end
            
        end % redraw
        
    end % template methods
    
    methods
        
        function onParentChange( obj, ~, ~ )
            
            parent = obj.Parent;
            obj.TitleBox.Parent = parent;
            obj.TitleText.Parent = parent;
            
        end % onParentChange
        
        function onTitleChange( obj, ~, ~ )
            
            title = obj.Title;
            if isempty( title )
                obj.TitleBox.Visible = 'off';
                obj.TitleText.Visible = 'off';
            else
                obj.TitleBox.Visible = 'on';
                obj.TitleText.Visible = 'on';
            end
            obj.TitleText.Title = deblank( title ); % TODO
            
        end % onTitleChange
        
    end % event handlers
    
end % classdef