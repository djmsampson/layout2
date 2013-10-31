classdef BugPanel < matlab.ui.container.Panel
    
    properties % ( Access = private )
        TitleBox
        ParentListener
        TitleListener
        SizeListener
    end
    
    methods
        
        function obj = BugPanel( varargin )
            
            % Call superclass constructor
            obj@matlab.ui.container.Panel( varargin{:} )
            
            titleBox = matlab.ui.container.Panel( ...
                'Parent', obj.Parent, ...
                'Units', 'pixels', ...
                'Title', '', ...
                'Visible', 'off' );
            % Store properties
            obj.TitleBox = titleBox;
            
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
            
        end % constructor
        
    end % structors
    
    methods
        
        function onParentChange( obj, ~, ~ )
            
            parent = obj.Parent;
            obj.TitleBox.Parent = parent;
            
        end % onParentChange
        
        function onTitleChange( obj, ~, ~ )
            
            title = obj.Title;
            if isempty( title )
                obj.TitleBox.Visible = 'off';
            else
                obj.TitleBox.Visible = 'on';
            end
            
        end % onTitleChange
        
    end % event handlers
    
end % classdef