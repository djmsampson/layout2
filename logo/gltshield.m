function cdata = gltshield()

padding = 8;
background = uint8( [0 255 0] );
border = uint8( [255 255 255] );
cdata = i_image( padding, border );
mask = i_mask();
for ii = 1:size( cdata, 3 )
    layer = cdata(:,:,ii);
    layer(mask==2) = background(ii);
    layer(mask==1) = border(ii);
    cdata(:,:,ii) = layer;
end

end

function cdata = i_image( pa, border )

orange = uint8( [203 96 21] ); % orange
blue = uint8( [0 169 224] ); % light blue
mask = i_mask();
[hi, wi] = size( mask );
cdata = zeros( [hi wi 3], 'like', orange );
for ii = 1:size( cdata, 3 )
    cdata(hi/2+(-pa/2:pa/2),:,ii) = border(ii);
    cdata(:,wi/2+(-pa/2:pa/2),ii) = border(ii);
end
cdata(1:(hi/2-pa/2),1:(wi/2-pa/2),:) = block( orange, ([hi wi]-pa)/2 );
cdata((hi/2+pa/2+1):end,1:(wi/2-pa/2),:) = block( blue, ([hi wi]-pa)/2 );
cdata(1:(hi/2-pa/2),(wi/2+pa/2+1):end,:) = block( blue, ([hi wi]-pa)/2 );
cdata((hi/2+pa/2+1):end,(wi/2+pa/2+1):end,:) = block( orange, ([hi wi]-pa)/2 );
logo = marilynize( orange, blue );
ogol = marilynize( blue, orange );
[hl, wl, ~] = size( logo );
cdata(1+hi/2-pa/2-hl:hi/2-pa/2,1+wi/2-pa/2-wl:wi/2-pa/2,:) = logo;
cdata(1+hi/2+pa/2:hi/2+pa/2+hl,1+wi/2-pa/2-wl:wi/2-pa/2,:) = ogol;
cdata(1+hi/2-pa/2-hl:hi/2-pa/2,1+wi/2+pa/2:wi/2+pa/2+wl,:) = ogol;
cdata(1+hi/2+pa/2:hi/2+pa/2+hl,1+wi/2+pa/2:wi/2+pa/2+wl,:) = logo;

end

function c = i_mask()

d = fileparts( mfilename( 'fullpath' ) );
s = imread( fullfile( d, 'shield.jpg' ) );
s = imresize( s, 0.8 );
c = double( rgb2ind( s, 2 ) == 0 ); % outline 1, other 0
for ii = 1:size( c, 1 )
    fi = find( c(ii,:) == 1, 1, 'first' );
    la = find( c(ii,:) == 1, 1, 'last' );
    if isempty( fi )
        fi = 0;
        la = 0;
    end
    c(ii,1:fi-1) = 2; % background 2
    c(ii,la+1:end) = 2; % background 2
end
for jj = 1:size( c, 2 )
    fi = find( c(:,jj) == 1, 1, 'first' );
    la = find( c(:,jj) == 1, 1, 'last' );
    if isempty( fi )
        fi = 0;
        la = 0;
    end
    c(1:fi-1,jj) = 2; % background 2
    c(la+1:end,jj) = 2; % background 2
end

end

function cdata = block( c, s )

cdata = zeros( [s 3], 'like', c );
cdata(:,:,1) = c(1);
cdata(:,:,2) = c(2);
cdata(:,:,3) = c(3);

end