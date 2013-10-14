function [a, f] = ancestors( h )
%uix.ancestors  Get object ancestors
%
%  a = uix.ancestors(h) gets the ancestors of the object h, from top to
%  bottom.  For rooted objects, the highest level ancestor returned is the
%  figure, not the root.
%
%  [a,f] = uix.ancestors(h) returns the figure ancestor f directly.  For
%  unrooted objects, f is an empty placeholder.

% Find ancestors
a = matlab.graphics.GraphicsPlaceholder.empty( [0 1] ); %  initialize
p = h.Parent;
while ~isempty( p ) && ~isa( p, 'matlab.ui.Root' )
    a = [p; a]; %#ok<AGROW>
    p = p.Parent;
end

% Return figure is requested
if nargout > 1
    if isempty( p )
        f = p;
    else
        f = a(1);
    end
end

end % uix.ancestors