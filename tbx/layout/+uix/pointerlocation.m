function p = pointerlocation( eventData )
%pointerlocation  Pointer location in pixels
%
%  p = uix.pointerlocation(e) returns the current pointer location
%  in pixels, using the WindowMouseData e.
%
%  In Java graphics, this function uses the root
%  PointerLocation relative to the primary screen origin,
%  because the WindowMouseData Point is not correct.
%
%  In JavaScript graphics, this function uses the
%  WindowMouseData Point relative to the figure origin, because
%  the root PointerLocation is not correct.

f = eventData.Source; % figure
switch uix.figuretype( f ) % figure type
    case 'js' % JavaScript including MATLAB Online
        p = hgconvertunits( f, [eventData.Point 0 0], ...
            f.Units, 'pixels', f ); % requires 1x4
        p = p(1:2); % pointer [pixels]
    otherwise % Java
        r = groot();
        units = r.Units;
        r.Units = 'pixels';
        p = r.PointerLocation;
        r.Units = units;
end

end % pointerlocation