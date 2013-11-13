classdef BugContainer < matlab.ui.container.internal.UIContainer
    
    properties( Access = private )
        ChildObserver
        ChildAddedListener
    end
    
    methods
        
        function obj = BugContainer()
            
            % Call superclass constructor
            obj@matlab.ui.container.internal.UIContainer()
            
            % Create observers and listeners
            childObserver = BugChildObserver( obj );
            childAddedListener = event.listener( ...
                childObserver, 'ChildAdded', @obj.onChildAdded );
            
            % Store observers and listeners
            obj.ChildObserver = childObserver;
            obj.ChildAddedListener = childAddedListener;
            
        end % constructor
        
        function onChildAdded( obj, ~, eventData )
            
        end % onChildAdded
        
    end
    
end % classdef