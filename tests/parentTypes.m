function types = parentTypes()
%PARENTTYPES Return a structure of the possible graphics parent types for
%GUI Layout Toolbox components. This is used a class setup parameter across
%multiple test classes.

types = struct( 'JavaFigure', 'legacy', ...
            'WebFigure', 'web', ...
            'Unrooted', 'unrooted' );

end % parentTypes