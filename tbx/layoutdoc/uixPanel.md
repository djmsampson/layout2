# `uix.Panel`

![Panel](Images/bigicon_Panel.png "Panel")

Arrange a single element inside a standard panel

## Syntax

* `p = uix.Panel()` creates a standard [**`uipanel`**](https://www.mathworks.com/help/matlab/ref/uipanel.html) object, with automatic management of the contained control or layout. The available properties are largely the same as the standard [**`uipanel`**](https://www.mathworks.com/help/matlab/ref/uipanel.html) object.

* `p = uix.Panel( <propertyName>, <propertyValue> ... )` also sets one or more property values.

## `uix.Panel` Properties



## Examples

### Add a button to a panel

```matlab
f = figure();
p = uix.Panel( 'Parent', f, 'Title', 'A Panel', 'Padding', 5 );
uicontrol( 'Parent', p, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
```

### Add a listbox and a button to a [horizontal layout](uixHBox.md) inside a panel

```matlab
f = figure();
p = uix.Panel( 'Parent', f, 'Title', 'A Panel', 'TitlePosition', 'centertop' );
hb = uix.HBox( 'Parent', p, 'Spacing', 5, 'Padding', 5 );
uicontrol( 'Parent', hb, 'Style', 'listbox', 'String', {'Item 1', 'Item 2'} )
uicontrol( 'Parent', hb, 'BackgroundColor', 'b' )
hb.Widths = [100, -1];
```

### Add a table to a panel in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
p = uix.Panel( "Parent", f, "Title", "A Panel", "Units", "normalized", "Position", [0.05, 0.05, 0.90, 0.90] );
uitable( p, "Data", magic( 5 ) );
```

## Compatibility
In version 2.3.9, the `Selection` property no longer has any effect. In previous versions, the currently visible child of the `uix.Panel` object was determined using the `Selection` property.

## See also
* [`uix.CardPanel`](uixCardPanel.md): Show one element (card) from a list
* [`uix.BoxPanel`](uixBoxPanel.md): Arrange a single element in a panel with boxed title and optional toolbar controls
* [`uixTabPanel`](uixTabPanel.md): Arrange elements in a panel with tabs for selecting which element is visible
* [`uix.ScrollingPanel`](uixScrollingPanel.md): Arrange a single element inside a scrollable panel