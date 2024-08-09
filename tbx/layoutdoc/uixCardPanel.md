# `uix.CardPanel`

![CardPanel](Images/bigicon_CardPanel.png "CardPanel")

Show one element (card) from a list

## Syntax

* `cp = uix.CardPanel()` creates a new card panel which allows selection between its different child objects. Changing the `Selection` property makes the corresponding element fill the space available in the card panel, and makes all the other children invisible. Card panels are commonly used for creating wizards or to allow switching between different views of a single dataset.

* `cp = uix.CardPanel( <propertyName>, <propertyValue> ... )` also sets one or more property values.

## `uix.CardPanel` Properties



## Examples

### Add multiple buttons to a card panel

```matlab
f = figure();
cp = uix.CardPanel( 'Parent', f, 'Padding', 5 );
uicontrol( 'Parent', cp, 'Style', 'pushbutton', 'BackgroundColor', 'r', ...
'String', 'Button 1', 'ForegroundColor', 'w', 'FontSize', 40 )
uicontrol( 'Parent', cp, 'Style', 'pushbutton', 'BackgroundColor', 'g', ...
'String', 'Button 2', 'ForegroundColor', 'w', 'FontSize', 40 )
uicontrol( 'Parent', cp, 'Style', 'pushbutton', 'BackgroundColor', 'b', ...
'String', 'Button 3', 'ForegroundColor', 'w', 'FontSize', 40 )
cp.Selection = 2;
```

### Add multiple axes to a card panel in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
cp = uix.CardPanel( "Parent", f );

ax = axes( uicontainer( cp ) );
plot( ax, cumsum( randn( 100, 1 ) ) )
title( ax, "Axes 1" )

ax = axes( uicontainer( cp ) );
plot( ax, cumsum( randn( 100, 1 ) ) )
title( ax, "Axes 2" )
```
Change the selection.
```matlab
cp.Selection = 1;
```

## See also

* [`uix.Panel`](uixPanel.md): Arrange a single element inside a standard panel
* [`uix.BoxPanel`](uixBoxPanel.md): Arrange a single element in a panel with boxed title and optional toolbar controls
* [`uix.TabPanel`](uixTabPanel.md): Arrange elements in a panel with tabs for selecting which element is visible
* [`uix.ScrollingPanel`](uixScrollingPanel.md): Arrange a single element inside a scrollable panel