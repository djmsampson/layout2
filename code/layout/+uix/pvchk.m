function pvchk( pv )

if rem( numel( pv ), 2 ) ~= 0
    MException( 'uix:InvalidArgument' ).throwAsCaller()
elseif ~all( cellfun( @ischar, pv(1:2:end) ) )
    MException( 'uix:InvalidArgument' ).throwAsCaller()
elseif numel( pv(1:2:end) ) ~= numel( unique( pv(1:2:end) ) )
    MException( 'uix:InvalidArgument' ).throwAsCaller()
end   
    
end % pvchk