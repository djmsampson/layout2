# Responding to User Interaction

Finally, let's have a look at how one of the callbacks (`onListSelection`) works. This is the function that is called when an item is selected in the listbox. The other callbacks follow the same pattern.

A core principle of modular application development is that a callback should not update any part of the user interface directly. Instead, its job is to respond to user interaction by changing the `data` structure. In this example, each example changes the underlying data structure then asks the interface to refresh. This might mean that elements in the interface are updated when it is not necessary, but it ensures that the callbacks remain simple and that all interface update logic is one place. Extending this to more granular interface updates is straightforward. See [Scalability](Scalability.md) for more details.

For the listbox callback, the `src` argument is a handle to the listbox and we simply need to update the `SelectedExample` field of the `data` structure to reflect the new selection. We then ask the rest of the interface to update in response to the change.

```matlab
% User selected an example from the list - update "data" and refresh
data.SelectedExample = get( src, 'Value' );
updateInterface()
redrawExample() 
```
![The interface after being updated](Images/UpdateInterface01.png "The interface after being updated")

The complete source code for this application is available in `galleryBrowser.m`.

```matlab
edit galleryBrowser 
```

## Related Topics

* [Application Structure](ApplicationStructure.md)
* [Creating the User Interface](CreateInterface.md) 
* [Updating the User Interface](UpdateInterface.md)
* [Launching the Application](RunningIt.md)
* [Scalability and Architecture](Scalability.md)

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2009-2024