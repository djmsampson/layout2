# `uix.BoxPanel`

![BoxPanel](Images/bigicon_BoxPanel.png "BoxPanel")

Arrange a single element in a panel with boxed title and optional toolbar controls

## Syntax
* `bp = uix.BoxPanel()` creates a box-styled panel object with automatic management of the contained control or layout. The available properties are largely the same as the standard [**`uipanel`**](https://www.mathworks.com/help/matlab/ref/uipanel.html) object.

* `bp = uix.BoxPanel( <propertyName>, <propertyValue> ... )` also sets one or more property values.

## `uix.BoxPanel` Properties


## Examples

### Add a button to a box panel

```matlab
f = figure();
bp = uix.BoxPanel( 'Parent', f, 'Title', 'A Box Panel', 'Padding', 5 );
uicontrol( 'Parent', bp, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
``` 

### Add a listbox and a button to a [horizontal layout](uixHBox.md) inside a box panel

```matlab
f = figure();
bp = uix.BoxPanel( 'Parent', f, 'Title', 'Box Panel', 'Padding', 5 );
hb = uix.HBox( 'Parent', bp, 'Spacing', 5, 'Padding', 5 );
uicontrol( 'Parent', hb, 'Style', 'listbox', 'String', {'Item 1', 'Item 2'} )
uicontrol( 'Parent', hb, 'BackgroundColor', 'b' )
h.Widths = [100, -1];
```

### Create a box panel with a help button on the title bar

```matlab
f = figure();
bp = uix.BoxPanel( 'Parent', f, 'Title', 'Box Panel with Help Button', ...
'HelpFcn', @(~, ~) doc( "sin" ) );
ax = axes( uicontainer( bp ) );
x = linspace( -2*pi, 2*pi, 500 );
y = sin( 3*x );
plot( ax, x, y, "LineWidth", 2, "DisplayName", "$y = \sin(x)$" )
legend( ax, "Interpreter", "latex" )
```

### Add a vertical button box to a box panel in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
bp = uix.BoxPanel( "Parent", f, "Title", "Box Panel with Button Box", ...
"Units", "normalized", "Position", [0.05, 0.05, 0.90, 0.90], ...
"FontSize", 16 );
vbb = uix.VButtonBox( "Parent", bp, "Spacing", 10, "ButtonSize", [100, 40] );
uibutton( vbb, "BackgroundColor", "r" );
uibutton( vbb, "BackgroundColor", "g" );
uibutton( vbb, "BackgroundColor", "b" );
```

## Compatibility
* In version 2.3.9, the `Selection` property no longer has any effect. In previous versions, the currently visible child of the `uix.BoxPanel` object was determined using the `Selection` property.
* In version 2.4, the `*TooltipString` properties were renamed to `*Tooltip` (e.g., `MinimizeTooltipString` is now `MinimizeTooltip`). This is for consistency with the behavior of `uicontrol` and web controls. Setting a `*TooltipString` property is still supported.

## See also
* [`uix.Panel`](uixPanel.md): Arrange a single element inside a standard panel
* [`uix.CardPanel`](uixCardPanel.md): Show one element (card) from a list
* [`uix.TabPanel`](uixTabPanel.md): Arrange elements in a panel with tabs for selecting which element is visible
* [`uix.ScrollingPanel`](uixScrollingPanel.md): Arrange a single element inside a scrollable panel