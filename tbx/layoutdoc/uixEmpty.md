# :no_entry_sign: uix.Empty

Create an empty space

## Syntax

* `e = uix.Empty()` creates a new, default, *unparented* empty space object that can be used in layouts to add gaps between other elements. The empty space is achieved using a container that monitors its parent's color and changes its own to match.
* `e = uix.Empty( n1, v1, n2, v2, ... )` also sets one or more property values.

## Properties

| Name | Description | Type |
| --- | --- | --- |
| `BackgroundColor` | Background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `Parent` | Parent figure or container | figure, panel, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#mw_e4809363-1f35-4bc7-89f8-36ed9cccb017) |
| `Position` | Position within parent figure or container, in `Units` | `[left, bottom, width, height]`  |
| `Units` | Position units; default is `"normalized"` | `"normalized"`, `"pixels"`, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#bub8wap-1_sep_shared-Position) |
| `Visible` | Visibility; default is `"on"` | `"on"` or `"off"` |

plus other [container properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`

## Limitations
* It is not possible to monitor the `Color` or `BackgroundColor` properties for every graphics object, since some objects have the `SetObservable` attribute of these properties set to `false`. In these cases, it is necessary to set the `BackgroundColor` of the empty space object directly. In particular, this applies to placing an empty space object in a [`uigridlayout`](https://www.mathworks.com/help/matlab/ref/uigridlayout.html) container. See the example below.

## Examples

### Create an empty space between two buttons

```matlab
f = figure();
hb = uix.HBox( 'Parent', f, 'Spacing', 5 );
uicontrol( 'Parent', hb, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
uix.Empty( 'Parent', hb );
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

## Related Topics
* :arrow_right: [`uix.HBox`](uixHBox.md): Arrange elements horizontally in a single row
