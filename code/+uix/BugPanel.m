classdef BugPanel < matlab.ui.container.Panel
    
    properties % ( Access = private )
        TitleBox
        TitleText
        ParentListener
        TitleListener
        SizeListener
    end
    
    methods
        
        function obj = BugPanel( varargin )
            
            % Call superclass constructor
            obj@matlab.ui.container.Panel()
            
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
    
    methods( Access = protected )
        
        function redraw( obj )
            
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