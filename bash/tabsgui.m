function tabsgui( p )

% Autoparent
if nargin == 0
    p = gcf;
end

% Create
t = uix.TabPanel( 'Parent', p, ...
    'TabWidth', 100, 'TabLocation', 'bottom', ...
    'FontSize', 14, 'FontAngle', 'italic', ...
    'SelectionChangedCallback', @onSelectionChanged );
checkerboard( t )
boxes( t )
peaksgui( t )
t.TabTitles = {'Checkers';'Boxes';'Peaks'};
t.Selection = 3;

    function onSelectionChanged( ~, e )
        
        fprintf( 1, 'Changed selection from %d to %d.\n', ...
            e.OldValue, e.NewValue );
        
    end

end