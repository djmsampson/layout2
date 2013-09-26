function position = getPixelPosition( object, figure, recursive )

% Check inputs
narginchk( 2, 3 )
        
% Get position
if isempty( figure ) % unrooted
    position = [NaN NaN NaN NaN];
else % in figure
    % Handle inputs
    if nargin < 3
        recursive = false;
    end
    % Get position relative to parent
    parent = object.Parent;
    position = hgconvertunits( figure, object.Position, object.Units, 'pixels', parent );
    % Add offsets for each parent
    if recursive && ~isequal( object, figure )
        while ~isequal( parent, figure )
            % Compute offset relative to parent
            object = parent;
            parent = object.Parent;
            offset = hgconvertunits( figure, object.Position, object.Units, 'pixels', parent );
            % Adjust position by offset
            position = position + [offset(1) offset(2) 0 0] - [1 1 0 0];
        end
    end
end

end % getPixelPosition