classdef FlexSharedTests < ContainerSharedTests
    %FLEXSHAREDTESTS Shared test accross all Flex classes
    
    methods ( Test )
        
        function testMouseOverDividerInDockedFigure( testcase, ContainerType )
            % g1334965: Add test for g1330841: Mouse-over-divider detection
            % does not work for docked figures in R2015b
            %
            % Pass for unparented tests, since this is not applicable
            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.Matches
            
            % Abort for unparented cases and in unsuitable environments
            if testcase.isJenkins() || testcase.isBaT() || testcase.isUnparented(), return, end
            
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
            % Find figure origin
            figOrigin = getFigureOrigin( fig );
            % Move to lower bottom
            moveMouseTo( figOrigin )
            % Check you start with an arrow pointer
            testcase.verifyEqual( fig.Pointer, 'arrow', 'Pointer should be arrow to start with' )
            % Move over dividers and make sure you get the right ones
            set( dividers, 'Units', 'pixel' );
            for ii = 1:numel( dividers )
                moveMouseTo( figOrigin + getpixelcenter( dividers(ii), true ) )
                testcase.verifyThat( @()fig.Pointer, Eventually( Matches( '(left|right|top|bottom)' ) ),...
                    sprintf( 'Wrong pointer in divider %d', ii ) );
            end
            
        end % testMouseOverDividerInDockedFigure
        
        function testMousePointerUpdateOnFlexChange( testcase, ContainerType )
            % g1367326: Add test for g1346921: Mouse pointer gets confused
            % when moving between adjacent flex containers
            
            % Abort for unparented cases and in unsuitable environments
            if testcase.isJenkins() || testcase.isBaT() || testcase.isUnparented(), return, end
            
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
            % Get figure origin
            figOrigin = getFigureOrigin( fig );
            % Move over a button
            moveMouseTo( figOrigin + getpixelcenter( h1Buttons(1), true ) )
            testcase.verifyEqual( fig.Pointer, 'arrow' );
            % Move over a divider
            moveMouseTo( figOrigin + getpixelcenter( h1Dividers(end), true ) )
            testcase.verifyMatches( fig.Pointer, '(left|right|top|bottom)' );
            % Move to the matching divider of the other flex
            moveMouseTo( figOrigin + getpixelcenter( h2Dividers(end), true ) )
            testcase.verifyMatches( fig.Pointer, '(left|right|top|bottom)' );
            % Move back to a button
            moveMouseTo( figOrigin + getpixelcenter( h2Buttons(2), true ) )
            testcase.verifyMatches( fig.Pointer, 'arrow' );
            % And the other way around
            moveMouseTo( figOrigin + getpixelcenter( h2Dividers(end), true ) )
            testcase.verifyMatches( fig.Pointer, '(left|right|top|bottom)' );
            moveMouseTo( figOrigin + getpixelcenter( h1Dividers(end), true ) )
            testcase.verifyMatches( fig.Pointer, '(left|right|top|bottom)' );
            moveMouseTo( figOrigin + getpixelcenter( h1Buttons(1), true ) )
            testcase.verifyEqual( fig.Pointer, 'arrow' );
            
        end % testMousePointerUpdateOnFlexChange
        
        function testMousePointerUpdateOnFlexClick( testcase, ContainerType )
            % g1367337: Update flex container pointer on mouse press event
            
            % Abort for unparented cases and in unsuitable environments
            if testcase.isJenkins() || testcase.isBaT() || testcase.isUnparented(), return, end
            
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
            figOrigin = getFigureOrigin( fig );
            dividerPosition = figOrigin + getpixelcenter( h1Dividers(1), true );
            % Unparent
            h1.Parent = [];
            % Place the mouse
            moveMouseTo( dividerPosition )
            testcase.verifyEqual( fig.Pointer, 'arrow' );
            % Parent
            h1.Parent = fig;
            % Bring figure back into focus
            figure(fig);
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
            
        end % testMousePointerUpdateOnFlexClick
        
    end
    
    methods ( Access = private )
        
        function tf = isUnparented( testcase )
            %isUnparented  Test for unparented testcases
            
            tf = strcmp( testcase.parentStr, '[]' );
            
        end % isUnparented
        
        function tf = isJenkins( ~ )
            %isJenkins  True in Jenkins environment
            
            tf = strcmp( getenv( 'JOB_NAME' ), 'GUI_Layout-Toolbox-v2' );
            
        end % isJenkins
        
    end % helpers
    
end

function p = getFigureOrigin( f )
%getFigureOrigin  Get location on screen of figure origin
%
%  p = getFigureOrigin(f) returns the location on screen of the bottom-left
%  corner of the figure f.
%
%  The method used is unreliable if the display resolution or
%  scaling is changed after MATLAB starts.

switch f.WindowStyle
    
    case 'docked'
        
        t = 0.1; % pause during screen sweep
        
        figure( f ); % bring to front
        li = event.listener( f, 'WindowMouseMotion', @onMouseMotion ); %#ok<NASGU>
        r = groot(); % graphics root
        m = r.MonitorPositions; % get monitor positions
        p = [NaN NaN]; % initialize result
        for ii = 1:size( m, 1 ) % sweep monitors
            nx = ceil( m(ii,3)/f.Position(3) ) + 1;
            ny = ceil( m(ii,4)/f.Position(4) ) + 1;
            x = linspace( m(ii,1), m(ii,1)+m(ii,3), nx*2 ); % horizontal grid
            y = linspace( m(ii,2), m(ii,2)+m(ii,4), ny*2 ); % vertical grid
            for jj = 1:numel( x ) % sweep horizontally
                for kk = 1:numel( y ) % sweep vertically
                    r.PointerLocation = [x(jj), y(kk)]; % move pointer
                    pause( t ) % wait
                    if ~all( isnan( p ) ), return, end % found figure
                end
            end
        end
        
    otherwise
        
        p = f.Position(1:2);
        
end % switch

    function onMouseMotion( ~, e )
        p = r.PointerLocation - e.Point + [1 1]; % set output
    end

end % getFigureOrigin

function c = getpixelcenter( varargin )
%getpixelcenter  Get center of object in pixel units

p = getpixelposition( varargin{:} );
c = p(1:2) + p(3:4)/2;

end % getpixelcenter

function moveMouseTo( newPosition )
%moveMouseTo  Move mouse to new position
%
%  moveMouseTo(p) moves the mouse to the location p.

n = 5; % number of steps
t = 0.1; % pause during move

r = groot();
oldPosition = r.PointerLocation;
x = linspace( oldPosition(1), newPosition(1), n );
y = linspace( oldPosition(2), newPosition(2), n );
for ii = 2:n
    r.PointerLocation = [x(ii) y(ii)];
    pause( t ); % wait
end

end % moveMouseTo