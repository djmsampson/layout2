function varargout = galleryBrowser()
%galleryBrowser: an example of using layouts to build a user interface
%
%   galleryBrowser() opens a simple app that allows several of MATLAB's
%   built-in examples to be viewed. It aims to demonstrate how multiple
%   layouts can be used to create a good-looking user interface that
%   retains the correct proportions when resized. It also shows how to
%   connect callbacks to interpret user interaction.

%  Copyright 2009-2024 The MathWorks, Inc.

% Data is shared between all child functions by declaring the variables
% here (they become global to the function). We keep things tidy by putting
% all app components in one structure and all data in another. As the app
% grows, we might consider making these objects rather than structures.
data = createData();
app = createInterface( data.ExampleNames );

% Now update the app with the current data
updateInterface()
redrawExample()

% Return the figure if an output is requested.
nargoutchk( 0, 1 )
if nargout == 1
    varargout{1} = app.Figure;
end % if

    function data = createData()

        % Create the shared data-structure for this application
        exampleList = {
            'Complex surface'            'cplxdemo'
            'Cruller'                    'cruller'
            'Earth'                      'earthmap'
            'Four linked tori'           'tori4'
            'Klein bottle'               'xpklein'
            'Klein bottle (1)'           'klein1'
            'Knot'                       'knot'
            'Logo'                       'logo'
            'Spherical Surface Harmonic' 'spharm2'
            'Werner Boy''s Surface'      'wernerboy'
            };
        selectedExample = 8;
        data = struct( ...
            'ExampleNames', {exampleList(:,1)'}, ...
            'ExampleFunctions', {exampleList(:,2)'}, ...
            'SelectedExample', selectedExample );

    end % createData

    function gui = createInterface( exampleList )

        % Create the user interface for the application and return a
        % structure of handles for global use.
        gui = struct();

        % Create a figure and add some menus
        gui.Figure = figure( ...
            'Name', 'Gallery Browser', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off' );

        % + File menu
        gui.FileMenu = uimenu( gui.Figure, 'Label', 'File' );
        uimenu( gui.FileMenu, 'Label', 'Exit', 'Callback', @onExit );

        % + View menu
        gui.ViewMenu = uimenu( gui.Figure, 'Label', 'View' );
        for ii=1:numel( exampleList )
            uimenu( gui.ViewMenu, 'Label', exampleList{ii}, ...
                'Callback', @onMenuSelection );
        end

        % + Help menu
        helpMenu = uimenu( gui.Figure, 'Label', 'Help' );
        uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );

        % Arrange the main interface
        mainLayout = uix.HBoxFlex( 'Parent', gui.Figure, 'Spacing', 3 );

        % + Create the panels
        controlPanel = uix.BoxPanel( ...
            'Parent', mainLayout, ...
            'Title', 'Select an example' );
        gui.ViewPanel = uix.BoxPanel( ...
            'Parent', mainLayout, ...
            'Title', 'Viewing: ???', ...
            'HelpFcn', @onExampleHelp );
        gui.ViewContainer = uicontainer( ...
            'Parent', gui.ViewPanel );

        % + Adjust the main layout
        set( mainLayout, 'Widths', [-1, -2]  );

        % + Create the controls
        controlLayout = uix.VBox( 'Parent', controlPanel, ...
            'Padding', 3, 'Spacing', 3 );
        gui.ListBox = uicontrol( 'Style', 'list', ...
            'BackgroundColor', 'w', ...
            'Parent', controlLayout, ...
            'String', exampleList(:), ...
            'Value', 1, ...
            'Callback', @onListSelection);
        gui.HelpButton = uicontrol( 'Style', 'PushButton', ...
            'Parent', controlLayout, ...
            'String', 'Help for <example>', ...
            'Callback', @onExampleHelp );

        % Make the list fill the space
        set( controlLayout, 'Heights', [-1, 28] );

        % + Create the view
        p = gui.ViewContainer;
        gui.ViewAxes = axes( 'Parent', p );

    end % createInterface

    function updateInterface()
        % Update various parts of the interface in response to the example
        % being changed.

        % Update the list and menu to show the current example
        set( app.ListBox, 'Value', data.SelectedExample )

        % Update the help button label
        exampleName = data.ExampleNames{ data.SelectedExample };
        set( app.HelpButton, 'String', ['Help for ', exampleName] )

        % Update the view panel title
        set( app.ViewPanel, 'Title', ...
            sprintf( 'Viewing: %s', exampleName ) )

        % Untick all menus
        menus = get( app.ViewMenu, 'Children' );
        set( menus, 'Checked', 'off' )

        % Use the name to work out which menu item should be ticked
        whichMenu = strcmpi( exampleName, get( menus, 'Label' ) );
        set( menus(whichMenu), 'Checked', 'on' )

    end % updateInterface

    function redrawExample()
        % Draw a example into the axes provided

        % We first clear the existing axes ready to build a new one
        if ishandle( app.ViewAxes )
            delete( app.ViewAxes );
        end

        % Some examples create their own figure. Others don't.
        fcnName = data.ExampleFunctions{data.SelectedExample};
        switch upper( fcnName )
            case 'LOGO'
                % These examples open their own windows
                evalin( 'base', fcnName );
                app.ViewAxes = gca();
                fig = gcf();
                set( fig, 'Visible', 'off' )

            otherwise
                % These examples need a window opening
                fig = figure( 'Visible', 'off' );
                evalin( 'base', fcnName );
                app.ViewAxes = gca();
        end

        % Now copy the axes from the example into our window and restore its
        % state.
        cmap = colormap( app.ViewAxes );
        set( app.ViewAxes, 'Parent', app.ViewContainer );
        colormap( app.ViewAxes, cmap );
        rotate3d( app.ViewAxes, 'on' );

        % Get rid of the example figure
        close( fig )

    end % redrawExample

    function onListSelection( src, ~ )

        % User selected an example from the list - update "data" and
        % refresh
        data.SelectedExample = get( src, 'Value' );
        updateInterface()
        redrawExample()

    end % onListSelection

    function onMenuSelection( src, ~ )

        % User selected a example from the menu - work out which one
        exampleName = get( src, 'Label' );
        data.SelectedExample = find( strcmpi( exampleName, ...
            data.ExampleNames ), 1, 'first' );
        updateInterface()
        redrawExample()

    end % onMenuSelection

    function onHelp( ~, ~ )

        % User has asked for the documentation
        doc layout

    end % onHelp

    function onExampleHelp( ~, ~ )

        % User wants documentation for the current example
        showdemo( data.ExampleFunctions{data.SelectedExample} )

    end % onExampleHelp

    function onExit( ~, ~ )

        % User wants to exit from the application
        delete( app.Figure )

    end % onExit

end % galleryBrowser