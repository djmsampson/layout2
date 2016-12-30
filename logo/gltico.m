function cdata = gltico

padding = 8;
background = uint8( 255 );
main = pane( padding, background );
blue = uint8( [0 75 135] );
cdata = block( blue, size( main, 2 ), 35 );
cdata(end+1:end+padding,:) = background;
cdata = cat( 1, cdata, main );

end

function cdata = pane( p, b )

orange = uint8( [215 136 37] ); % orange
membranes = grid( [2 2], p, b );
cdata = block( orange, 110, size( membranes, 1 ) );
cdata(:,end+1:end+p,:) = b;
cdata = cat( 2, cdata, membranes );

end

function cdata = block( c, w, h )

cdata = zeros( [h w], 'uint8' );
cdata(:,:,1) = c(1);
cdata(:,:,2) = c(2);
cdata(:,:,3) = c(3);

end

function cdata = grid( sz, p, b )

orange = [203 96 21]/255; % orange
blue = [0 169 224]/255; % light blue
cdata = zeros( [0 0], 'double' );
for rr = 1:sz(1)
    row = [];
    for cc = 1:sz(2)
        if rem( rr + cc, 2 )
            tile = marilynize( orange, blue );
        else
            tile = marilynize( blue, orange );
        end
        row = cat( 2, row, tile );
        if cc < sz(2)
            row(:,end+1:end+p,:) = double( b )/255;
        end
    end
    cdata = cat( 1, cdata, row );
    if rr < sz(1)
        cdata(end+1:end+p,:,:) = double( b )/255;
    end
end
cdata = uint8( cdata * 255 );

end