function boxes( p )

% Autoparent
if nargin == 0
    p = gcf;
end

% Create
h = uix.HBox( 'Parent', p, 'Padding', 10, 'Spacing', 10 );
uicontrol( 'Parent', h, 'String', 'Twice as wide' );
uicontrol( 'Parent', h, 'String', 'as this' );
uicontrol( 'Parent', h, 'String', '100 wide' );
v = uix.VBoxFlex( 'Parent', h, 'Spacing', 10 );
uicontrol( 'Parent', v, 'String', 'Push me!' );
uicontrol( 'Parent', v, 'String', 'Push me!' );
h.Widths = [-2;-1;100;-1];
v.Heights = [-1;-2];

end