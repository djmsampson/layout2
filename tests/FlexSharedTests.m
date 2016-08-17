classdef FlexSharedTests < ContainerSharedTests
    %FLEXSHAREDTESTS Shared test accross all Flex classes
    
    methods ( Test )
        function testMouseOverDividerInDockedFigure( testcase, ContainerType )
            % g1334965: Add test for g1330841: Mouse-over-divider detection
            % does not work for docked figures in R2015b
            %
            % Pass for unparented tests, since this is not applicable
            if strcmp( testcase.parentStr, '[]' ) || isjenkins()
                return;
            end
            % Create a docked figure front and center
            root = groot;
            % Build the flex
            flex = testcase.hCreateObj( ContainerType );
            fig = flex.Parent;
            fig.WindowStyle = 'docked';
            figure( fig )
            for ii = 1:9
                uicontrol( 'Parent', flex );
            end
            flex.Padding = 10;
            flex.Spacing = 10;
            % In case of grid, make sure you have a grid
            if isa( flex, 'uiextras.GridFlex' )
                flex.Widths = [-1 -1 -1];
            end
            % Find some dividers
            children = hgGetTrueChildren( flex );
            dividers = findobj( children, 'Tag', 'uix.Divider', 'Visible', 'on' );
            drawnow;
            % [SWITCH] Find the docked figure origin
            dockedFigureDetection = 1;
            % 1. The hard way, look all over the screens to find the figure
            % 2. Undocumented java feature, faster and cleaner, might break
            %    at anytime. Further, will break if Windows Screen Zoom
            switch dockedFigureDetection
                case 1
                    fig.WindowButtonMotionFcn = @fakeCallback;
                    % Scour the screens
                    steps = 10;
                    mousePosition = [0 0];
                    for screenPosition = root.MonitorPositions'
                        [X,Y] = meshgrid(...
                            linspace( screenPosition(1), screenPosition(1)+screenPosition(3), steps ),...
                            linspace( screenPosition(2), screenPosition(2)+screenPosition(4), steps ) );
                        for i=1:numel(X)
                            % Move and click
                            testcase.mouseMove( root, [X(i) Y(i)], false );
                            % Check if you hit the figure
                            if ~isequal( mousePosition, [0 0] )
                                % Move by a pixel, to lock down
                                testcase.mouseMove( root, [X(i) Y(i)], false );
                                % Grab the info
                                absolutePosition = root.PointerLocation;
                                relativePosition = fig.CurrentPoint;
                                figureLeftBottom = absolutePosition - relativePosition;
                                fig.WindowButtonMotionFcn = [];
                                break;
                            end
                        end
                    end
                case 2
                    warning( 'off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame' );
                    javaFrame = fig.JavaFrame;  % This will warn – you'll have to suppress it
                    warning( 'on', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame' );
                    frameLocation = javaFrame.getContainerLocation();
                    % Java indexes from top left, MATLAB from Bottom left
                    figureLeftBottom = [frameLocation.x, root.ScreenSize(4) - fig.Position(4) - frameLocation.y];
            end
            % 1. Nested
            function fakeCallback( src, ~ )
                mousePosition = src.CurrentPoint;
            end
            % [END SWITCH]
            % Move to lower bottom
            testcase.mouseMove( root, figureLeftBottom );
            % Check you start with an arrow pointer
            testcase.verifyEqual( fig.Pointer, 'arrow', 'Pointer should be arrow to start with' )
            % Move over dividers and make sure you get the right ones
            set( dividers, 'Units', 'pixel' );
            for i = 1:numel( dividers )
                midDivider = dividers(i).Position(1:2) + figureLeftBottom  + dividers(i).Position(3:4)/2;
                testcase.mouseMove( root, midDivider );
                testcase.verifyMatches( fig.Pointer, '(left|right|top|bottom)',...
                    sprintf( 'Wrong pointer in divider %d, placed at [%d,%d]', i, midDivider ) );
            end
        end
        function testMousePointerUpdateOnFlexChange( testcase, ContainerType )
            % g1367326: Add test for g1346921: Mouse pointer gets confused
            % when moving between adjacent flex containers
            %
            % Only makes sense in parented case
            if strcmp( testcase.parentStr, '[]' ) || isjenkins()
                return;
            end
            % Build
            fig = figure;
            % Layout is component based
            switch ContainerType
                case 'uiextras.VBoxFlex'
                    testedContainer = 'VBoxFlex';
                    layoutContainer = 'HBox';
                case 'uiextras.HBoxFlex'
                    testedContainer = 'HBoxFlex';
                    layoutContainer = 'VBox';
                case 'uiextras.GridFlex'
                    testedContainer = 'GridFlex';
                    layoutContainer = 'Grid';
            end
            layout = uiextras.(layoutContainer)( 'Parent', fig );
            nChildren = 9;
            h1 = uiextras.(testedContainer)( 'Parent', layout, 'Spacing', 10 );
            h1Buttons = gobjects( 1, nChildren );
            for ii = 1:nChildren
                h1Buttons(ii) = uicontrol( 'Parent', h1 );
            end
            h2 = uiextras.(testedContainer)( 'Parent', layout, 'Spacing', 10 );
            h2Buttons = gobjects( 1, nChildren );
            for ii = 1:nChildren
                h2Buttons(ii) = uicontrol( 'Parent', h2 );
            end
            if strcmp( testedContainer, 'GridFlex' )
                layout.Widths = -1;
                h1.Widths = [-1 -1 -1];
                h2.Widths = [-1 -1 -1];
            end
            % Find the dividers
            h1Dividers = findobj( hgGetTrueChildren( h1 ), 'Tag', 'uix.Divider', 'Visible', 'on' );
            h2Dividers = findobj( hgGetTrueChildren( h2 ), 'Tag', 'uix.Divider', 'Visible', 'on' );
            % Mark test elements
            h1Buttons(1).BackgroundColor = 'r';
            h2Buttons(2).BackgroundColor = 'g';
            h1Dividers(end).BackgroundColor = 'c';
            h2Dividers(end).BackgroundColor = 'm';
            % Move over a button
            testcase.mouseMove( groot, testcase.midComponentAbsolutePosition( h1Buttons(1)) );
            testcase.verifyEqual( fig.Pointer, 'arrow' );
            % Move over a divider
            testcase.mouseMove( groot, testcase.midComponentAbsolutePosition( h1Dividers(end)) );
            testcase.verifyMatches( fig.Pointer, '(left|right|top|bottom)' );
            % Move to the matching divider of the other flex
            testcase.mouseMove( groot, testcase.midComponentAbsolutePosition( h2Dividers(end)) );
            testcase.verifyMatches( fig.Pointer, '(left|right|top|bottom)' );
            % Move back to a button
            testcase.mouseMove( groot, testcase.midComponentAbsolutePosition( h2Buttons(2)) );
            testcase.verifyMatches( fig.Pointer, 'arrow' );
            % And the other way around
            testcase.mouseMove( groot, testcase.midComponentAbsolutePosition( h2Dividers(end)) );
            testcase.verifyMatches( fig.Pointer, '(left|right|top|bottom)' );
            testcase.mouseMove( groot, testcase.midComponentAbsolutePosition( h1Dividers(end)) );
            testcase.verifyMatches( fig.Pointer, '(left|right|top|bottom)' );
            testcase.mouseMove( groot, testcase.midComponentAbsolutePosition( h1Buttons(1)) );
            testcase.verifyEqual( fig.Pointer, 'arrow' );
        end
        function testMousePointerUpdateOnFlexClick( testcase, ContainerType )
            % g1367337: Update flex container pointer on mouse press event
            %
            % Only makes sense in parented case
            if strcmp( testcase.parentStr, '[]' ) || isjenkins()
                return;
            end
            temp = strsplit( ContainerType, '.' );
            ComponentName = temp{2};
            % Build
            fig = figure;
            nChildren = 4;
            h1 = uiextras.(ComponentName)( 'Parent', fig, 'Spacing', 10 );
            h1Buttons = gobjects( 1, nChildren );
            for ii = 1:nChildren
                h1Buttons(ii) = uicontrol( 'Parent', h1 );
            end
            % Find the dividers
            h1Dividers = findobj( hgGetTrueChildren( h1 ), 'Tag', 'uix.Divider', 'Visible', 'on' );
            % Where will be the divider?
            futureDividerPosition = testcase.midComponentAbsolutePosition( h1Dividers(1) );
            % Unparent
            h1.Parent = [];
            % Place the mouse
            testcase.mouseMove( groot, futureDividerPosition );
            testcase.verifyEqual( fig.Pointer, 'arrow' );
            % Parent
            h1.Parent = fig;
            % Click and check pointer
            import java.awt.Robot;
            import java.awt.event.*;
            mouse = javaObjectEDT( 'java.awt.Robot' );
            drawnow
            javaMethodEDT( 'mousePress', mouse, InputEvent.BUTTON1_MASK );
            drawnow
            % Still sometimes needs a pose for the cursor change to take
            % effect
            pause( 0.01 )
            testcase.verifyMatches( fig.Pointer, '(left|right|top|bottom)' );
            Robot().mouseRelease( InputEvent.BUTTON1_MASK );
            drawnow
        end
    end
    
    methods ( Static, Access = private )
        function location = midComponentAbsolutePosition( component )
            location = component.Position(3:4)/2;
            while ~isa( component, 'matlab.ui.Root' )
                location = location + component.Position(1:2);
                component = component.Parent;
            end
        end
        function mouseMove( root, newPosition, slow )
            if nargin==2
                slow = true;
            end
            if slow
                oldPosition = root.PointerLocation;
                interpolatedPosition = @( step, nSteps ) (1-step/nSteps) * oldPosition + step/nSteps * newPosition;
                % Move in 6 steps
                nSteps=6;
                for i = 1:nSteps
                    root.PointerLocation = interpolatedPosition( i, nSteps );
                    % Uncomment next line to see the test in action
                    %                 pause( 0.1 )
                    drawnow;
                end
                % It seems that drawnow might not be enough for the pointer
                % change to be reflected in the figure. Might be due to the
                % PointerManager. The following pause just ensure this bit.
                pause( 0.01 )
            else
                root.PointerLocation = newPosition;
                drawnow;
            end
        end
        
    end % helpers
    
end

function tf = isjenkins()
tf = strcmp( getenv( 'JOB_NAME' ), 'GUI_Layout-Toolbox-v2' );
end