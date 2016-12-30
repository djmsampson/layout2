function c = marilynize( f, b )

x = imread( 'bw.png' );
x = double( x );
mi = min( x(:) );
ma = max( x(:) );
for ii = 1:3
    la{ii} = interp1( [mi ma], [f(ii) b(ii)], x ); %#ok<AGROW>
end
c = cat( 3, la{:} );

end