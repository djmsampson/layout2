function [hcomponent, hcontainer] = javacomponent( s, parent )

%   Copyright 2010-2013 The MathWorks, Inc.

position = [20 20 60 20]; % default;

hcomponent = javaObjectEDT( s );

%Show on screen and return the hg proxy
[hcontainer, parent , hgCleansJava, javaCleansHG] = applyArgumentsAndShow(hcomponent, position, parent);

%Special bug fixes
customizeSwingHandleForPainting(hcomponent);

%enable cleanup
enableAutoCleanup(getHGOwnerForCleanup(hcontainer,parent), hcomponent, hgCleansJava, javaCleansHG);

end

%-------------------------------------------------------------------
function customizeSwingHandleForPainting(hcomponent)
if isa(java(hcomponent), 'javax.swing.JComponent')
    % force component to be opaque if it's a JComponent. This prevents
    % lightweight component from showing the figure background (which
    % may never get a paint event)
    hcomponent.setOpaque(true);
end
end

%-------------------------------------------------------------------
% This is needed for a rather silly reason that hcontainer and "hg object responsible for cleanup" could
% be 2 different things in the case of the border layout. 
function owner = getHGOwnerForCleanup(hcontainer,parent)
if (isempty(hcontainer))
    % We are dealing with the border layout
    owner = ancestor(parent,'figure');
else
    % We are dealing with the following
    % hgjavacomponent/uitoolbar/uitogglesplittool
    owner = hcontainer;
end
end

%-------------------------------------------------------------------
function [hgProxy , parent, hgCleansJava, javaCleansHG] = applyArgumentsAndShow(hcomponent, position, parent)
if isempty(parent)
    parent = gcf;
end
component = java(hcomponent);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Content area hosting javacomponent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isa(parent,'matlab.ui.container.CanvasContainer')
    %If we are here then we want in the drawing area of the
    %figure.
    %If position is numeric, then it is pixel positioning
    if (isnumeric(position))
        hgProxy = hgjavacomponent('Parent',parent,'JavaPeer',java(hcomponent),'Units','pixels','Position',position,'Serializable','off');
        %For the sake of findobj, we need to do the following.
        set(hgProxy, 'UserData', char(component.getClass.getName)); 
        hgCleansJava = @(o,e) deleteComponent(o,e,hcomponent);
        javaCleansHG = @(o,e) delete(hgProxy);
    %Else if the positioning is a string, then border layout is requested.
    elseif (ischar(position))
        hgProxy = [];
        figParent = parent;
        % We are assuming here that figurepeer is constructed and hence
        % adding is OK. We need to be sure that this is always the case.
        peer = getJavaFrame(figParent);
        peer.addchild(java(hcomponent),position);
        hgCleansJava = @(o,e) deleteComponent(o,e,hcomponent);
        javaCleansHG = @(o,e) removeComponent(o,e,peer,component);
   else
        %We are not sure what was requested.
        assert(false,'Position can either be numeric or a string');
    end
    % If it is a toolbar, then setup a toolbar host.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Toolbar hosting javacomponent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif isa(parent,'matlab.ui.container.Toolbar')
    %The toolbar parent is the HG representative. All of the following code
    %is not enough because the figure could still be invisible and hence
    %the toolbar or toolbar tool's peer may not be set up yet.
    % @todo - Can we force toolbar creation when its JavaContainer property is
    % requested? - SVN
    hgProxy = parent;
    peer = get(hgProxy,'JavaContainer');
    if isempty(peer)
        drawnow('update');
        peer = get(hgProxy,'JavaContainer');
    end
    peer.add(component);
    hgCleansJava = @(o,e) deleteComponent(o,e,hcomponent);
    javaCleansHG = @(o,e) removeComponent(o,e,peer,component);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% uisplittool/uitogglesplittool hosting javacomponent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (isa(parent,'matlab.ui.container.toolbar.ToggleSplitTool') || ...
            isa(parent,'matlab.ui.container.toolbar.SplitTool'))
    %The toolbar tool is the HG representative. All of the following code
    %is not enough because the figure could still be invisible and hence
    %the toolbar or toolbar tool's peer may not be set up yet. 
    % @todo - Can we force toolbar tool's creation when its JavaContainer property is
    % requested? - SVN
    hgProxy = parent;
    toolbar = get(hgProxy,'Parent');
    peer = get(hgProxy,'JavaContainer');
    parPeer = get(toolbar,'JavaContainer');
    if isempty(parPeer)
        drawnow('update');
    end
    if isempty(peer)
       drawnow('update');
       peer = get(hgProxy,'JavaContainer'); 
    end
    peer.add(component);
    hgCleansJava = @(o,e) deleteComponent(o,e,hcomponent);
    javaCleansHG = @(o,e) removeComponent(o,e,peer,component);
