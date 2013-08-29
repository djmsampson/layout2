function o = hgGetTrueParent( c )
%hgGetTrueParent  Get the parent of a graphics object
%
%  p = hgGetTrueParent(c) returns the parent p of an object c.
%
%  hgGetTrueParent returns the true parent in the internal tree, which may
%  differ from the value returned by the property Parent.
%
%  See also: hgGetTrueChildren

o = nGetParent( c.Parent ); % search from the Parent down
if ~isempty( o ), return, end % return if we are done
o = nGetParent( groot() ); % search the entire tree

    function p = nGetParent( n )
        %nGetParent  Get parent
        %
        %  p = nGetParent(n) returns the parent p of an object c (defined
        %  in the outer function), beginning the search from the object n.
        %
        %  nGetParent iterates over the descendants of n, looking for c.
        %  If c is not under n then p = [].
        
        k = hgGetTrueChildren( n ); % get the children
        for ii = 1:numel( k ) % loop over the children
            if k(ii) == c % if this child matches the object
                p = n;
                return % then we are done
            else % otherwise
                p = nGetParent( k(ii) ); % continue searching below this child
                if ~isempty( p ) % if a parent is found
                    return % then we are done
                end
            end
        end
        p = matlab.graphics.GraphicsPlaceholder.empty( [0 0] ); % unsuccessful
        
    end % nGetParent

end % hgGetTrueParent