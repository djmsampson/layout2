function checkerboard( p )

% Autoparent
if nargin == 0
    p = gcf;
end

% Create
g = uix.Grid( 'Parent', p, 'Padding', 10 );
for ii = 1:4
    for jj = 1:4
        uicontrol( 'Parent', g );
        uicontrol( 'Parent', g, 'Visible', 'off' );
    end
    for jj = 1:4
        uicontrol( 'Parent', g, 'Visible', 'off' );
        uicontrol( 'Parent', g );
    end
end
g.Heights = -ones( [8 1] );

end