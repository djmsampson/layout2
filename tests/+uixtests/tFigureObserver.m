classdef tFigureObserver < utilities.mixin.TestInfrastructure
    %TFIGUREOBSERVER Tests for uix.FigureObserver.

    methods ( Test, Sealed )

        function tConstructorReturnsScalarObject( testCase )

            % Assume the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Create an object.
            fig = testCase.ParentFixture.Parent;
            FO = uix.FigureObserver( fig );

            % Verify the size of the object.
            testCase.verifySize( FO, [1, 1], ...
                ['The uix.FigureObserver constructor did not ', ...
                'return a scalar object.'] )

        end % tConstructorReturnsScalarObject

        function tConstructorErrorsForInvalidInput( testCase )

            % The non-graphics case.
            f = @() uix.FigureObserver( 0 );
            testCase.verifyError( f, 'MATLAB:invalidType', ...
                ['The uix.FigureObserver constructor accepted a ', ...
                'non-graphics input.'] )

            % The non-scalar case.
            ax = axes( 'Parent', [] );
            testCase.addTeardown( @() delete( ax ) )
            f = @() uix.FigureObserver( [ax, ax] );
            testCase.verifyError( f, 'MATLAB:expectedScalar', ...
                ['The uix.FigureObserver constructor accepted a ', ...
                'non-scalar input.'] )

        end % tConstructorErrorsForInvalidInput

        function tConstructorAssignsFigureAncestor( testCase )

            % Create an axes on the test figure (which may be empty).
            fig = ancestor( testCase.ParentFixture.Parent, 'figure' );
            ax = axes( 'Parent', fig );
            testCase.addTeardown( @() delete( ax ) )

            % Create an object.
            FO = uix.FigureObserver( ax );

            % Verify that the 'Subject' and 'Figure' properties are
            % assigned correctly.
            testCase.verifySameHandle( FO.Subject, ax, ...
                ['The uix.FigureObserver constructor did not ', ...
                'assign the ''Subject'' property correctly.'] )
            diagnostic = ['The uix.Figure Observer constructor ', ...
                'did not assign the ''Figure'' property correctly.'];
            if isempty( fig )
                testCase.verifyEmpty( FO.Figure, diagnostic )
            else
                testCase.verifySameHandle( FO.Figure, fig, diagnostic )
            end % if

        end % tConstructorAssignsFigureAncestor

        function tChangingParentRaisesEventAndPassesEventData( testCase )

            % Create a FigureObserver object.
            ax = axes( 'Parent', [] );
            testCase.addTeardown( @() delete( ax ) )
            FO = uix.FigureObserver( ax );

            % Create a new figure.
            fig = figure( 'Visible', 'off' );
            testCase.addTeardown( @() delete( fig ) )

            % Create a listener.
            eventRaised = false;
            eventData = struct.empty();
            event.listener( FO, 'FigureChanged', @onFigureChanged );

            % Change the parent of the axes.
            ax.Parent = fig;

            % Verify that the event was raised.
            testCase.verifyTrue( eventRaised, ...
                ['The uix.FigureObserver object did not raise the ', ...
                '''FigureChanged'' event when the parent of its ', ...
                'subject was changed.'] )

            % Verify that the event data has the correct properties.
            testCase.verifyEmpty( eventData.OldFigure, ...
                ['The uix.FigureData event data does not have the ', ...
                'correct value for the ''OldFigure'' property.'] )
            testCase.verifySameHandle( eventData.NewFigure, fig, ...
                ['The uix.FigureData event data does not have the ', ...
                'correct value for the ''NewFigure'' property.'] )

            function onFigureChanged( ~, e )

                eventRaised = true;
                eventData = e;

            end % onFigureChanged

        end % tChangingParentRaisesEventAndPassesEventData

    end % methods ( Test, Sealed )

end % class