else
    assert(false,'Invalid input');
end
end

%-------------------------------------------------------------------
% If there was true containment as we have now in most cases, there is no post processing needed in the
% java side. 
% 1. javacomponent inside hgjavacomponent
% 2. javacomponent inside toolbar
% 3. javacomponent inside toolbar tools.
% What is not handled here is the border layout case where the
% javacomponent is added to the figure. Hence when we delete the
% javacomponent, we need to go remove it from the figure (Look for
% peer.remove or wireBorderLayoutCleanup in this file for a special case clean up)
function enableAutoCleanup(hgowner , hcomponent, hgCleansJava, javaCleansHG)
assert(ishghandle(hgowner));
addlistener(hgowner,'ObjectBeingDestroyed',hgCleansJava);

%Set up auto deletion on the hgjavacomponent
jListener = handle.listener(hcomponent, 'ObjectBeingDestroyed',javaCleansHG);
savelistener(hcomponent, jListener);
end

%-----------------------------------------------------
% javalistener callback setup
%-----------------------------------------------------
function hdl=javalistener(jobj, eventName, response)
try
    jobj = java(jobj);
catch ex  %#ok
end

% make sure we have a Java objects
if ~ishandle(jobj) || ~isjava(jobj)
    error(message('MATLAB:javacomponent:invalidinput'))
end

hSrc = handle(jobj,'callbackproperties');
allfields = sortrows(fields(set(hSrc)));
alltypes = cell(length(allfields),1);
j = 1;
for i = 1:length(allfields)
    fn = allfields{i};
    if ~isempty(strfind(fn,'Callback'))
        fn = strrep(fn,'Callback','');
        alltypes{j} = fn;
        j = j + 1;
    end
end
alltypes = alltypes(~cellfun('isempty',alltypes));

if nargin == 1
    % show or return the possible events
    if nargout
        hdl = alltypes;
    else
        disp(alltypes)
    end
    return;
end

% validate event name
valid = any(cellfun(@(x) isequal(x,eventName), alltypes));

if ~valid
    error(message('MATLAB:javacomponent:invalidevent', class( jobj ), char( cellfun( @(x) sprintf( '\t%s', x ), alltypes, 'UniformOutput', false ) )'))
end

hdl = handle.listener(handle(jobj), eventName, ...
    @(o,e) cbBridge(o,e,response));
    function cbBridge(o,e,response)
        hgfeval(response, java(o), e.JavaEvent)
    end
end

%-----------------------------------------------------
% savelistener callback setup
%-----------------------------------------------------
function savelistener(hC,hl)
for i= 1:numel(hC)
    p = findprop(hC(i), 'Listeners__');
    if (isempty(p))
        p = schema.prop(hC(i), 'Listeners__', 'handle vector');
        % Hide this property and make it non-serializable and
        % non copy-able.
        set(p,  'AccessFlags.Serialize', 'off', ...
            'AccessFlags.Copy', 'off',...
            'FactoryValue', [], 'Visible', 'off');
    end
    % filter out any non-handles
    hC(i).Listeners__ = hC(i).Listeners__(ishandle(hC(i).Listeners__));
    hC(i).Listeners__ = [hC(i).Listeners__; hl];
end
end

%-----------------------------------------------------
% When we delete the HG host, we perform the following operation
%-----------------------------------------------------
function deleteComponent(~,~,hcomponent)
   if (ishandle(hcomponent))
       removeJavaCallbacks(hcomponent);
       delete(hcomponent);
   end
end


%-----------------------------------------------------
% When we delete the handle to the java object, we perform the following operation
%-----------------------------------------------------
function removeComponent(~,~,peer,component)
    peer.remove(component);
end

%-----------------------------------------------------
% Get the figure's JavaFrame property (used by border layout)
%-----------------------------------------------------
function javaFrame = getJavaFrame(f)
% store the last warning thrown
[ lastWarnMsg, lastWarnId ] = lastwarn;
% disable the warning when using the 'JavaFrame' property
% this is a temporary solution
oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
javaFrame = get(f,'JavaFrame');
warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
% restore the last warning thrown
lastwarn(lastWarnMsg, lastWarnId);
end
