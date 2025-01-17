# Launching the Application

When the main function is launched (`galleryBrowser`) it first creates the data, then the app, then updates the app using the data. At this point the function exits and control is returned to the command prompt. Note, however, that the app is still onscreen and will still respond to user interaction.

This works because the shared variables in the main function are not cleared when the function exits. They are only cleared when the app is closed. This is a slightly unusual, but very useful, feature of using nested functions for building applications.

## Example - running the app

```matlab
galleryBrowser
```

The complete source code for this application is available in `galleryBrowser.m`.

```matlab
edit galleryBrowser 
```

## Related Topics

*  [Application Structure](ApplicationStructure.md)
*  [Creating the User Interface](CreateInterface.md) 
*  [Updating the User Interface](UpdateInterface.md)
*  [Responding to User Interaction](OnListSelection.md)
*  [Scalability and Architecture](Scalability.md)

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2025