classdef BoxPanel < uix.Panel
    
    properties( Access = public, Dependent, AbortSet )
        TitlePadding
    end
    
    properties
        TitleBox
        TitleText
        TitlePadding_ = 2
        ParentListener
        TitleListener
        TitlePositionListener
        BorderTypeListener
        BorderWidthListener
        FontAngleListener
        FontNameListener
        FontSizeListener
        FontUnitsListener
        FontWeightListener
        BackgroundColorListener
        ForegroundColorListener
        HighlightColorListener
        ShadowColorListener
        LocationListener
        SizeListener
    end
    
    methods
        
        function obj = BoxPanel( varargin )
            
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
            titlePositionListener = event.proplistener( obj, ...
                findprop( obj, 'TitlePosition' ), 'PostSet', ...
                @obj.onTitlePositionChange );
            borderTypeListener = event.proplistener( obj, ...
                findprop( obj, 'BorderType' ), 'PostSet', ...
                @obj.onBorderTypeChange );
            borderWidthListener = event.proplistener( obj, ...
                findprop( obj, 'BorderWidth' ), 'PostSet', ...
                @obj.onBorderWidthChange );
            fontAngleListener = event.proplistener( obj, ...
                findprop( obj, 'FontAngle' ), 'PostSet', ...
                @obj.onFontAngleChange );
            fontNameListener = event.proplistener( obj, ...
                findprop( obj, 'FontName' ), 'PostSet', ...
                @obj.onFontNameChange );
            fontSizeListener = event.proplistener( obj, ...
                findprop( obj, 'FontSize' ), 'PostSet', ...
                @obj.onFontSizeChange );
            fontUnitsListener = event.proplistener( obj, ...
                findprop( obj, 'FontUnits' ), 'PostSet', ...
                @obj.onFontUnitsChange );
            fontWeightListener = event.proplistener( obj, ...
                findprop( obj, 'FontWeight' ), 'PostSet', ...
                @obj.onFontWeightChange );
            backgroundColorListener = event.proplistener( obj, ...
                findprop( obj, 'BackgroundColor' ), 'PostSet', ...
                @obj.onBackgroundColorChange );
            foregroundColorListener = event.proplistener( obj, ...
                findprop( obj, 'ForegroundColor' ), 'PostSet', ...
                @obj.onForegroundColorChange );
            highlightColorListener = event.proplistener( obj, ...
                findprop( obj, 'HighlightColor' ), 'PostSet', ...
                @obj.onHighlightColorChange );
            shadowColorListener = event.proplistener( obj, ...
                findprop( obj, 'ShadowColor' ), 'PostSet', ...
                @obj.onShadowColorChange );
            locationListener = event.listener( obj, ...
                'LocationChange', @obj.onLocationChange );
            sizeListener = event.listener( obj, ...
                'SizeChange', @obj.onSizeChange );
            
            % Store properties
            obj.ParentListener = parentListener;
            obj.TitleListener = titleListener;
            obj.TitlePositionListener = titlePositionListener;
            obj.BorderTypeListener = borderTypeListener;
            obj.BorderWidthListener = borderWidthListener;
            obj.FontAngleListener = fontAngleListener;
            obj.FontNameListener = fontNameListener;
            obj.FontSizeListener = fontSizeListener;
            obj.FontUnitsListener = fontUnitsListener;
            obj.FontWeightListener = fontWeightListener;
            obj.BackgroundColorListener = backgroundColorListener;
            obj.ForegroundColorListener = foregroundColorListener;
            obj.HighlightColorListener = highlightColorListener;
            obj.ShadowColorListener = shadowColorListener;
            obj.LocationListener = locationListener;
            obj.SizeListener  = sizeListener;
            
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
        
        function value = get.TitlePadding( obj )
            
            value = obj.TitlePadding_;
            
        end % get.TitlePadding
        
        function set.TitlePadding( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''TitlePadding'' must be a non-negative scalar.' )
            
            % Set
            obj.TitlePadding_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.TitlePadding
        
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
            titleBoxHeight = titleTextHeight + 2 * obj.TitlePadding_ + ...
                2 * borderWidth * borderFactor;
            titleBoxPosition = [outerBounds(1), ...
                outerBounds(2) + outerBounds(4) - titleBoxHeight, ...
                outerBounds(3), titleBoxHeight];
            titleTextPosition = titleBoxPosition + ...
                borderWidth * borderFactor * [1 1 -2 -2];
            
            if any( titleBoxPosition(3:4) <= 0 ) || any( titleTextPosition(3:4) <= 0 )
                disp Small!
            end
            
            obj.TitleBox.Position = max( titleBoxPosition, [-Inf -Inf 1 1] );
            obj.TitleText.Position = max( titleTextPosition, [-Inf -Inf 1 1] );
            
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
        
        function onTitlePositionChange( obj, ~, ~ ) % TODO
            
            obj.TitleText.TitlePosition = obj.TitlePosition;
            
        end % onTitlePositionChange
        
        function onBorderTypeChange( obj, ~, ~ )
            
            obj.TitleBox.BorderType = obj.BorderType;
            
        end % onBorderTypeChange
        
        function onBorderWidthChange( obj, ~, ~ )
            
            obj.TitleBox.BorderWidth = obj.BorderWidth;
            
        end % onBorderWidthChange
        
        function onFontAngleChange( obj, ~, ~ )
            
            obj.TitleText.FontAngle = obj.FontAngle;
            
        end % onFontAngleChange
        
        function onFontNameChange( obj, ~, ~ )
            
            obj.TitleText.FontName = obj.FontName;
            
        end % onFontNameChange
        
        function onFontSizeChange( obj, ~, ~ )
            
            obj.TitleText.FontSize = obj.FontSize;
            
        end % onFontSizeChange
        
        function onFontWeightChange( obj, ~, ~ )
            
            obj.TitleText.FontWeight = obj.FontWeight;
            
        end % onFontWeightChange
        
        function onFontUnitsChange( obj, ~, ~ )
            
            obj.TitleText.FontUnits = obj.FontUnits;
            
        end % onFontUnitsChange
        
        function onBackgroundColorChange( obj, ~, ~ )
            
            color = obj.BackgroundColor;
            obj.TitleBox.BackgroundColor = color;
            obj.TitleText.BackgroundColor = color;
            
        end % onBackgroundColorChange
        
        function onForegroundColorChange( obj, ~, ~ )
            
            obj.TitleText.ForegroundColor = obj.ForegroundColor;
            
        end % onForegroundColorChange
        
        function onHighlightColorChange( obj, ~, ~ )
            
            obj.TitleBox.HighlightColor = obj.HighlightColor;
            
        end % onHighlightColorChange
        
        function onShadowColorChange( obj, ~, ~ )
            
            obj.TitleBox.ShadowColor = obj.ShadowColor;
            
        end % onShadowColorChange
        
        function onLocationChange( obj, ~, ~ )
            
            % Set as dirty
            obj.Dirty = true;
            
        end % onLocationChange
        
        function onSizeChange( obj, ~, ~ )
            
            % Set as dirty
            obj.Dirty = true;
            
        end % onSizeChange
        
    end % event handlers
    
end % classdef