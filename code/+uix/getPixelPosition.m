function position = getPixelPosition( h, recursive )

% Check inputs
narginchk( 1, 2 )

% Get position
figure = ancestor( h, 'figure' );
if isempty( figure ) % unrooted
    position = [NaN NaN NaN NaN];
else % in figure
    % Handle inputs
    if nargin < 2
        recursive = false;
    end
    % Get position relative to parent
    parent = h.Parent;
    position = hgconvertunits( figure, h.Position, h.Units, 'pixels', parent );
    % Add offsets for each parent
    if recursive && ~isequal( h, figure )
        while ~isequal( parent, figure )
            % Compute offset relative to parent
            h = parent;
            parent = h.Parent;
            offset = hgconvertunits( figure, h.Position, h.Units, 'pixels', parent );
            % Adjust position by offset
            position = position + [offset(1) offset(2) 0 0] - [1 1 0 0];
        end
    end
end

end % getPixelPosition