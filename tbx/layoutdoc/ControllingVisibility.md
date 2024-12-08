# Controlling Visibility

This example shows the effect of setting the `Visible` property on a layout object. The `Visible` property can be used to hide entire sections of a user interface or component. 

The code for this example is available in `visibleExample.m`.

## Setup

Create a new figure window and add a box panel.
```matlab
f = figure( 'Name', 'Visible Example', ...
    'MenuBar', 'none', ...
    'ToolBar', 'none', ...
    'NumberTitle', 'off' );
f.Position(3:4) = [300, 350];
panel = uix.BoxPanel( 'Parent', f, ...
    'Title', 'BoxPanel', ...
    'FontSize', 12 );
```

## Put some buttons inside the panel

First, create a vertical button box to hold the buttons.

```matlab
box = uix.VButtonBox( 'Parent', panel, 'ButtonSize', [80, 30] );
```

Place a selection of buttons with mixed visibilities inside the button box.

```matlab
uicontrol( 'Parent', box, 'Style', 'pushbutton', 'String', 'Button 1' )
uicontrol( 'Parent', box, 'Style', 'pushbutton', 'String', 'Button 2' )
uicontrol( 'Parent', box, 'Style', 'pushbutton', 'String', 'Button 3', ...
    'Visible', 'off' )
uicontrol( 'Parent', box, 'Style', 'pushbutton', 'String', 'Button 4' )
uicontrol( 'Parent', box, 'Style', 'pushbutton', 'String', 'Button 5', ...
    'Visible', 'off' )
uicontrol( 'Parent', box, 'Style', 'pushbutton', 'String', 'Button 6' )
```

## Toggle the visibility of the box panel
```matlab
panel.Visible = 'off';
```

## Restore the box panel visibility.

Note that the original `Visible` state of each button has been preserved.

```matlab
panel.Visible = 'on';
```

## Related Topics
* [Box panels](uixBoxPanel.md)
* [Vertical button boxes](uixVButtonBox.md)
* [`uicontrol`](https://www.mathworks.com/help/matlab/ref/uicontrol.html)