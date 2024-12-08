# :point_right: uix.TabPanel

Arrange elements in a panel with tabs for selecting which element is visible

## Syntax

* `tp = uix.TabPanel()` creates a new, default, *unparented* panel with tabs along one edge to allow selection between the different child elements contained in the panel.
* `tp = uix.TabPanel( n1, v1, n2, v2, ... )` also sets one or more property values.

## Properties

| Name | Description | Type |
| --- | --- | --- |
| `BackgroundColor` | Background color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `Contents` | Children, in order of addition to the layout, regardless of `HandleVisibility`; settable only to a permutation of itself | graphics vector |
| `ForegroundColor` | Tab title font color | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) |
| `Padding` | Space around contents, in pixels | nonnegative scalar integer |
| `Parent` | Parent figure or container | figure, panel, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#mw_e4809363-1f35-4bc7-89f8-36ed9cccb017) |
| `Position` | Position within parent figure or container, in `Units` | `[left, bottom, width, height]` |
| `Selection` | Index of the visible tab (and child) | nonnegative scalar integer |
| `SelectionChangedFcn` | Function to call when the selected tab is changed; the event data supplied with this callback has properties `OldValue` and `NewValue` giving the indices of the previously selected and newly selected tabs | [`function_handle`](https://www.mathworks.com/help/matlab/ref/function_handle.html) |
| `TabContextMenus` | The context menus (or `[]`) for each tab | `cell` array of context menus or empty values (`[]`) |
| `TabEnables` | A list of the enabled state of each tab (default is all `"on"`) | `cell` array of `'on'` \| `'off'` or string array of `"on"` \| `"off"` |
| `TabTitles` | A list of the tab titles with one element per tab | `cell` array of character vectors, or `string` array |
| `Units` | Position units; default is `"normalized"` | `"normalized"`, `"pixels"`, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#bub8wap-1_sep_shared-Position) |
| `Visible` | Visibility; default is `"on"` | `"on"` or `"off"` |

plus other [container properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`

### :warning: Deprecated
| Name | Alternative | Type | Notes |
| --- | --- | --- | --- |
| `FontAngle` | none | `"normal"` \| `"italic"` | Now `normal`, as per `uitab`; decorative properties of the tab titles no longer have any effect; this is due to a change in the underlying implementation, which now uses [`uitabgroup`](https://www.mathworks.com/help/matlab/ref/uitabgroup.html) and [`uitab`](https://www.mathworks.com/help/matlab/ref/uitab.html) to create the tab group and tabs |
| `FontName` | none | `string` scalar (e.g., `"Arial"`, `"Helvetica"`, etc) | As above: now `MS Sans Serif` |
| `FontSize` | none | positive scalar integer | As above; not supportable in a `uitab`-backed implementation |
| `FontUnits` | none | `"inches"` \| `"centimeters"` \| `"normalized"` \| `"points"` \| `"pixels"` | As above; not supportable in a `uitab`-backed implementation |
| `FontWeight` | none | `"normal"` \| `"bold"` | As above; not supportable in a `uitab`-backed implementation |
| `HighlightColor` | none | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) | As above; not a property of `uitabgroup` |
| `ShadowColor` | none | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) | As above; not a property of `uitabgroup` |
| `TabWidth` | none | positive scalar integer | As above; not a property of `uitabgroup` or `uitab` |

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
This example shows how to use tabs within a layout. It also shows how to use the `SelectionChangedFcn` callback property of the `uix.TabPanel` layout to update other user-interface elements when the visible tab is changed. The code for this example is available in `tabPanelExample.m`.

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