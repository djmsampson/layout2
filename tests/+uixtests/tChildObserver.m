classdef tChildObserver < glttestutilities.TestInfrastructure
    %TCHILDOBSERVER Tests for uix.ChildObserver.

    methods ( Test, Sealed )

        function tConstructorErrorsWithNoInputArguments( testCase )

            f = @() uix.ChildObserver();
            testCase.verifyError( f, 'MATLAB:minrhs', ...
                ['The uix.ChildObserver constructor has not ', ...
                'errored when zero input arguments were provided.'] )

        end % tConstructorErrorsWithNoInputArguments

        function tConstructorErrorsForNonPositionableGraphics( testCase )

            % Create a menu, which is nonpositionable.
            m = uimenu( 'Parent', [] );
            testCase.addTeardown( @() delete( m ) )

            % Verify that passing the menu to the uix.ChildObserver
            % constructor issues an error.
            f = @() uix.ChildObserver( m );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['The uix.ChildObserver constructor has accepted ', ...
                'a nonpositionable graphics input argument.'] )

        end % tConstructorErrorsForNonPositionableGraphics

        function tConstructorErrorsForNonScalarGraphics( testCase )

            % Use two handles to the test figure.
            testCase.assumeGraphicsAreRooted()
            fig = testCase.ParentFixture.Parent;
            f = @() uix.ChildObserver( [fig, fig] );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['The uix.ChildObserver constructor has accepted ', ...
                'a non-scalar graphics input argument.'] )

        end % tConstructorErrorsForNonScalarGraphics

        function tConstructorReturnsScalarObject( testCase )

            % Create an axes.
            ax = axes( 'Parent', [] );
            testCase.addTeardown( @() delete( ax ) )

            % Create a ChildObserver object.
            CO = uix.ChildObserver( ax );

            % Verify the size.
            testCase.verifySize( CO, [1, 1], ...
                ['The uix.ChildObserver constructor has not ', ...
                'returned a scalar object.'] )

        end % tConstructorReturnsScalarObject

        function tConstructorIsWarningFreeForObjectWithChildren( testCase )

            % Create an axes with children.
            ax = axes( 'Parent', [] );
            plot( ax, magic( 5 ) )
            testCase.addTeardown( @() delete( ax ) )

            % Verify that creating a ChildObserver object is warning-free.
            f = @() uix.ChildObserver( ax );
            testCase.verifyWarningFree( f, ...
                ['The uix.ChildObserver constructor was not ', ...
                'warning-free when called with a graphics object ', ...
                'which has children.'] )

        end % tConstructorIsWarningFreeForObjectWithChildren

        function tAddingChildRaisesCorrectEventData( testCase )

            % Create a panel.
            p = uipanel( 'Parent', [] );
            testCase.addTeardown( @() delete( p ) )

            % Create a ChildObserver object.
            CO = uix.ChildObserver( p );

            % Create a listener.
            eventRaised = false;
            eventData = struct.empty();
            event.listener( CO, 'ChildAdded', @onChildAdded );

            % Add a child object to the panel.
            child = uipanel( 'Parent', p );

            % Verify that the event was raised.
            testCase.verifyTrue( eventRaised, ...
                ['The uix.ChildObserver object did not raise the ', ...
                'event ''ChildAdded'' when a child was added.'] )

            % Verify that the event data is correct.
            testCase.verifyClass( eventData, 'uix.ChildEvent', ...
                ['The uix.ChildObserver object did not pass ', ...
                'event data of type ''uix.ChildEvent''.'] )
            testCase.verifySameHandle( eventData.Child, child, ...
                ['The uix.ChildObserver object did not pass ', ...
                'the correct graphics object to uix.ChildEvent.'] )

            function onChildAdded( ~, e )

                eventRaised = true;
                eventData = e;

            end % onChildAdded

        end % tAddingChildRaisesCorrectEventData

        function tRemovingChildRaisesCorrectEventData( testCase )

            % Create a panel with children. Add a BoxPanel containing an
            % axes in order to reach the recursive code within the
            % removeChild() method of uix.ChildObserver.
            panel = uipanel( 'Parent', [] );
            child = uix.BoxPanel( 'Parent', panel );
            axes( 'Parent', child )
            testCase.addTeardown( @() delete( panel ) )

            % Create a ChildObserver object.
            CO = uix.ChildObserver( panel );

            % Create a listener.
            eventRaised = false;
            eventData = struct.empty();
            event.listener( CO, 'ChildRemoved', @onChildRemoved );

            % Remove a child object from the panel.
            delete( child )

            % Verify that the event was raised.
            testCase.verifyTrue( eventRaised, ...
                ['The uix.ChildObserver object did not raise the ', ...
                'event ''ChildRemoved'' when a child was removed.'] )

            % Verify that the event data is correct.
            testCase.verifyClass( eventData, 'uix.ChildEvent', ...
                ['The uix.ChildObserver object did not pass ', ...
                'event data of type ''uix.ChildEvent''.'] )
            testCase.verifySameHandle( eventData.Child, child, ...
                ['The uix.ChildObserver object did not pass ', ...
                'the correct graphics object to uix.ChildEvent.'] )

            function onChildRemoved( ~, e )

                eventRaised = true;
                eventData = e;

            end % onChildRemoved

        end % tRemovingChildRaisesCorrectEventData

        function tSettingInternalTrueRaisesChildRemovedEvent( testCase )

            % Create a panel with children.
            p = uipanel( 'Parent', [] );
            child = uipanel( 'Parent', p );

            % Create a ChildObserver object.
            CO = uix.ChildObserver( p );

            % Create a listener.
            eventRaised = false;
            eventData = struct.empty();
            event.listener( CO, 'ChildRemoved', @onChildRemoved );

            % Set the 'Internal' property to true.
            child.Internal = true;

            % Verify that the event was raised.
            testCase.verifyTrue( eventRaised, ...
                ['The uix.ChildObserver object did not raise the ', ...
                'event ''ChildRemoved'' when the ''Internal'' ', ...
                'property of the subject was set to true.'] )

            % Verify that the event data is correct.
            testCase.verifyClass( eventData, 'uix.ChildEvent', ...
                ['The uix.ChildObserver object did not pass ', ...
                'event data of type ''uix.ChildEvent''.'] )
            testCase.verifySameHandle( eventData.Child, child, ...
                ['The uix.ChildObserver object did not pass ', ...
                'the correct graphics object to uix.ChildEvent.'] )

            function onChildRemoved( ~, e )

                eventRaised = true;
                eventData = e;

            end % onChildRemoved

        end % tSettingInternalTrueRaisesChildRemovedEvent

        function tSettingInternalFalseRaisesChildAddedEvent( testCase )

            % Create a panel with children.
            p = uipanel( 'Parent', [] );
            child = uipanel( 'Parent', p, 'Internal', true );

            % Create a ChildObserver object.
            CO = uix.ChildObserver( p );

            % Create a listener.
            eventRaised = false;
            eventData = struct.empty();
            event.listener( CO, 'ChildAdded', @onChildAdded );

            % Set the 'Internal' property to false.
            child.Internal = false;

            % Verify that the event was raised.
            testCase.verifyTrue( eventRaised, ...
                ['The uix.ChildObserver object did not raise the ', ...
                'event ''ChildAdded'' when the ''Internal'' ', ...
                'property of the subject was set to false.'] )

            % Verify that the event data is correct.
            testCase.verifyClass( eventData, 'uix.ChildEvent', ...
                ['The uix.ChildObserver object did not pass ', ...
                'event data of type ''uix.ChildEvent''.'] )
            testCase.verifySameHandle( eventData.Child, child, ...
                ['The uix.ChildObserver object did not pass ', ...
                'the correct graphics object to uix.ChildEvent.'] )

            function onChildAdded( ~, e )

                eventRaised = true;
                eventData = e;

            end % onChildAdded

        end % tSettingInternalFalseRaisesChildAddedEvent

        function tCreatingChildObserverOnObjectWithChildren( testCase )

            % Assume that we have a test figure.
            testCase.assumeGraphicsAreFigureBased()

            % Add a control to the figure.
            testFigure = testCase.ParentFixture.Parent;
            uicontrol( 'Parent', testFigure )

            % Verify that creating a child observer is warning-free.
            f = @() uix.ChildObserver( testFigure );
            testCase.verifyWarningFree( f, ['Creating an object of ', ...
                'type uix.ChildObserver from a figure containing a ', ...
                'control was not warning-free.'] )

        end % tCreatingChildObserverOnObjectWithChildren

        function tChangingInternalChildPropertyRaisesEvents( testCase )

            % Assume that we have a test figure.
            testCase.assumeGraphicsAreFigureBased()

            % Add a control to the figure.
            testFigure = testCase.ParentFixture.Parent;
            button = uicontrol( 'Parent', testFigure );

            % Create a child observer.
            observer = uix.ChildObserver( testFigure );

            % Create listeners.
            childRemovedListener = event.listener( observer, ...
                'ChildRemoved', @onChildRemoved );
            childAddedListener = event.listener( observer, ...
                'ChildAdded', @onChildAdded );
            childRemovedEventRaised = false;
            childAddedEventRaised = false;

            % Trigger a child removed event.
            button.Internal = true;
            testCase.verifyTrue( childRemovedEventRaised, ['Setting ', ...
                ' ''Internal'' to true on an observed child did ', ...
                'not raise the ''ChildRemoved'' event.'] )

            % Trigger a child added event.
            button.Internal = false;
            testCase.verifyTrue( childAddedEventRaised, ['Setting ', ...
                ' ''Internal'' to false on an observed child did ', ...
                'not raise the ''ChildAdded'' event.'] )

            % Reset the variable and verify that no event was raised when
            % the 'Internal' property is set to the same value.
            childRemovedEventRaised = false;
            button.Internal = false;
            testCase.verifyFalse( childRemovedEventRaised, ['Setting ', ...
                ' ''Internal'' to the same value on an observed ', ...
                'child incorrectly raised an event.'] )

            function onChildRemoved( ~, ~ )

                childRemovedEventRaised = true;

            end % onChildRemoved

            function onChildAdded( ~, ~ )

                childAddedEventRaised = true;

            end % onChildAdded

        end % tChangingInternalChildPropertyRaisesEvents

    end % methods ( Test, Sealed )

end % classdef