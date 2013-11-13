classdef BugContainer < matlab.ui.container.internal.UIContainer
    
    properties( Dependent, GetAccess = public, SetAccess = private )
        Contents
    end
    
    properties( Access = protected )
        Contents_ = gobjects( [0 1] ) % backing for Contents
    end
    
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
        
        function value = get.Contents( obj )
            
            value = obj.Contents_;
            
        end % get.Contents
        
        function onChildAdded( obj, ~, eventData )
            
            obj.Contents_(end+1,1) = eventData.Child;
            
        end % onChildAdded
        
    end
    
end % classdef