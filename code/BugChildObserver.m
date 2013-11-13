classdef( Hidden ) BugChildObserver < handle
    
    properties( Hidden )
        Root % root node
    end
    
    events( NotifyAccess = protected )
        ChildAdded % child added
        ChildRemoved % child removed
    end
    
    methods
        
        function obj = BugChildObserver( oRoot )
            
            % Check
            assert( ishghandle( oRoot ) && ...
                isequal( size( oRoot ), [1 1] ), 'uix.InvalidArgument', ...
                'Object must be a graphics object.' )
            
            % Create root node
            nRoot = uix.Node( oRoot );
            childAddedListener = event.listener( oRoot, 'ObjectChildAdded', @(~,e)obj.addChild(nRoot,e.Child) );
            childAddedListener.Recursive = true;
            nRoot.addListener( childAddedListener );
            childRemovedListener = event.listener( oRoot, 'ObjectChildRemoved', @(~,e)removeChild(nRoot,e.Child) );
            childRemovedListener.Recursive = true;
            nRoot.addListener( childRemovedListener );
            
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
                % Add property listener
                nChild.addListener( event.proplistener( oChild, ...
                    findprop( oChild, 'Internal' ), 'PostSet', ...
                    @(~,~)obj.postSetInternal(nChild) ) )
            else
                % Add child listeners
                nChild.addListener( event.listener( oChild, 'ObjectChildAdded', @(~,e)obj.addChild(nChild,e.Child) ) );
                nChild.addListener( event.listener( oChild, 'ObjectChildRemoved', @(~,e)obj.removeChild(nChild,e.Child) ) );
            end
            
            % Raise ChildAdded event
            if ishghandle( oChild ) && oChild.Internal == false
                notify( obj, 'ChildAdded', uix.ChildEvent( oChild ) )
            end
            
            % Add grandchildren
            if ~ishghandle( oChild )
                oGrandchildren = hgGetTrueChildren( oChild );
                for ii = 1:numel( oGrandchildren )
                    obj.addChild( nChild, oGrandchildren(ii) )
                end
            end
            
        end % addChild
        
        function removeChild( obj, nParent, oChild )
            
            % Get child node
            nChildren = nParent.Children;
            tf = oChild == [nChildren.Object];
            nChild = nChildren(tf);
            
            % Raise ChildRemoved event(s)
            notifyChildRemoved( nChild )
            
            % Delete child node
            delete( nChild )
            
            function notifyChildRemoved( nc )
                
                % Process child nodes
                ngc = nc.Children;
                for ii = 1:numel( ngc )
                    notifyChildRemoved( ngc(ii) )
                end
                
                % Process this node
                oc = nc.Object;
                if ishghandle( oc ) && oc.Internal == false
                    notify( obj, 'ChildRemoved', uix.ChildEvent( oc ) )
                end
                
            end % notifyChildRemoved
            
        end % removeChild
        
    end % public methods
    
    methods( Access = protected )
        
        function postSetInternal( obj, n )
            %postSetInternal  Perform property PostSet tasks
            %
            %  co.postSetInternal(n) raises a ChildAdded or ChildRemoved
            %  event on the child observer co in response to a change of
            %  the value of the property Internal of the object referenced
            %  by the node n.
            
            % Raise event if required
            object = n.Object;
            if object.Internal == false
                notify( obj, 'ChildAdded', uix.ChildEvent( object ) )
            else
                notify( obj, 'ChildRemoved', uix.ChildEvent( object ) )
            end
            
        end % postSetInternal
        
    end % event handlers
    
end % classdef