classdef ( Hidden, Sealed ) ChildObserver < handle
    %uix.ChildObserver  Child observer
    %
    %  co = uix.ChildObserver(o) creates a child observer for the graphics
    %  object o.  A child observer raises events when objects are added to
    %  and removed from the property Children of o.
    %
    %  See also: uix.AncestryObserver, uix.Node
    
    %  Copyright 2009-2013 The MathWorks, Inc.
    %  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $
    
    properties( Hidden )
        Root % root node
    end
    
    events( NotifyAccess = private )
        ChildAdded % child added
        ChildRemoved % child removed
    end
    
    methods
        
        function obj = ChildObserver( oRoot )
            %uix.ChildObserver  Child observer
            %
            %  co = uix.ChildObserver(o) creates a child observer for the
            %  graphics object o.  A child observer raises events when
            %  objects are added to and removed from the property Children
            %  of o.
            
            % Check
            assert( ishghandle( oRoot ) && ...
                isequal( size( oRoot ), [1 1] ), 'uix.InvalidArgument', ...
                'Object must be a graphics object.' )
            
            % Create root node
            nRoot = uix.Node( oRoot );
            childAddedListener = event.listener( ...
                uix.EventSource.getInstance( oRoot ), ... % TODO
                'ObjectChildAdded', ...
                @(~,e)obj.addChild(nRoot,e.Child) );
            childAddedListener.Recursive = true;
            nRoot.addListener( childAddedListener );
            childRemovedListener = event.listener( ...
                uix.EventSource.getInstance( oRoot ), ... % TODO
                'ObjectChildRemoved', ...
                @(~,e)obj.removeChild(nRoot,e.Child) );
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
    
    methods( Access = private )
        
        function addChild( obj, nParent, oChild )
            %addChild  Add child object to parent node
            %
            %  co.addChild(np,oc) adds the child object oc to the parent
            %  node np, either as part of construction of the child
            %  observer co, or in response to an ObjectChildAdded event on
            %  an object of interest to co.  This may lead to ChildAdded
            %  events being raised on co.
            
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
                nChild.addListener( event.listener( ...
                    uix.EventSource.getInstance( oChild ), ... % TODO
                    'ObjectChildAdded', ...
                    @(~,e)obj.addChild(nChild,e.Child) ) )
                nChild.addListener( event.listener( ...
                    uix.EventSource.getInstance( oChild ), ... % TODO
                    'ObjectChildRemoved', ...
                    @(~,e)obj.removeChild(nChild,e.Child) ) )
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
            %removeChild  Remove child object from parent node
            %
            %  co.removeChild(np,oc) removes the child object oc from the
            %  parent node np, in response to an ObjectChildRemoved event
            %  on an object of interest to co.  This may lead to
            %  ChildRemoved events being raised on co.
            
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