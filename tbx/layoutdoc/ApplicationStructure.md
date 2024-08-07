
# **Application Structure**

# Overview

There are many ways to build graphical applications in MATLAB, but here we will take a very simple approach. If the application were to become larger and more complex, this approach would be changed to better mitigate the complexity. Some notes on this are contained at the [end of this section](Scalability.md).

## Application structure

The application is structured as a single function, with callbacks and other helper functions implemented as nested functions, i.e., functions defined inside the main function. This has the advantage that the nested functions can share access to any variables defined in the main function. This approach also poses a risk, as anything we accidentally define in the main function lies in the scope of all nested functions within the file. For this reason, all logic is put into nested functions and we restrict the main function to only define two shared variables:

-  **`data`**: a structure containing all shared data, 
-  **`app`**: a structure containing handles to user\-interface components.

```matlab
function galleryBrowser()

   % Declare shared variables
   data = createData();
   app = createInterface( data.ExampleNames );

   % Now update the app with the current data
   updateInterface()
   redrawExample()
   
   % Helper functions.
   function data = createData() ... end
   function app = createInterface( names ) ... end
   function updateInterface() ... end
   function redrawExample() ... end

   % Callback subfunctions.
   function onMenuSelection() ... end
   function onListSelection() ... end
   function onExampleHelp() ... end
   function onHelp() ... end
   function onExit() ... end 
```