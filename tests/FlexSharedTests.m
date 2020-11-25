classdef FlexSharedTests < ContainerSharedTests
    %FLEXSHAREDTESTS Shared test accross all Flex classes
    
    methods ( Test )
        
        function testMouseOverDividerInDockedFigure( testcase, ContainerType )
            % g1334965: Add test for g1330841: Mouse-over-divider detection
            % does not work for docked figures in R2015b
            
            import matlab.unittest.constraints.Eventually
            import matlab.unittest.constraints.Matches
            
            % Abort for unparented cases and in unsuitable environments
            testcase.assumeRooted()
            testcase.assumeNotWeb()
            testcase.assumeDisplay()
            
            % Build the flex
            c = testcase.hCreateObj( ContainerType );
            f = c.Parent;
            f.WindowStyle = 'docked';
            figure( f ) % bring to front
            for ii = 1:9
                uicontrol( 'Parent', c );
            end
            c.Padding = 10;
            c.Spacing = 10;
            % In case of grid, make sure you have a grid
            if isa( c, 'uiextras.GridFlex' )
                c.Widths = [-1 -1 -1];
            end
            % Find some dividers
            d = findobj( hgGetTrueChildren( c ), 'Tag', 'uix.Divider', 'Visible', 'on' );
            % Move to lower bottom
            figureOrigin = getFigureOrigin( f );
            moveMouseTo( figureOrigin )
            % Check you start with an arrow pointer
            testcase.verifyEqual( f.Pointer, 'arrow', 'Pointer should be arrow to start with' )
            % Move over dividers and make sure you get the right ones
            for ii = 1:numel( d )
                moveMouseTo( figureOrigin + getpixelcenter( d(ii), true ) )
                testcase.verifyThat( @()f.Pointer, Eventually( Matches( '(left|right|top|bottom)' ) ),...
                    sprintf( 'Wrong pointer in divider %d', ii ) );
            end
            
        end % testMouseOverDividerInDockedFigure
        
        function testMousePointerUpdateOnFlexChange( testcase, ContainerType )
            % g1367326: Add test for g1346921: Mouse pointer gets confused
            % when moving between adjacent flex containers
            
            % Abort for unparented cases and in unsuitable environments
            testcase.assumeRooted()
            testcase.assumeDisplay()
            
            % Build
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            f = fx.FigureHandle;
            % Layout is component based
            switch ContainerType
                case 'uiextras.VBoxFlex'
                    childType = 'VBoxFlex';
                    parentType = 'HBox';
                case 'uiextras.HBoxFlex'
                    childType = 'HBoxFlex';
                    parentType = 'VBox';
                case 'uiextras.GridFlex'
                    childType = 'GridFlex';
                    parentType = 'Grid';
            end
            p = uiextras.(parentType)( 'Parent', f );
            nChildren = 9;
            c1 = uiextras.(childType)( 'Parent', p, 'Spacing', 10 );
            b1 = gobjects( 1, nChildren );
            for ii = 1:nChildren
                b1(ii) = uicontrol( 'Parent', c1 );
            end
            c2 = uiextras.(childType)( 'Parent', p, 'Spacing', 10 );
            b2 = gobjects( 1, nChildren );
            for ii = 1:nChildren
                b2(ii) = uicontrol( 'Parent', c2 );
            end
            if strcmp( childType, 'GridFlex' )
                p.Widths = -1;
                c1.Widths = [-1 -1 -1];
                c2.Widths = [-1 -1 -1];
            end
            % Find the dividers
            d1 = findobj( hgGetTrueChildren( c1 ), 'Tag', 'uix.Divider', 'Visible', 'on' );
            d2 = findobj( hgGetTrueChildren( c2 ), 'Tag', 'uix.Divider', 'Visible', 'on' );
            % Mark test elements
            b1(1).BackgroundColor = 'r';
            b2(2).BackgroundColor = 'g';
            d1(end).BackgroundColor = 'c';
            d2(end).BackgroundColor = 'm';
            % Get figure origin
            figureOrigin = getFigureOrigin( f );
            % Move over a button
            moveMouseTo( figureOrigin + getpixelcenter( b1(1), true ) )
            testcase.verifyEqual( f.Pointer, 'arrow' );
            % Move over a divider
            moveMouseTo( figureOrigin + getpixelcenter( d1(end), true ) )
            testcase.verifyMatches( f.Pointer, '(left|right|top|bottom)' );
            % Move to the matching divider of the other flex
            moveMouseTo( figureOrigin + getpixelcenter( d2(end), true ) )
            testcase.verifyMatches( f.Pointer, '(left|right|top|bottom)' );
            % Move back to a button
            moveMouseTo( figureOrigin + getpixelcenter( b2(2), true ) )
            testcase.verifyMatches( f.Pointer, 'arrow' );
            % And the other way around
            moveMouseTo( figureOrigin + getpixelcenter( d2(end), true ) )
            testcase.verifyMatches( f.Pointer, '(left|right|top|bottom)' );
            moveMouseTo( figureOrigin + getpixelcenter( d1(end), true ) )
            testcase.verifyMatches( f.Pointer, '(left|right|top|bottom)' );
            moveMouseTo( figureOrigin + getpixelcenter( b1(1), true ) )
            testcase.verifyEqual( f.Pointer, 'arrow' );
            
        end % testMousePointerUpdateOnFlexChange
        
        function testMousePointerUpdateOnFlexClick( testcase, ContainerType )
            % g1367337: Update flex container pointer on mouse press event
            
            % Abort for unparented cases and in unsuitable environments
            testcase.assumeRooted()
            testcase.assumeDisplay()
            
            temp = strsplit( ContainerType, '.' );
            ComponentName = temp{2};
            % Build
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            f = fx.FigureHandle;
            nChildren = 4;
            h1 = uiextras.(ComponentName)( 'Parent', f, 'Spacing', 10 );
            b1 = gobjects( 1, nChildren );
            for ii = 1:nChildren
                b1(ii) = uicontrol( 'Parent', h1 );
            end
            % Find the dividers
            d1 = findobj( hgGetTrueChildren( h1 ), 'Tag', 'uix.Divider', 'Visible', 'on' );
            % Where will be the divider?
            figureOrigin = getFigureOrigin( f );
            dividerPosition = figureOrigin + getpixelcenter( d1(1), true );
            % Unparent
            h1.Parent = [];
            % Place the mouse
            moveMouseTo( dividerPosition )
            testcase.verifyEqual( f.Pointer, 'arrow' );
            % Parent
            h1.Parent = f;
            % Bring figure back into focus
            eval('figure(f)');
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
            testcase.verifyMatches( f.Pointer, '(left|right|top|bottom)' );
            Robot().mouseRelease( InputEvent.BUTTON1_MASK );
            drawnow
            
        end % testMousePointerUpdateOnFlexClick
        
    end
    
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
        
        figure( f ) % bring to front
        pause( t )
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

function moveMouseTo( new )
%moveMouseTo  Move mouse to new position
%
%  moveMouseTo(p) moves the mouse to the location p.

n = 5; % number of steps
t = 0.1; % pause during move

r = groot();
old = r.PointerLocation;
x = linspace( old(1), new(1), n );
y = linspace( old(2), new(2), n );
for ii = 2:n
    r.PointerLocation = [x(ii) y(ii)];
    pause( t ) % wait
end

end % moveMouseTo