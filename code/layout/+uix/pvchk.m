function pvchk( pv )
%uix.pvchk  Check parameter value pairs
%
%  uix.pvcvk(pv) checks the cell array of parameter value pairs pv.  An
%  error is issued if:
%  * The number of parameters does not match the number of values
%  * Any parameter is not a string
%  * Any parameter is repeated
%
%  This function is typically used from class constructors,
%  uix.pvchk(varargin).

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision$ $Date$

if rem( numel( pv ), 2 ) ~= 0
    MException( 'uix:InvalidArgument' ).throwAsCaller()
elseif ~all( cellfun( @ischar, pv(1:2:end) ) )
    MException( 'uix:InvalidArgument' ).throwAsCaller()
elseif numel( pv(1:2:end) ) ~= numel( unique( pv(1:2:end) ) )
    MException( 'uix:InvalidArgument' ).throwAsCaller()
end   
    
end % pvchk