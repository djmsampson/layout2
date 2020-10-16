function peaksgui( p )

% Autoparent
if nargin == 0
    p = gcf;
end

% Create
v = uix.VBox( 'Parent', p );
h = uix.HBox( 'Parent', v, 'Padding', 5, 'Spacing', 5 );
uicontrol( 'Parent', h, 'Style', 'listbox', 'String', {'David';'Kirsty';'Paul';'Amy'} );
axes( 'Parent', h )
peaks % into gca
uicontrol( 'Parent', v, 'Style', 'edit', 'String', 'Are you enjoying the bash?', 'Enable', 'inactive' );
h.Widths = [100;-1];
v.Heights = [-1;50];

end