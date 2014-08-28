GUI Layout Toolbox 2
====================


Structure of the repository
---------------------------

GUI Layout Toolbox 2 is arranged as follows:

SVNRoot
|-> code/     : contains everything that ends up on the file-exchange.
|-> docsrc/   : the input files for building the documentation. Not to be shared with customers.
|-> planning/ : various internal documents capturing the design decisions and issues.
|-> tests/    : unit and integration tests that should be run before committing any changes



Code
----
The CODE folder contains everything that is uploaded to the file exchange for customers to use. It is split up as follows:

code/
|-> layout/      : the layout toolbox code
|-> layoutdoc/   : the layout toolbox documentation (html)
|-> install.m    : installation script that adds the code and documentation to the path
|-> uninstall.m  : uninstallation script that removes the code and documentation from the path



DocSrc
------
The DOCSRC folder contains the XML files that define the GUI Layout Toolbox documentation. The DocTools toolbox is required to convert these into HTML documentation suitable for the MATLAB help browser. To build:

>> buildDoc

Note that the GUI Layout Toolbox must be installed for the documentation to build. This ensures that the documentation picks up the right version number and install location.



Tests
-----
The TESTS folder contains xUnit tests for the GUI Layout Toolbox. It requires MATLAB xUnit to be installed. To run:

>> runtests

Note that the GUI Layout Toolbox must be installed for the tests to run.
