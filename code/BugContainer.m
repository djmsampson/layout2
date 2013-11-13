classdef BugContainer < matlab.ui.container.internal.UIContainer
    
    properties( Access = private )
        ChildObserver
    end
    
    methods
        
        function obj = BugContainer()
            
            % Call superclass constructor
            obj@matlab.ui.container.internal.UIContainer()
            
            % Create and store observer
            childObserver = BugChildObserver( obj );
            obj.ChildObserver = childObserver;
            
        end % constructor
        
    end
    
end % classdef