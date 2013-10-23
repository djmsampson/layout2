classdef AxesLayoutManager < matlab.graphics.primitive.world.Group & matlab.graphics.mixin.UIParentable
    % This class manages axes layout. It is an internal-only class and not
    % meant for public consumption. We will use a modified singleton
    % pattern for the manager as there should only be one in existence per
    % axes.
    
    %   Copyright 2009-2013 The MathWorks, Inc.
    
    properties (SetAccess = private)
        Axes; %This should be a matlab.graphics.mixin.UIParentable scalar
    end
    
    properties (SetAccess = private, GetAccess = private)
        % This controls whether Axes is in 'make room for legend' mode
        MakeRoom@logical = true;
        % This is the last known  position assigned by the layout manager
        % to the axes.  Always store this value in normalized units
        ExpectedAxesPositionNorm = [0 0 1 1]; %This should be a Position
        ExpectedAxesPositionPixels = [1 1 560 420];
        ExpectedAxesPositionProperty = 'outerposition';
        % This is the position of the axes we use when resizing the
        % axes to account for outerlist items.
        % Always store the StartingLayoutPosition in normalized units.
        StartingLayoutPosition = [0 0 1 1];
        % We only want to sync LayoutInfo from axes appdata once
        SyncLayoutInfo@logical = true;
    end
    
    properties (SetAccess = private, GetAccess = private, Transient = true)   
        % We will maintain two layout lists - an inner and an outer.
        InnerList = matlab.graphics.shape.internal.ListComponent.empty; %This should be a matlab.graphics.shape.internal.ListComponent vector
        OuterList = matlab.graphics.shape.internal.ListComponent.empty; %This should be a matlab.graphics.shape.internal.ListComponent vector
        
        % We also need to cache the "MarkedDirty" listeners for the various
        % objects in the scene
        ListenerList = event.listener.empty; %This should be a event.listener vector 
        AxesDirtyListener = event.listener.empty; %This should be a event.listener vector
        
        %add listeners to Position and OuterPosition to manage MakeRoom
        %mode
        AxesPositionListeners = event.proplistener.empty;
    end
    
    methods
        function set.Axes(hObj,hAx)
            hObj.Axes = hAx;
        end
    end
    
    methods (Access = public, Static = true)        
        function hObj = getManager(hAx)
                hObj = uix.AxesLayoutManager(hAx);
                % Insert the manager into the tree.
                hObj.insertAboveAxes();
        end
    end
    
    methods (Access = private)
        function hObj = AxesLayoutManager(hAx)
            hObj.Axes = hAx;
        end
        
        function insertAboveAxes(hObj)
            % Preserve existing child order prior to layout manager being added.
            % @todo use SET instead of dot notation (g641267)
            hAx = hObj.Axes;
            hAxParent = hAx.Parent;
            hAxSiblings = flipud(get(hAxParent,'Children'));
            oldSubplotGrid = [];
            if ~isempty(hAxParent)
                oldSubplotGrid = getappdata(hAxParent,'SubplotGrid');
            end
            for i = 1:numel(hAxSiblings)
                if hAxSiblings(i)==hAx
                    emptyGroup = matlab.graphics.primitive.world.Group.empty();
                    set(hAxSiblings(i+1:end),'Parent',emptyGroup);
                    hObj.Parent = hAxParent;
                    set(hAxSiblings, 'Parent', hAxParent);
                end
            end

            hObj.addNode(hAx);

        end
        
    end
    
    methods (Access = public)
            
        function doUpdate(~,~)
            return
        end
            
        function hParent = getParentImpl(~, hParent)
            % Unlike other UIParentable objects, we don't want to lie about 
            % our parent.
        end
        
    end

    
end
