function [cdata, varargout] = wingetframe( f, d )
%wingetframe  Capture figure at native resolution
%
%  cdata = wingetframe(f) captures a screenshot of the figure f at native
%  resolution using Windows APIs.  The figure must be undocked and on a
%  single screen.
%
%  ... = wingetframe(f,d) waits d seconds before capturing the screenshot.

arguments
    f (1,1) matlab.ui.Figure
    d (1,1) double = 0.1
end

% Set figure window style to always on top, temporarily
assert( f.WindowStyle ~= "docked", "uix:InvalidOperation", ...
    mfilename + " is not supported for docked figures." )
style = f.WindowStyle;
f.WindowStyle = "alwaysontop";
pause( d )
styleUp = onCleanup( @()set( f, "WindowStyle", style ) );

% On which screen is the figure?
root = groot();
pFigure = f.Position;
pScreen = root.MonitorPositions;
iScreen = 0; % figure screen index, initialize
for ii = 1:size( pScreen, 1 )
    if pFigure(1) >= floor( pScreen(ii,1) ) && ...
            pFigure(1) <= ceil( pScreen(ii,1) + pScreen(ii,3) ) && ...
            pFigure(2) >= floor( pScreen(ii,2) ) && ...
            pFigure(2) <= ceil( pScreen(ii,2) + pScreen(ii,4) )
        iScreen = ii;
        break
    end
end
assert( iScreen ~= 0, "uix:ItemNotFound", ...
    "Cannot find screen for figure %g.", double( f ) ) % not found
pScreen = pScreen(iScreen,:);

% What is the position?
NET.addAssembly( "System.Windows.Forms" );
oScreen = System.Windows.Forms.Screen.AllScreens(iScreen);
scale = double( oScreen.Bounds.Width ) / pScreen(3);
left = ( pFigure(1) - pScreen(1) ) * scale ...
    + double( oScreen.Bounds.Left ) + 1;
top = ( pScreen(4) - pScreen(2) + 1 - pFigure(2) - pFigure(4) + 1 ) ...
    * scale + double( oScreen.Bounds.Top ) - 1;
width = pFigure(3) * scale;
height = pFigure(4) * scale;

% Capture
filename = tempname + ".bmp";
fileUp = onCleanup( @()delete( filename ) );
NET.addAssembly( "System.Drawing" );
bitmap = System.Drawing.Bitmap( width, height );
graphic = System.Drawing.Graphics.FromImage( bitmap );
graphic.CopyFromScreen( left, top, 0, 0, bitmap.Size );
bitmap.Save( filename );
[cdata, varargout{1:nargout}] = imread( filename );

end % wingetframe