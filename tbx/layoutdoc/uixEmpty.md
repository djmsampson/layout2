# `uix.Empty`

Create an empty space

## Syntax

* `e = uix.Empty()` creates an empty space object that can be used in layouts to add gaps between other elements. The empty space is achieved using a container that monitors its parent's color and changes its own to match.
* `e = uix.Empty( <propertyName>, <propertyValue>, ... )` also sets one or more property values.

## `uix.Empty` Properties




## Limitations
* It is not possible to monitor the `Color` or `BackgroundColor` properties for every graphics object, since some objects have the `SetObservable` attribute of these properties set to `false`. In these cases, it is necessary to set the `BackgroundColor` of the empty space object directly. In particular, this applies to placing an empty space object in a [**`uigridlayout`**](https://www.mathworks.com/help/matlab/ref/uigridlayout.html) container. See the example below.

## Examples

### Create an empty space between two buttons

```matlab
f = figure();
hb = uix.HBox( 'Parent', f, 'Spacing', 5 );
uicontrol( 'Parent', hb, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
uix.Empty( 'Parent', hb )
uicontrol( 'Parent', hb, 'Style', 'pushbutton', 'BackgroundColor', 'g' )
```

### Create an empty space in a grid layout in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
g = uigridlayout( f, [1, 3], "BackgroundColor", "m" );
uibutton( g, "BackgroundColor", "r" );
e = uix.Empty( "Parent", g );
uibutton( g, "BackgroundColor", "g" );
```

Note that the empty space has the correct background color. Change the background color of the grid layout.

```matlab
g.BackgroundColor = "y";
```

Note that the empty space has not updated its background color (see the limitation above). Update the background color manually.

```matlab
e.BackgroundColor = g.BackgroundColor;
```

## See also
* [`uix.HBox`](uixHBox.md): Arrange elements horizontally in a single row
