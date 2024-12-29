function e = extent( c )
%extent  Extent of uicontrol
%
%   e = uix.extent(c) returns the extent of the uicontrol c.
%
%   For Java graphics, this function simply returns the Extent property.
%   For JavaScript graphics, the Extent property is unreliable for large
%   font sizes, and this function is more accurate.

% Get nominal extent
e = c.Extent;

% Correct height for web graphics
f = ancestor( c, 'figure' );
if ~isempty( f ) && verLessThan( 'MATLAB', '25.1' ) && ...
        isprop( f, 'JavaFrame_I' ) && isempty( f.JavaFrame_I ) %#ok<VERLESSMATLAB>
    df = figure( 'Visible', 'off' ); % dummy *Java* figure
    dc = copyobj( c, df ); % dummy control
    e(4) = dc.Extent(4); % use Java height
    delete( df ) % clean up
end

end % extent