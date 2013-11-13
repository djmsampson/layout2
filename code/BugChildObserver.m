classdef( Hidden ) BugChildObserver < handle
    
    properties( Hidden )
        Root % root node
    end
    
    events( NotifyAccess = protected )
        ChildAdded % child added
    end
    
    methods
        
        function obj = BugChildObserver( oRoot )
            
            % Create root node
            nRoot = uix.Node( oRoot );
            childAddedListener = event.listener( oRoot, 'ObjectChildAdded', @(~,e)obj.addChild(nRoot,e.Child) );
            childAddedListener.Recursive = true;
            nRoot.addListener( childAddedListener );
            
            % Add children
            oChildren = hgGetTrueChildren( oRoot );
            for ii = 1:numel( oChildren )
                obj.addChild( nRoot, oChildren(ii) )
            end
            
            % Store properties
            obj.Root = nRoot;
            
        end % constructor
        
    end % structors
    
    methods
        
        function addChild( obj, nParent, oChild )
            
            % Create child node
            nChild = uix.Node( oChild );
            nParent.addChild( nChild )
            if ishghandle( oChild )
                notify( obj, 'ChildAdded', uix.ChildEvent( oChild ) )
            else
                % Add child listeners
                nChild.addListener( event.listener( oChild, 'ObjectChildAdded', @(~,e)obj.addChild(nChild,e.Child) ) );
            end
            
            % Add grandchildren
            if ~ishghandle( oChild )
                oGrandchildren = hgGetTrueChildren( oChild );
                for ii = 1:numel( oGrandchildren )
                    obj.addChild( nChild, oGrandchildren(ii) )
                end
            end
            
        end % addChild
        
    end % public methods
    
end % classdef