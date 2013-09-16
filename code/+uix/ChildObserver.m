classdef( Hidden ) ChildObserver < handle
    %uix.ChildObserver  Child observer
    %
    %  co = uix.ChildObserver(o) creates a child observer for the graphics
    %  object o.  A child observer raises events ChildAdded and
    %  ChildRemoved when objects are respectively added to and removed from
    %  the property Children of o.
    
    %  Copyright 2009-2013 The MathWorks, Inc.
    %  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $
    
    properties( Hidden )
        Root % root node
    end
    
    events( NotifyAccess = protected )
        ChildAdded % child added
        ChildRemoved % child removed
    end
    
    methods
        
        function obj = ChildObserver( oRoot )
            %uix.ChildObserver  Child observer
            %
            %  co = uix.ChildObserver(o) creates a child observer for the
            %  graphics object o.  A child observer raises events
            %  ChildAdded and ChildRemoved when objects are respectively
            %  added to and removed from the property Children of o.
            
            % Check
            assert( ishghandle( oRoot ) && ...
                isequal( size( oRoot ), [1 1] ), 'uix.InvalidArgument', ...
                'Object must be a graphics object.' )
            
            % Create root node
            nRoot = uix.Node( oRoot );
            nRoot.addListener( event.listener( ...
                uix.EventSource.getInstance( oRoot ), ... % TODO
                'ObjectChildAdded', ...
                @(~,e)obj.addChild(nRoot,e.Child) ) )
            nRoot.addListener( event.listener( ...
                uix.EventSource.getInstance( oRoot ), ... % TODO
                'ObjectChildRemoved', ...
                @(~,e)obj.removeChild(nRoot,e.Child) ) )
            
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
                % Add property listeners
                nChild.addListener( event.proplistener( oChild, ...
                    findprop( oChild, 'HandleVisibility' ), 'PreSet', ...
                    @(~,~)obj.preSetHandleVisibility(nChild) ) )
                nChild.addListener( event.proplistener( oChild, ...
                    findprop( oChild, 'HandleVisibility' ), 'PostSet', ...
                    @(~,~)obj.postSetHandleVisibility(nChild) ) )
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
            if ishghandle( oChild ) && strcmp( oChild.HandleVisibility, 'on' )
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
                if ishghandle( oc ) && strcmp( oc.HandleVisibility, 'on' )
                    notify( obj, 'ChildRemoved', uix.ChildEvent( oc ) )
                end
                
            end % notifyChildRemoved
            
        end % removeChild
        
        function preSetHandleVisibility( ~, n )
            %preSetHandleVisibility  Perform property PreSet tasks
            %
            %  co.preSetHandleVisibility(n) stores the pre-set value of
            %  HandleVisibility of the object referenced by a node n.
            
            n.addprop( 'OldHandleVisibility' );
            n.OldHandleVisibility = n.Object.HandleVisibility;
            
        end % preSetHandleVisibility
        
        function postSetHandleVisibility( obj, n )
            %postSetHandleVisibility  Perform property PostSet tasks
            %
            %  co.postSetHandleVisibility(n) compares the pre- and post-set
            %  values of HandleVisibility of the object referenced by a
            %  node n, raising a ChildAdded or ChildRemoved event on the
            %  child observer co if appropriate.
            
            % Retrieve old and new HandleVisibility values
            oldViz = n.OldHandleVisibility;
            delete( findprop( n, 'OldHandleVisibility' ) )
            newViz = n.Object.HandleVisibility;
            
            % Raise event if required
            if strcmp( oldViz, 'on' ) && ~strcmp( newViz, 'on' )
                notify( obj, 'ChildRemoved', uix.ChildEvent( n.Object ) )
            elseif ~strcmp( oldViz, 'on' ) && strcmp( newViz, 'on' )
                notify( obj, 'ChildAdded', uix.ChildEvent( n.Object ) )
            end
            
        end % postSetHandleVisibility
        
    end % event handlers
    
end % classdef