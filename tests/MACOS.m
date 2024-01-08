CommonNameValuePairs = {
            'BackgroundColor', [1, 1, 0], ...
            'BorderType', 'line', ...
            'ButtonDownFcn', @glttestutilities.noop, ...
            'CreateFcn', @glttestutilities.noop, ...
            'ContextMenu', [], ...
            'DeleteFcn', @glttestutilities.noop, ...
            'Enable', 'on', ...
            'FontAngle', 'normal', ...
            'FontName', 'Monospaced', ...
            'FontSize', 20, ...
            'FontUnits', 'points', ...
            'FontWeight', 'bold', ...
            'ForegroundColor', [0, 0, 0], ...
            'HighlightColor', [1, 1, 1], ...
            'HandleVisibility', 'on', ...
            'Padding', 5, ...
            'Tag', 'Test', ...
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Visible', 'on'
            };

f = uifigure( "AutoResizeChildren", "off" );
p1 = uix.Panel( "Parent", f );
p2 = uiextras.Panel( 'Parent', f );

for k = 1 : 2 : numel( CommonNameValuePairs )
    n = CommonNameValuePairs{k};
    v = CommonNameValuePairs{k+1};
    try
        p1.(n) = v;
        p2.(n) = v;
        disp( "Set property " + n + " without problems." )
    catch e
        disp( "Failed to set property " + n + "." )
    end
end % for