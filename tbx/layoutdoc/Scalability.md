# Scalability

As applications get bigger the code gets more complex. The simple application structure used here does not scale well to large applications. However, some small adjustments can make life much better.

* Convert the `data` structure into a [**`handle`**](https://www.mathworks.com/help/matlab/matlab_oop/comparing-handle-and-value-classes.html) object. This allows a single `data` object to be shared between multiple graphical components, and in turn means that the interface need not be built as a single monolithic entity.
* Use the [events system](https://www.mathworks.com/help/matlab/events-sending-and-responding-to-messages.html) to trigger updates to specific parts of the app in response to properties of the data object changing. This removes the need for a single large `updateInterface` function and reduces coupling between parts of the interface. For example, the `SelectedExample` property would have an associated event such that when it is changed by a callback (or from the command line) it notifies other interface components of the change. Each interface component (or group thereof) can listen for the events that affect it.

Advice on how to build large-scale applications is beyond the scope of this document. If you need help in this area, please contact your MathWorks account manager who will be able to put you in touch with a technical specialist.