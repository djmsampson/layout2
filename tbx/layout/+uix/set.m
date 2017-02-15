function set( obj, varargin )
%uix.set  Set property values
%
%  uix.set(o,p1,v1,p2,v2,...) sets property p1 of the object o to value v1,
%  property p2 to o2, etc.
%
%  In contrast to builtin set, querying possible values is not supported.

if nargin == 1, return, end
assert( rem( nargin, 2 ) == 1, 'uix:InvalidArgument', ...
    'Parameters and values must be provided in pairs.' )
set( obj, varargin{:} )

end % set