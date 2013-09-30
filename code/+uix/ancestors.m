function [a, f] = ancestors( h )

a = h; %  initialize
p = h.Parent;
while ~isempty( p ) && ~isa( p, 'matlab.ui.Root' )
    a = [p; a]; %#ok<AGROW>
    p = p.Parent;
end

if nargout > 1
    if isempty( p )
        f = p;
    else
        f = a(1);
    end
end

end