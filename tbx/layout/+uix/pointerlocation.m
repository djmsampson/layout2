function p = pointerlocation( eventData )
%pointerlocation  Pointer location in pixels
%
%  p = uix.pointerlocation(e) returns the current pointer location
%  in pixels, based on the WindowMouseData event data e.
%
%  In Java graphics, this function returns the location relative to the
%  primary screen origin, using the root PointerLocation. This is because
%  the WindowMouseData Point is not correct.
%
%  In JavaScript graphics, this function returns the location relative to
%  the figure origin, using the WindowMouseData Point. This is because the
%  root PointerLocation is not correct in MATLAB Online.

%  Copyright 2025 The MathWorks, Inc.

f = eventData.Source; % figure
switch uix.figuretype( f ) % figure type
    case 'js' % JavaScript including MATLAB Online
        p = hgconvertunits( f, [eventData.Point 0 0], f.Units, ...
            'pixels', f ); % requires 1x4
        p = p(1:2); % 1x2
    otherwise % Java
        r = groot(); % graphics root
        units = r.Units; % capture original units
        r.Units = 'pixels'; % change units to pixels
        p = r.PointerLocation; % pointer location in pixels
        r.Units = units; % change units back to original
end

end % pointerlocation