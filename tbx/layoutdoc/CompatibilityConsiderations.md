# Compatibility Considerations

## MATLAB&reg; Version Support

This is version 2 of GUI Layout Toolbox, which works with MATLAB versions from R2014b.  Version 1 supports MATLAB versions prior to R2014b.

## Version 1 Compatibility

When upgrading from version 1, there are a number of compatibility considerations.

### `uiextras` namespace

Version 1 classes were contained in the namespace `uiextras`. Version 2 classes are contained in the namespace `uix`. In version 2, a namespace `uiextras` is included to provide support for legacy code. Classes in `uiextras` extend the corresponding classes in `uix`, and contain only compatibility-related code.

### `Contents` property

The contents of version 1 objects were accessible via the property `Children`. The contents of version 2 objects are accessible via the property `Contents`. Version 2 objects also provide a property `Children`, but this controls the vertical stacking order rather than the layout order. Legacy code that accesses `Children` will run without error, but will not achieve the desired change in layout order, and should be modified to access `Contents` instead.

An upcoming release of version 1 will include support for code that references contents via `Contents`. That way, code modified to work in version 2 will also work in version 1.

The background to this change is as follows. Version 1 classes were wrappers for built-in graphics classes, and presented contents in layout order via the property `Children`. Version 2 objects extend built-in graphics objects, and as such, inherit properties, methods, and events. One such property is `Children`, which is used to control the top-to-bottom stacking order. MATLAB stacking rules, e.g., controls are always on top of axes, mean that some reasonable layout orders may be invalid stacking orders, so a new property for layout order is required.

Another difference between `Children` and `Contents` relates to the `HandleVisibility` of the graphics objects placed in a layout. The `Children` property does not include graphics objects with `HandleVisibility` set to `'off'`. However, the `Contents` property includes all graphics objects placed in the layout, including those with `HandleVisibility` set to `'off'`. This difference ensures that users are able to specify the layout of all child elements placed in a layout.

### Autoparenting

