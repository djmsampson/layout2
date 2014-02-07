function rgb = hex2rgb( hex )
%hex2rgb: convert a 3 or 6 character hex colour into a MATLAB RGB vector
%
%   rgb = hex2rgb(hex) converts a hexadecimal RGB colour string into the
%   equivalent MATLAB RGB vector with each element in the range 0.0 to 1.0.
%   The input can either be a 3-char (4 bits per channel) or 6-character
%   (8 bits per channel) string.
%
%   Examples:
%   >> hex2rgb( 'ff7843' )

%   Copyright 2009 The MathWorks Inc
%   $Revision: 82 $    $Date: 2009-11-06 10:42:52 +0000 (Fri, 06 Nov 2009) $

error( nargchk( 1, 1, nargin ) );
if ~ischar( hex ) ...
        || ~ismember( numel( hex ), [3 6] ) ...
        || any( ~ismember( lower( hex ), '0123456789abcdef' ) )
    error( 'MATLAB:HEX2RGB:BadHexColour', 'Hex colour must be a 3- or 6-character string' );
end

rgb = nan(1,3);
if numel( hex )==3
    for ii=1:numel( rgb )
        rgb(ii) = hex2dec( hex(ii) ) / 15;
        
    end
else
    for ii=1:numel( rgb )
        rgb(ii) = hex2dec( hex((ii-1)*2 + (1:2)) ) / 255;
    end
end