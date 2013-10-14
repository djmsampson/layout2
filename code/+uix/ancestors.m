function a = ancestors( h )
%uix.ancestors  Get object ancestors
%
%  a = uix.ancestors(h) gets the ancestors of the object h, from top to
%  bottom.  For rooted objects, the highest level ancestor returned is the
%  figure, not the root.

% Find ancestors
a = matlab.graphics.GraphicsPlaceholder.empty( [0 1] ); %  initialize
p = h.Parent;
while ~isempty( p ) && ~isa( p, 'matlab.ui.Root' )
    a = [p; a]; %#ok<AGROW>
    p = p.Parent;
end

end % uix.ancestors