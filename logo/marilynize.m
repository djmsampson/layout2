function cdata = marilynize( foreground, background )

mode = class( foreground );
switch mode
    case 'double'
        dForeground = foreground;
        dBackground = background;
    case 'uint8'
        dForeground = double( foreground ) / 255;
        dBackground = double( background ) / 255;
    otherwise
        error( 'uix:InvalidArgument', ...
            'Input must be of type double or uint8.' )
end

d = fileparts( mfilename( 'fullpath' ) );
x = imread( fullfile( d, 'bw.png' ) );
x = double( x );
mi = min( x(:) );
ma = max( x(:) );
for ii = 1:3
    layers{ii} = interp1( [mi ma], [dForeground(ii) dBackground(ii)], x ); %#ok<AGROW>
end
dCdata = cat( 3, layers{:} );

switch mode
    case 'double'
        cdata = dCdata;
    case 'uint8'
        cdata = uint8( dCdata * 255 );
end

end