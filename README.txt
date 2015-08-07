GUI Layout Toolbox 2
====================

Structure of the repository
---------------------------

GUI Layout Toolbox 2 is arranged as follows:

/bash     : bash tasks
/docsrc   : the input files for building the documentation (internal)
/planning : documents capturing the design decisions and issues (internal)
/releases : archive of previous releases
/tbx      : the toolbox itself -- what ends up on the File Exchange
/tests    : unit and integration tests that should be run before committing any changes


tbx
---

The tbx folder is arranged as follows:

/tbx/layout    : the code
/tbx/layoutdoc : the documentation


docsrc
------

The docsrc folder contains the XML files that define the GUI Layout Toolbox documentation. The DocTools toolbox is required to convert these into HTML documentation suitable for the MATLAB help browser. To build:

>> buildDoc

Note that the GUI Layout Toolbox must be installed for the documentation to build. This ensures that the documentation picks up the right version number and install location.


tests
-----
The tests folder contains MATLAB unit tests for GUI Layout Toolbox. To run:

>> runtests

Note that the GUI Layout Toolbox must be installed for the tests to run.
