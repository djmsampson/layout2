% Create a figure
f = figure();

% Create a container
b = uix.HBox( 'Parent', f, 'Padding', 10, 'Spacing', 10 );

% Create some content
b1 = uicontrol( 'Parent', b, 'String', 'The' );
a = axes( 'Parent', b, 'ActivePositionProperty', 'position', 'Visible', 'off' );
peaks() % membrane
a.Visible = 'off';
b2 = uicontrol( 'Parent', b, 'String', 'Math' );
b3 = uicontrol( 'Parent', b, 'String', 'Works' );

% Set sizes
b.Widths = [100 -2 -1 -1];