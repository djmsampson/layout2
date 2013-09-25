function position = getPixelPosition(h,recursive)
% GETPIXELPOSITION Get the position of an HG object in pixel units.
%   GETPIXELPOSITION(HANDLE) gets the position of the object specified by
%   HANDLE in pixel units.
%
%   GETPIXELPOSITION(HANDLE, RECURSIVE) gets the position as above. If
%   RECURSIVE is true, the returned position is relative to the parent
%   figure of HANDLE.
%
%   POSITION = GETPIXELPOSITION(...) returns the pixel position in POSITION.
%
%   Example:
%       f = figure;
%       p = uipanel('Position', [.2 .2 .6 .6]);
%       h1 = uicontrol(p, 'Units', 'normalized', 'Position', [.1 .1 .5 .2]);
%       % Get pixel position w.r.t the parent uipanel
%       pos1 = getpixelposition(h1)
%       % Get pixel position w.r.t the parent figure using the recursive flag
%       pos2 = getpixelposition(h1, true)
%
%   See also SETPIXELPOSITION, UICONTROL, UIPANEL

% Copyright 1984-2010 The MathWorks, Inc.
% $Revision: 1.1.6.11 $ $Date: 2011/03/09 07:05:43 $
  
% Verify that getpixelposition is given between 1 and 2 arguments
persistent pixOrigin;

% @todo - Pixel origin has crept into MATLAB code. This should be made a
% built-in.
if isempty(pixOrigin)
    pixOrigin = 1;
end

error(nargchk(1, 2, nargin, 'struct')) 

% Verify that "h" is a handle
if ~ishghandle(h)
    error(message('MATLAB:getpixelposition:InvalidHandle'))
end

if nargin < 2
  recursive = false;
end

parent = get(h,'Parent');

% Use hgconvertunits to get the position in pixels (avoids recursion
% due to unit changes triggering resize events which re-call
% getpixelposition)
position = hgconvertunits(ancestor(h,'figure'),get(h,'Position'),get(h,'Units'),...
          'Pixels',parent);      

if recursive && ~ishghandle(h,'figure') && ~ishghandle(parent,'figure')
 parentPos = uix.getPixelPosition(parent, recursive); 
 position = position + [parentPos(1) parentPos(2) 0 0] - [pixOrigin pixOrigin 0 0];
end
  

