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
        function addToLayout(hObj, obj, list, location)
            % Add an object to the specified layout list ('inner' or
            % 'outer') with the specified location ('north', 'south', 
            % 'east', 'west').
            
            % First, validate the inputs:
            if ~hObj.ValidateObject(obj)
                error(message('MATLAB:graphics:axeslayoutmanager:InvalidObject'));
            end
            if ~isempty(hObj.findInInnerList(obj)) || ~isempty(hObj.findInOuterList(obj))
                error(message('MATLAB:graphics:axeslayoutmanager:DuplicateEntry'));
            end

            try
                location = hgcastvalue('matlab.graphics.chart.datatype.ScribeLayoutType',location);
            catch E
                error(message('MATLAB:graphics:axeslayoutmanager:InvalidLocation'));
            end            
            
            % Set the parent of the object to the manager if the object is not
            % already a child of the manager.  Set the Parent before
            % updating the InnerList/OuterList to avoid update errors when
            % breaking during the setParentImpl.
            if ~ismember(obj,hObj.Children)
                obj.Parent_I = hObj;
            end
            
            if strcmpi(list,'inner')
                % Create a new list component of the object
                hObj.InnerList(end+1) = matlab.graphics.shape.internal.ListComponent(obj,location);
            elseif strcmpi(list,'outer')
                % Create a new list component of the object                
                hObj.OuterList(end+1) = matlab.graphics.shape.internal.ListComponent(obj,location);
            else
                error(message('MATLAB:graphics:axeslayoutmanager:InvalidList'));
            end

            % Mark the object dirty:
            hObj.MarkDirty('all');
        end
            
        function doUpdate(hObj, updateState)
            % Perform the layout:
            
            % If the figure is being destroyed, bail out early
            hAx = hObj.Axes;
            hFig = ancestor(hObj,'Figure');
            if strcmpi(hFig.BeingDeleted,'on')
                return;
            end
            
            % include the difference between the PlotBox and
            % DecoratedPlotBox in the adjustments when laying out
            % outerList items.  The starting layout footprint
            % should be the PlotBox, but we begin layout of outer
            % items at the DecoratedPlotBox.  So we need to adjust
            % for the axes decorations as well.
            currLayoutInfo = hAx.GetLayoutInformation;
            currPBPts = hgconvertunits(hFig,currLayoutInfo.PlotBox,'pixels','points',hAx.Parent);
            currDPBPts = hgconvertunits(hFig,currLayoutInfo.DecoratedPlotBox,'pixels','points',hAx.Parent);

            axDecAdjustments = [currPBPts(1) - currDPBPts(1), ...
                                              currPBPts(2) - currDPBPts(2), ...
                                             (currDPBPts(1) + currDPBPts(3)) - (currPBPts(1) + currPBPts(3)), ...
                                             (currDPBPts(2) + currDPBPts(4)) - (currPBPts(2) + currPBPts(4))];

            % offsets from axes edge or decorations
            outerPointsOffset = 12;
            innerPointsOffset = 12;

            if hObj.MakeRoom
                % use the activepositionproperty to manage axes position
                actPosProp = hAx.ActivePositionProperty;
                if strcmp(actPosProp,'position')
                    actPosProp_I = 'Position_I';
                else
                    actPosProp_I = 'OuterPosition_I';
                end

                % the current axes Position or OuterPosition based on the
                % ActivePositionProperty
                % g901155/g733129 - when screenpixelsperinch is not 72,
                % position will be incorrect for units other than pixels.
                currAxPos = hAx.(actPosProp_I);
                currAxPosPixels = hgconvertunits(hFig,currAxPos,hAx.Units,'pixels',hAx.Parent);
                currAxPosNorm = hgconvertunits(hFig,currAxPos,hAx.Units,'normalized',hAx.Parent);
                
                % we will use the stored starting layout position if both
                % of the following are true, else, update the starting
                % layout position.
                %
                %   1. the activePositionProperty of the axes has not
                %   changed since the last update
                %
                %   2. the current value of that property matches the
                %   expected value of that property
                tol = 10*eps(max(currAxPosPixels));
                axesInExpectedLocation = strcmp(actPosProp,hObj.ExpectedAxesPositionProperty) && ...
                                                            (max(abs(currAxPosPixels - hObj.ExpectedAxesPositionPixels)) < tol || ...
                                                            max(abs(currAxPosNorm - hObj.ExpectedAxesPositionNorm)) < tol);
                if ~axesInExpectedLocation
                    % if the axes is not where we expect it to be, but we
                    % are still in MakeRoom mode, then update the
                    % StartinglayoutPosition to be the current axes
                    % Position/OuterPosition.
                    hObj.StartingLayoutPosition = hgconvertunits(hFig,currAxPosPixels,'pixels','normalized',hAx.Parent);
                end
                
                % Adjust axes size based on the outer list
                % do layout in points
                startingLayoutPosition = hObj.StartingLayoutPosition;
                startingLayoutPosPoints = hgconvertunits(hFig,startingLayoutPosition,'normalized','points',hAx.Parent);
                
                % keep track of the outerList item inset adjustments 
                % [Left Bottom Right Top]
                adjustments = [0 0 0 0];     
                % a bit mask for when to include the axes decoration
                % adjustments.  Include them once if there is at least
                % one outerList item on the corresponding side [L B R T]
                useAxDecAdj = [0 0 0 0];
                    
                % In this implementation, the preferred size of the laid
                % out components will always be honored. (* except when the legend
                % is wider/taller than the axes and would push it off screen)
                % We will loop through the outer list and, for every object,
                % add space for it.
                outerList = hObj.OuterList;
                if ~isempty(outerList)
                    % get layout information from axes based on starting layout
                    % position, then restore the current position.  
                    % @TODO - it would nice if GetLayoutInformation could provide
                    % info based on inputs so this set/restore would not be
                    % necessary.
                    currAxUnits = hAx.Units;
                    hAx.Units_I = 'normalized';
                    currAxPosNorm = hAx.(actPosProp_I);
                    set(hAx,actPosProp_I,startingLayoutPosition);
                    % get plotbox and insets info from axes
                    startingLayoutInfo = hAx.GetLayoutInformation;
                    startingPlotBoxPoints = hgconvertunits(hFig,startingLayoutInfo.PlotBox,'pixels','points',hAx.Parent);
                    startingDecPlotBoxPoints = hgconvertunits(hFig,startingLayoutInfo.DecoratedPlotBox,'pixels','points',hAx.Parent);
                    % restore position, then units
                    set(hAx,actPosProp_I,currAxPosNorm);
                    hAx.Units_I = currAxUnits;

                    % include the difference between the PlotBox and
                    % DecoratedPlotBox in the adjustments when laying out
                    % outerList items.  The starting layout footprint
                    % should be the PlotBox, but we begin layout of outer
                    % items at the DecoratedPlotBox.  So we need to adjust
                    % for the axes decorations as well.
                    axDecAdjustments = [startingPlotBoxPoints(1) - startingDecPlotBoxPoints(1), ...
                                                      startingPlotBoxPoints(2) - startingDecPlotBoxPoints(2), ...
                                                     (startingDecPlotBoxPoints(1) + startingDecPlotBoxPoints(3)) - (startingPlotBoxPoints(1) + startingPlotBoxPoints(3)), ...
                                                     (startingDecPlotBoxPoints(2) + startingDecPlotBoxPoints(4)) - (startingPlotBoxPoints(2) + startingPlotBoxPoints(4))];

                                         
                    for i=1:numel(outerList)
                        prefSize = outerList(i).ObjectHandle.getPreferredSize(updateState,[startingPlotBoxPoints(3),startingPlotBoxPoints(4)]);
                        loc = outerList(i).Location;
                        if any(strcmpi(loc,{'east','west'}))
                            if prefSize(1) >= (startingPlotBoxPoints(3) - (adjustments(2) + adjustments(4)))% (*)
                                prefSize(1) = 0;
                            end
                            if strcmpi(loc,'west')
                                useAxDecAdj(1) = 1;
                                adjustments(1) = adjustments(1) + prefSize(1) + outerPointsOffset;
                            else % 'east'
                                useAxDecAdj(3) = 1;
                                adjustments(3) = adjustments(3) + prefSize(1) + outerPointsOffset;
                            end
                        else
                            if prefSize(2) >= (startingPlotBoxPoints(4) - (adjustments(1) + adjustments(3)))% (*)
                                prefSize(2) = 0;
                            end
                            if strcmpi(loc,'south')
                                useAxDecAdj(2) = 1;
                                adjustments(2) = adjustments(2) + prefSize(2) + outerPointsOffset;
                            else % 'north'
                                useAxDecAdj(4) = 1;
                                adjustments(4) = adjustments(4) + prefSize(2) + outerPointsOffset;
                            end
                        end
                    end
                end
                
                adjustments = adjustments + useAxDecAdj.*axDecAdjustments;
                   
                % apply the adjustments
                newAxPosPoints(1) = startingLayoutPosPoints(1) + adjustments(1);
                newAxPosPoints(2) = startingLayoutPosPoints(2) + adjustments(2);
                newAxPosPoints(3) = startingLayoutPosPoints(3) - adjustments(1) - adjustments(3);
                newAxPosPoints(4) = startingLayoutPosPoints(4) - adjustments(2) - adjustments(4);
                                
                % if the axes needs adjustment, set the axes Position
                currAxPosPoints = hgconvertunits(hFig,currAxPosPixels,'pixels','points',hAx.Parent);
                
                % if the result of adjustments was a negative position
                % value, revert to the current position and warn
                if any(newAxPosPoints < 0)
                    newAxPosPoints = currAxPosPoints;
                end
                if any(newAxPosPoints ~= currAxPosPoints)
                    newPos = hgconvertunits(hFig,newAxPosPoints,'points',hAx.Units,hAx.Parent);
                    set(hAx,actPosProp_I,newPos);
                    % Set position of plotyypeer.  We need to manage this
                    % bit of synchronization in the layout manager because
                    % we are using Position_I here, and there is not yet a
                    % way to keep two Position_I properties linked.
                    % Linkprop does not work, and _I properties are
                    % SetObservable = false (g800761)
                    if isprop(hObj,'PlotyyPeer') && isvalid(hObj.PlotyyPeer)
                        set(hObj.PlotyyPeer,actPosProp_I,newPos);
                    end                    
                end

                % update the expected axes position
                % we need to capture the normalized and absolute values
                % each time through so long as the MakeRoom feature is
                % active, regardless of whether any adjustments were
                % necessary on the current pass.
                hObj.ExpectedAxesPositionProperty = actPosProp;
                hObj.ExpectedAxesPositionNorm = hgconvertunits(hFig,newAxPosPoints,'points','normalized',hAx.Parent);
                hObj.ExpectedAxesPositionPixels = hgconvertunits(hFig,newAxPosPoints,'points','pixels',hAx.Parent);
            end % end hObj.MakeRoom     
                   
            % At this point, the axes has been positioned in a "known good"
            % location. 
            newLayoutInfo = hAx.GetLayoutInformation;
            newPlotBoxPoints = hgconvertunits(hFig,newLayoutInfo.PlotBox,'pixels','points',hAx.Parent);
            newDecPlotBoxPoints = hgconvertunits(hFig,newLayoutInfo.DecoratedPlotBox,'pixels','points',hAx.Parent);
            
            plotBox = newPlotBoxPoints;
            currOuterBox = newDecPlotBoxPoints;

            % Lay out the objects in the outer list:
            outerList = hObj.OuterList;
            for i=1:numel(outerList)
                hLayoutObj = outerList(i).ObjectHandle;
                prefSize = hLayoutObj.getPreferredSize(updateState,[newPlotBoxPoints(3),newPlotBoxPoints(4)]);
                % If the "isStretchToFill" method returns "true", this
                % means that we want to use the size of the axes.
                
                % determine size for StretchToFill objects
                fillSpace = newPlotBoxPoints(3:4);
                
                prefLoc = hLayoutObj.getPreferredLocation;
                % If we need to fill the space, do this here.
                if hLayoutObj.isStretchToFill
                    if any(strcmpi(outerList(i).Location,{'east','west'}))
                        prefSize(2) = fillSpace(2);
                    else
                        prefSize(1) = fillSpace(1);
                    end
                end
                switch(outerList(i).Location)
                    case 'east'
                        % For objects on the east outside, we will position
                        % them based on the right side of the box.
                        objPos = [0 0 prefSize];
                        objPos(1) = currOuterBox(1)+currOuterBox(3)+outerPointsOffset;
                        % For y, things get a bit complicated. We want to
                        % position ourselves based on the width of the
                        % axes, such that the center of the object matches
                        % the preferred y-location, which is normalized.
                        objPos(2) = min(plotBox(2)+plotBox(4)-prefSize(2),max(plotBox(2),plotBox(2)+prefLoc(2)*plotBox(4)-.5*prefSize(2)));
                        newObjPos = hgconvertunits(ancestor(hLayoutObj,'Figure'),objPos,'Points',hLayoutObj.Units,hLayoutObj.Parent);
                        if ~all(abs(hLayoutObj.Position_I-newObjPos) < eps)
                            hLayoutObj.Position_I = newObjPos;
                        end
                        % Update the points box for the next object:
                        % @TODO: prefSize(1) does not include the colorbar
                        % decorations.  We need a decoratedPlotBox
                        % equivalent for layout objects.  This will be true
                        % for all similar incrementing over all cases.
                        currOuterBox(3) = currOuterBox(3)+outerPointsOffset + prefSize(1);
                    case 'west'
                        % for objects on the west outside, we will position
                        % them based on the left side of the box.
                        objPos = [0 0 prefSize];
                        objPos(1) = currOuterBox(1)-prefSize(1)-outerPointsOffset;
                        % for y, things get a bit complicated. we want to
                        % position ourselves based on the width of the
                        % axes, such that the center of the object matches
                        % the preferred y-location, which is normalized.
                        objPos(2) = min(plotBox(2)+plotBox(4)-prefSize(2),max(plotBox(2),plotBox(2)+prefLoc(2)*plotBox(4)-.5*prefSize(2)));
                        newObjPos = hgconvertunits(ancestor(hLayoutObj,'figure'),objPos,'points',hLayoutObj.Units,hLayoutObj.Parent);
                        if ~all(abs(hLayoutObj.Position_I-newObjPos) < eps)
                            hLayoutObj.Position_I = newObjPos;
                        end
                        % Update the points box for the next object:
                        currOuterBox(1) = currOuterBox(1)-outerPointsOffset-prefSize(1);
                        currOuterBox(3) = currOuterBox(3)+outerPointsOffset+prefSize(1);
                    case 'north'
                        % for objects on the north outside, we will position
                        % them based on the top side of the box.
                        objPos = [0 0 prefSize];
                        objPos(2) = currOuterBox(2)+currOuterBox(4)+outerPointsOffset;
                        % for x, things get a bit complicated. we want to
                        % position ourselves based on the width of the
                        % axes, such that the center of the object matches
                        % the preferred x-location, which is normalized.
                        objPos(1) = min(plotBox(1)+plotBox(3)-prefSize(1),max(plotBox(1),plotBox(1)+prefLoc(1)*plotBox(3)-.5*prefSize(1)));
                        newObjPos = hgconvertunits(ancestor(hLayoutObj,'figure'),objPos,'points',hLayoutObj.Units,hLayoutObj.Parent);
                        if ~all(abs(hLayoutObj.Position_I-newObjPos) < eps)
                            hLayoutObj.Position_I = newObjPos;
                        end
                        % Update the points box for the next object:
                        currOuterBox(4) = currOuterBox(4)+outerPointsOffset+prefSize(2);
                    case 'south'
                        % for objects on the south outside, we will position
                        % them based on the bottom side of the box.
                        objPos = [0 0 prefSize];
                        objPos(2) = currOuterBox(2)-prefSize(2)-outerPointsOffset;
                        % for x, things get a bit complicated. we want to
                        % position ourselves based on the width of the
                        % axes, such that the center of the object matches
                        % the preferred y-location, which is normalized.
                        objPos(1) = min(plotBox(1)+plotBox(3)-prefSize(1),max(plotBox(1),plotBox(1)+prefLoc(1)*plotBox(3)-.5*prefSize(1)));
                        newObjPos = hgconvertunits(ancestor(hLayoutObj,'figure'),objPos,'points',hLayoutObj.Units,hLayoutObj.Parent);
                        if ~all(abs(hLayoutObj.Position_I-newObjPos) < eps)
                            hLayoutObj.Position_I = newObjPos;
                        end
                        % Update the points box for the next object:
                        currOuterBox(2) = currOuterBox(2)-outerPointsOffset-prefSize(2);
                        currOuterBox(4) = currOuterBox(4)+outerPointsOffset+prefSize(2);
                end
            end
            % Lay out the objects in the inner list:
            innerList = hObj.InnerList;
            currInnerBox = plotBox;
            for i=1:numel(innerList)
                hLayoutObj = innerList(i).ObjectHandle;
                prefSize = hLayoutObj.getPreferredSize(updateState,[newPlotBoxPoints(3),newPlotBoxPoints(4)]);
                fillSpace = plotBox(3:4)-2*innerPointsOffset;
                prefLoc = hLayoutObj.getPreferredLocation;
                % If we need to fill the space, do this here.
                if hLayoutObj.isStretchToFill
                    if any(strcmpi(innerList(i).Location,{'east','west'}))
                        prefSize(2) = fillSpace(2);
                    else
                        prefSize(1) = fillSpace(1);
                    end
                end               
                switch(innerList(i).Location)
                    case 'east'
                        % For objects on the east outside, we will position
                        % them based on the right side of the axes box.
                        objPos = [0 0 prefSize];
                        objPos(1) = currInnerBox(1)+currInnerBox(3)-prefSize(1)-innerPointsOffset;
                        % For y, things get a bit complicated. We want to
                        % position ourselves based on the width of the
                        % axes, such that the center of the object matches
                        % the preferred y-location, which is normalized.
                        objPos(2) = min(plotBox(2)+plotBox(4)-prefSize(2)-innerPointsOffset,max(plotBox(2)+innerPointsOffset,plotBox(2)+prefLoc(2)*plotBox(4)-.5*prefSize(2)));
                        newObjPos = hgconvertunits(ancestor(hLayoutObj,'Figure'),objPos,'Points',hLayoutObj.Units,hLayoutObj.Parent);
                        if ~all(abs(hLayoutObj.Position_I-newObjPos) < eps)
                            hLayoutObj.Position_I = newObjPos;
                        end
                        % Update the points box for the next object:
                        currInnerBox(3) = currInnerBox(3)-prefSize(1)-innerPointsOffset;
                    case 'west'
                        % for objects on the west outside, we will position
                        % them based on the left side of the box.
                        objPos = [0 0 prefSize];
                        objPos(1) = currInnerBox(1)+innerPointsOffset;
                        % for y, things get a bit complicated. we want to
                        % position ourselves based on the width of the
                        % axes, such that the center of the object matches
                        % the preferred y-location, which is normalized.
                        objPos(2) = min(plotBox(2)+plotBox(4)-prefSize(2)-innerPointsOffset,max(plotBox(2)+innerPointsOffset,plotBox(2)+prefLoc(2)*plotBox(4)-.5*prefSize(2)));
                        newObjPos = hgconvertunits(ancestor(hLayoutObj,'figure'),objPos,'points',hLayoutObj.Units,hLayoutObj.Parent);
                        if ~all(abs(hLayoutObj.Position_I-newObjPos) < eps)
                            hLayoutObj.Position_I = newObjPos;
                        end
                        % Update the points box for the next object:
                        currInnerBox(1) = currInnerBox(1)+prefSize(1)+innerPointsOffset;
                        currInnerBox(3) = currInnerBox(3)-prefSize(1)-innerPointsOffset;                        
                    case 'north'
                        % for objects on the north outside, we will position
                        % them based on the top side of the box.
                        objPos = [0 0 prefSize];
                        objPos(2) = currInnerBox(2)+currInnerBox(4)-prefSize(2)-innerPointsOffset;
                        % for x, things get a bit complicated. we want to
                        % position ourselves based on the width of the
                        % axes, such that the center of the object matches
                        % the preferred x-location, which is normalized.
                        objPos(1) = min(plotBox(1)+plotBox(3)-prefSize(1)-innerPointsOffset,max(plotBox(1)+innerPointsOffset,plotBox(1)+prefLoc(1)*plotBox(3)-.5*prefSize(1)));
                        newObjPos = hgconvertunits(ancestor(hLayoutObj,'figure'),objPos,'points',hLayoutObj.Units,hLayoutObj.Parent);
                        if ~all(abs(hLayoutObj.Position_I-newObjPos) < eps)
                            hLayoutObj.Position_I = newObjPos;
                        end
                        % Update the points box for the next object:
                        currInnerBox(4) = currInnerBox(4)-prefSize(2)-innerPointsOffset;
                    case 'south'
                        % for objects on the south outside, we will position
                        % them based on the bottom side of the box.
                        objPos = [0 0 prefSize];
                        objPos(2) = currInnerBox(2)+innerPointsOffset;
                        % for x, things get a bit complicated. we want to
                        % position ourselves based on the width of the
                        % axes, such that the center of the object matches
                        % the preferred y-location, which is normalized.
                        objPos(1) = min(plotBox(1)+plotBox(3)-prefSize(1)-innerPointsOffset,max(plotBox(1)+innerPointsOffset,plotBox(1)+prefLoc(1)*plotBox(3)-.5*prefSize(1)));
                        newObjPos = hgconvertunits(ancestor(hLayoutObj,'figure'),objPos,'points',hLayoutObj.Units,hLayoutObj.Parent);
                        if ~all(abs(hLayoutObj.Position_I-newObjPos) < eps)
                            hLayoutObj.Position_I = newObjPos;
                        end
                        % Update the points box for the next object:
                        currInnerBox(2) = currInnerBox(2)+prefSize(2)+innerPointsOffset;
                        currInnerBox(4) = currInnerBox(4)-prefSize(2)-innerPointsOffset;
                end
            end
            
            % update layout info in axes appdata for save/load
            s.MakeRoom = hObj.MakeRoom;
            s.ExpectedAxesPositionNorm = hObj.ExpectedAxesPositionNorm;
            s.ExpectedAxesPositionPixels = hObj.ExpectedAxesPositionPixels;
            s.ExpectedAxesPositionProperty = hObj.ExpectedAxesPositionProperty;
            s.StartingLayoutPosition = hObj.StartingLayoutPosition;
            setappdata(hAx,'LayoutInfo',s);
        end
            
        function hParent = getParentImpl(~, hParent)
            % Unlike other UIParentable objects, we don't want to lie about 
            % our parent.
        end
        
        function enableAxesDirtyListeners(hObj, trueFalse)
            % enable or disable the MarkedDirty listener
            % support for PAN to disable unnecessary updates of legend and
            % colorbar during a pan operation.
            hObj.AxesDirtyListener.Enabled = trueFalse;
            if ~isempty(hObj.ListenerList)
                for i=1:numel(hObj.ListenerList)
                    % enable/disable the layout manager's marked dirty
                    % listeners on each of its layout objects
                    hObj.ListenerList(i).Enabled = trueFalse;
                    % enable/disable each layout object's marked dirty
                    % listener on the Axes
                    hObj.ListenerList(i).Source{1}.enableAxesDirtyListeners(trueFalse);
                end
            end
        end
    end

    
end
