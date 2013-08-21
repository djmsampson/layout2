function [pvc, pvo] = pvsplit( pv, c )
%pvsplit  Split parameter value pairs

% Check
uix.pvchk( pv )

% Extract parameters and values
p = pv(1:2:end);
v = pv(2:2:end);

% Split
cl = meta.class.fromName( c );
pl = cl.PropertyList;
tf = ismember( p, {pl([pl.DefiningClass] == cl).Name} );
pvc = [p(tf); v(tf)];
pvc = (pvc(:))'; % to list
pvo = [p(~tf); v(~tf)];
pvo = (pvo(:))'; % to list

end % pvsplit