The new MATLAB graphics system introduces unparented objects, i.e., those with property `Parent` empty. The new system also introduces a separation between formal class constructors, e.g., `matlab.ui.container.Panel`, and informal construction functions, e.g., `uipanel`. Construction functions are autoparenting, i.e., if `Parent` is not specified then it is set to [`gcf`](https://www.mathworks.com/help/matlab/ref/gcf.html), whereas class constructors return objects with `Parent` empty unless explicitly specified. Version 2 presents a formal interface of class constructors which follow this new convention.

Classes in `uiextras` are autoparenting, so the behavior of legacy code is unchanged. However, best practice is to specify the parent explicitly during construction.

### Defaults mechanism

Version 1 provided a defaults mechanism (`uiextras.get`, `uiextras.set`, and `uiextras.unset`) that mimicked [`get`](https://www.mathworks.com/help/matlab/ref/get.html) and [`set`](https://www.mathworks.com/help/matlab/ref/set.html) in the MATLAB graphics system. This feature has been removed from version 2. Users should use an alternative programming pattern, e.g., a factory function, to create objects with standard settings.

### Enable and disable

Version 1 provided a mechanism to enable and disable container contents using the property `Enable`. This feature has been removed from version 2. Users should enable and disable controls directly rather than via containers. For more commentary, see [this article](https://stackoverflow.com/questions/305527/how-to-disable-a-container-and-its-children-in-swing).

### Other property name changes

A number of property names have changed to achieve greater consistency across the namespace. For example, `RowSizes` and `ColumnSizes` in `uiextras.Grid` are now `Heights` and `Widths` in `uix.Grid`. The namespace `uiextras` provides support for legacy property names.

| `uiextras` | `uix` |
| :-- | :-- |
| `RowSizes` | `Heights` |
| `ColumnSizes` | `Widths` |
| `ShowMarkings` | `DividerMarkings`  |

### Property shape changes

Version 2 contents companion properties are now of the same size as `Contents`, i.e., column vectors. In version 1, these properties were row vectors. The namespace `uiextras` provides support for legacy property values.

### Tab selection behavior

In version 1, after adding a tab to a tab panel, the new tab is selected.

In version 2, the original selection is preserved, except if the tab panel was empty, in which case the new tab is selected. This is consistent with the behavior of [`uitabgroup`](https://www.mathworks.com/help/matlab/ref/uitabgroup.html).

## `uifigure` Support

`uifigure` and its JavaScript graphics system was introducted in MATLAB R2016a, alongside `figure` and its Java graphics system.  As the JavaScript graphics system has matured, it has been possible to support more layouts:

| Layout | R2020b | R2021a,b | R2022a... |
| :--- | :---: | :---: | :---: |
| `uix.HBox` | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `uix.VBox` | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `uix.HButtonBox` | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `uix.VButtonBox` | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `uix.Grid` | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `uix.Empty` | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `uix.Panel` | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `uix.CardPanel` | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `uix.TabPanel` | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `uix.HBoxFlex` | | :white_check_mark: | :white_check_mark: |
| `uix.VBoxFlex` | | :white_check_mark: | :white_check_mark: |
| `uix.GridFlex` | | :white_check_mark: | :white_check_mark: |
| `uix.BoxPanel` | | | :white_check_mark: |
| `uix.ScrollingPanel` | | | :white_check_mark: |

Draggable dividers require `uicontainer` callback `ButtonDownFcn`, which is supported from R2021a.  `uix.ScrollingPanel` and `uix.BoxPanel` require `uicontrol`, which is supported from R2022a.

### Usage

To use GUI Layout Toolbox with JavaScript graphics, the `AutoResizeChildren` property of any ancestor [`uifigure`](https://www.mathworks.com/help/matlab/ref/uifigure.html), [`uipanel`](https://www.mathworks.com/help/matlab/ref/uipanel.html), or [`uitab`](https://www.mathworks.com/help/matlab/ref/uitab.html) must be set to `off`; otherwise, the layouts will not resize as expected.

For example, to create a flexible grid in a `uifigure`:

```matlab
f = uifigure( "AutoResizeChildren", "off" );
g = uix.GridFlex( "Parent", f, "Padding", 5 );
uilistbox( g, "Items", ["Red", "Green", "Blue"] );
uibutton( g, "Text", "Button", "BackgroundColor", "m" );
uitable( g, "Data", magic(3) );
uilabel( g, "Text", "Label", "HorizontalAlignment", "center" );
g.Widths = [-1, -1];
```

To create a card panel in a `uipanel`:

```matlab
f = uifigure( "AutoResizeChildren", "off" );
p = uipanel( "Parent", f, ...
    "Title", "Card Panel", ...
    "Units", "normalized", ...
    "Position", [0.25, 0.25, 0.50, 0.50], ...
    "AutoResizeChildren", "off" );
cp = uix.CardPanel( "Parent", p, "Padding", 5 );
uibutton( cp, "Text", "Button 1" );
uibutton( cp, "Text", "Button 2" );
```

### :warning: Known Issues

In R2022b, a MATLAB bug exists whereby the default `Position` of `[0 0 1 1]` is not honored during construction of `uix.Panel` and `uix.BoxPanel` objects.  Instead, the layouts are drawn incorrectly in the default `uipanel` position, until the `Position` is changed.  To work around this bug, set `Position` to a different value before the required value:

```matlab
f = uifigure( "AutoResizeChildren", "off" );
p = uix.Panel( "Parent", f, "Position", [0 0 0.5 0.5], "Position", [0 0 1 1] ); 
```

This bug was fixed in R2023a.  It recurred in R2023b for *all* GUI Layout Toolbox layouts.  It was fixed in R2024a for all layouts *except* `uix.Panel` and `uix.BoxPanel`.  It was fixed completely in R2024b.

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024