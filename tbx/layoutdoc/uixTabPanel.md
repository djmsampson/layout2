# :point_right: uix.TabPanel

Arrange elements in a tabbed panel

## Syntax

`p = uix.TabPanel()` creates a new, default, *unparented* panel with tabs along one edge to allow selection between the different child elements contained in the panel.

`p = uix.TabPanel(n1,v1,n2,v2,...)` also sets one or more property values.

## Properties

| Name | Description | Type / Values |
| --- | --- | --- |
| `BackgroundColor` | Background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `Contents` | Children, in tab order, regardless of `HandleVisibility`; settable only to a permutation of itself | graphics vector |
| `ForegroundColor` | Tab title font color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `Padding` | Space around content, in pixels | nonnegative double |
| `Parent` | Parent figure or container | [figure, panel, etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel.html?#mw_8db64fed-c01a-48e8-8182-edc1cbc2ac86) |
| `Position` | Position `[left bottom width height]` within parent figure or container, in `Units` | double 1x4 |
| `Selection` | Index of the visible tab (and child); between 1 and the number of tabs | nonnegative integer |
| `SelectionChangedFcn` | Function to call when the selected tab is changed; the event data has properties `OldValue` and `NewValue` denoting the old and new `Selection` | [function handle](https://www.mathworks.com/help/matlab/ref/function_handle.html) |
| `TabContextMenus` | Context menus (or [placeholders](https://www.mathworks.com/help/matlab/ref/matlab.graphics.graphicsplaceholder-class.html)) for each tab | { context menus } |
| `TabEnables` | Enabled state for each tab | { **`'on'`**\|`'off'` } |
| `TabTitles` | Title for each tab | { strings } |
| `Units` | Position units | [**`'normalized'`**\|`'pixels'`\|etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel.html?#bub8wap-1_sep_mw_fcd6f5ca-13f2-41e8-9760-965b092c4093) |
| `Visible` | Visibility | **`'on'`**\|`'off'` |

plus other [container properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`

### :warning: Deprecated

| Name | Alternative | Type | Notes |
| --- | --- | --- | --- |
| `FontAngle` | none | `'normal'`\|`'italic'` | Now `normal`, as per `uitab`; decorative properties of the tab titles no longer have any effect; this is due to a change in the underlying implementation, which now uses [`uitabgroup`](https://www.mathworks.com/help/matlab/ref/uitabgroup.html) and [`uitab`](https://www.mathworks.com/help/matlab/ref/uitab.html) to create the tab group and tabs |
| `FontName` | none | `string` (e.g., `'Arial'`, `'Helvetica'`, etc) | As above: now `MS Sans Serif` |
| `FontSize` | none | positive integer | As above; not supportable in a `uitab`-backed implementation |
| `FontUnits` | none | `'inches'`\|`'centimeters'`\|`'normalized'`\|`'points'`\|`'pixels'` | As above; not supportable in a `uitab`-backed implementation |
| `FontWeight` | none | `'normal'`\|`'bold'` | As above; not supportable in a `uitab`-backed implementation |
| `HighlightColor` | none | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) | As above; not a property of `uitabgroup` |
| `ShadowColor` | none | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) | As above; not a property of `uitabgroup` |
| `TabWidth` | none | positive integer | As above; not a property of `uitabgroup` or `uitab` |

## Examples

### Add three buttons to a tab panel

```matlab
f = figure();
tp = uix.TabPanel( 'Parent', f, 'Padding', 5 );
uicontrol( 'Parent', tp, 'Style', 'pushbutton', 'BackgroundColor', 'r' )
uicontrol( 'Parent', tp, 'Style', 'pushbutton', 'BackgroundColor', 'b' )
uicontrol( 'Parent', tp, 'Style', 'pushbutton', 'BackgroundColor', 'g' )
tp.TabTitles = {'Red', 'Blue', 'Green'};
tp.Selection = 2;
```

### Add controls to a tab panel in web graphics

```matlab
f = uifigure( "AutoResizeChildren", "off" );
tp = uix.TabPanel( "Parent", f, "TabLocation", "left" );
uibutton( tp, "BackgroundColor", "m" );
uilistbox( tp );
uitable( tp, "Data", magic( 5 ) );
```

Disable the second tab. Select the third.
```matlab
tp.TabEnables{2} = 'off';
tp.Selection = 3;
```

### Create a simple app with a tab panel and synchronized callbacks

This example shows how to use tabs within a layout. It also shows how to use the `SelectionChangedFcn` callback property of the `uix.TabPanel` layout to update other user interface elements when the visible tab is changed. The code for this example is available in `tabPanelExample.m`.

```matlab
edit tabPanelExample 
```

Create a new figure window and remove the toolbar and menus.

```matlab
f = figure( 'Name', 'Tab Panel Example', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'NumberTitle', 'off' ); 
```

Next, we define the application layout. The layout involves two panels side by side. This is done using a flexible horizontal box. The left-hand side is filled with a standard panel and the right-hand side with a tab panel.

```matlab
hbf = uix.HBoxFlex( 'Parent', f, ...
    'Spacing', 10 );
p = uix.Panel( 'Parent', hbf, ...
    'Padding', 5, ...
    'Title', 'List Box Control' );
tp = uix.TabPanel( 'Parent', hbf, ...
    'Padding', 0 ); 
```

Add a listbox on the left. Note that we link the listbox callback to the tab selection, and the tab panel selection changed callback to the listbox such that they are kept in sync.

```matlab
lb = uicontrol( 'Parent', p, ...
    'Style', 'listbox', ...
    'String', {'List Item 1', 'List Item 2', 'List Item 3'}, ...    
    'Callback', @(s, ~) set( tp, 'Selection', s.Value ) );
tp.SelectionChangedFcn = @(~, e) set( lb, 'Value', e.NewValue ); 
```

Add the tab contents. We fill each tab with a panel containing a numbered button.
```matlab
p1 = uix.Panel( 'Parent', tp, ...
    'Padding', 5, ...
    'Title', 'Panel 1' );
uicontrol( 'Parent', p1, ...
    'Style', 'pushbutton', ...
    'String', 'Button 1', ...
    'FontSize', 25, ...
    'FontWeight', 'bold' )
p2 = uix.Panel( 'Parent', tp, ...
    'Padding', 5, ...
    'Title', 'Panel 2' );
uicontrol( 'Parent', p2, ...
    'Style', 'pushbutton', ...
    'String', 'Button 2', ...
    'FontSize', 25, ...
    'FontWeight', 'bold' )
p3 = uix.Panel( 'Parent', tp, ...
    'Padding', 5, ...
    'Title', 'Panel 3' );
uicontrol( 'Parent', p3, ...
    'Style', 'pushbutton', ...
    'String', 'Button 3', ...
    'FontSize', 25, ...
    'FontWeight', 'bold' ) 
```

Update the tab titles.
```matlab
tp.TabTitles = {'Tab 1', 'Tab 2', 'Tab 3'}; 
```

Run the example.

```matlab
tabPanelExample
```

## Related Topics

* :page_facing_up: [`uix.Panel`](uixPanel.md): Arrange a single element inside a standard panel
* :card_index: [`uix.CardPanel`](uixCardPanel.md): Show one element (card) from a list
* :black_square_button: [`uix.BoxPanel`](uixBoxPanel.md): Arrange a single element in a panel with boxed title and optional toolbar controls
* :scroll: [`uix.ScrollingPanel`](uixScrollingPanel.md): Arrange a single element inside a scrollable panel

___

[home](index.md) :house: | [`CardPanel`](uixCardPanel.md) :card_index: | [`BoxPanel`](uixBoxPanel.md) :black_square_button: | [`TabPanel`](uixTabPanel.md) :point_right: | [`ScrollingPanel`](uixScrollingPanel.md) :scroll: | [`HBox`](uixHBox.md) :arrow_right: | [`VBox`](uixVBox.md) :arrow_down: | [`Grid`](uixGrid.md) :symbols: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024