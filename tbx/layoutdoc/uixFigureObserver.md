# :telescope: uix.FigureObserver

Detect when the figure ancestor of a graphics object changes

*This is a helper class to support developers using figure-level services such as mouse events.*

## Syntax

`o = uix.FigureObserver(s)` creates a new observer for the figure ancestor of the graphics object `s`.

## Properties

| Name | Description | Type |
| --- | --- | --- |
| `Subject` | Graphics object whose figure ancestor is observed | Scalar graphics object; must have the `Parent` property |
| `Figure` | Figure ancestor of the subject | Scalar `figure` object (class `matlab.ui.Figure`), or empty graphics placeholder (class `matlab.graphics.GraphicsPlaceholder`) |

These properties are read-only.

## Events

A `FigureChanged` event is raised when a subject's figure ancestor changes. The associated event data is of type `uix.FigureData`, with properties:

* `OldFigure`: the previous figure ancestor of the subject
* `NewFigure`: the current figure ancestor of the subject

Either property may be an empty graphics placeholder, `[]`, indicating that the subject is *unrooted*, or disconnected from the root of the graphics tree. `OldFigure` is `[]` when the subject is transitioning from unrooted to rooted. `NewFigure` is `[]` when the subject transitions from rooted to unrooted.

## Examples

### Create a figure observer for an axes

Create an axes.
```matlab
ax = axes();
```

Create a figure observer for the axes.
```matlab
fo = uix.FigureObserver( ax );
```

Create a listener for the event `FigureChanged`.
```matlab
li = listener( fo, 'FigureChanged', @( ~, ~ ) disp( 'Figure ancestor changed!' ) );
```

Unroot the axes.
```matlab
ax.Parent = [];
```

We observe that the listener callback is executed.

### Create a figure observer for a box panel

The following example shows how to respond to the `Theme` property of a box panel's figure ancestor. The source code for this example is available in `observerExample.m`.

Create an unrooted box panel.
```matlab
bp = uix.BoxPanel( 'Parent', [], ...
    'Units', 'normalized', ...
    'Position', [0.25, 0.25, 0.50, 0.50], ...
    'DeleteFcn', @onBoxPanelDeleted ); 
```

Add a label.
```matlab
lb = uilabel( 'Parent', bp, ...
    'HorizontalAlignment', 'center', ...
    'Text', '' ); 
```

Create a figure observer for the box panel.
```matlab
fo = uix.FigureObserver( bp ); 
```

Create a listener for the `FigureChanged` event.
```matlab
figureChangedListener = listener( fo, 'FigureChanged', @onFigureChanged ); 
```

Ensure that the listener persists.
```matlab
setappdata( bp, 'FigureChangedListener', figureChangedListener ) 
```

Initialize a listener for the figure ancestor `ThemeChanged` event.
```matlab
themeChangedListener = event.listener.empty( 0, 1 ); 
```

When the figure ancestor of the box panel changes, we renew the theme listener.
```matlab
function onFigureChanged( ~, e )

    % Renew the theme changed listener.
    newFigure = e.NewFigure;
    if ~isempty( newFigure )
        themeChangedListener = listener( newFigure, ...
        'ThemeChanged', @onThemeChanged );
        setappdata( bp, 'ThemeChangedListener', themeChangedListener )
        onThemeChanged( newFigure )
    end % if

end % onFigureChanged 
```

When the theme changes, we update the label text.
```matlab
function onThemeChanged( s, ~ )

    if ~isempty( s.Theme )
        lb.Text = s.Theme.Name;
    else
        lb.Text = 'No theme detected.';
    end % if

end % onThemeChanged 
```

Next, create two figures with different themes.
```matlab
f1 = uifigure( 'AutoResizeChildren', 'off', 'Theme', 'light' );
f2 = uifigure( 'AutoResizeChildren', 'off', 'Theme', 'dark' ); 
```

Call the `observerExample` function to create the box panel.
```matlab
bp = observerExample(); 
```

Parent the box panel to the first figure.
```matlab
bp.Parent = f1; 
```

Parent the box panel to the second figure.
```matlab
bp.Parent = f2; 
```

Change the theme of the second figure.
```matlab
f2.Theme = 'light'; 
```

In each case we note that the label text responds dynamically.

## Related Topics

* :black_square_button: [`uix.BoxPanel`](uixBoxPanel.md): Arrange a single element in a panel with boxed title and optional toolbar controls
* [`uilabel`](https://www.mathworks.com/help/matlab/ref/uilabel.html)

___

[home](index.md) :house: | [`CardPanel`](uixCardPanel.md) :card_index: | [`BoxPanel`](uixBoxPanel.md) :black_square_button: | [`TabPanel`](uixTabPanel.md) :point_right: | [`ScrollingPanel`](uixScrollingPanel.md) :scroll: | [`HBox`](uixHBox.md) :arrow_right: | [`VBox`](uixVBox.md) :arrow_down: | [`Grid`](uixGrid.md) :symbols: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024