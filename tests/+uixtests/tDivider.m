classdef tDivider < glttestutilities.TestInfrastructure
    %TDIVIDER Tests for uix.Divider.

    properties ( Constant )
        % Name-value pairs.
        NameValuePairs = {
            'Units', 'pixels', ...
            'Position', [10, 10, 20, 20], ...
            'Visible', 'off', ...
            'Color', [1, 0, 0]
            }
    end % properties ( Constant )

    methods ( Test, Sealed )

        function tConstructorReturnScalarObject( testCase )

            % Create a divider.
            d = uix.Divider();
            testCase.addTeardown( @() delete( d ) )

            % Verify its data type and size.
            testCase.verifyClass( d, 'uix.Divider', ...
                ['The uix.Divider constructor did not return an ', ...
                'object of the expected data type.'] )
            testCase.verifySize( d, [1, 1], ...
                ['The uix.Divider constructor did not return a ', ...
                'scalar object.'] )

        end % tConstructorReturnScalarObject

        function tConstructorErrorsForInvalidArguments( testCase )

            % Verify that passing an invalid input argument throws an
            % error.
            f = @() uix.Divider( 'Invalid' );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['The uix.Divider constructor did not throw the ', ...
                'expected exception when called with invalid inputs.'] )

        end % tConstructorErrorsForInvalidArguments

        function tConstructorSetsParentCorrectly( testCase )

            % Construct the divider.
            parent = testCase.ParentFixture.Parent;
            d = uix.Divider( 'Parent', parent );
            testCase.addTeardown( @() delete( d ) )

            % Verify that the 'Parent' argument has been assigned.
            diagnostic = ['The uix.Divider constructor did not ', ...
                'assign the ''Parent'' property correctly.'];
            if isempty( parent )
                testCase.verifyEmpty( d.Parent, diagnostic )
            else
                testCase.verifySameHandle( d.Parent, parent, diagnostic )
            end % if

        end % tConstructorSetsParentCorrectly

        function tConstructorSetsNameValuePairsCorrectly( testCase )

            % Construct the divider.
            parent = testCase.ParentFixture.Parent;
            pairs = testCase.NameValuePairs;
            d = uix.Divider( 'Parent', parent, pairs{:} );
            testCase.addTeardown( @() delete( d ) )

            % Verify that the name-value pairs have been assigned.
            for k = 1 : 2 : numel( pairs )-1
                name = pairs{k};
                value = pairs{k+1};
                converter = class( value );
                actualValue = feval( converter, d.(name) );
                testCase.verifyEqual( actualValue, value, ...
                    ['The uix.Divider constructor did not assign ', ...
                    'the ''', name, ''' property correctly.'] )
            end % for

        end % tConstructorSetsNameValuePairsCorrectly

        function tIsMouseOverMethodReturnsLogicalScalar( testCase )

            % Create a divider.
            parent = testCase.ParentFixture.Parent;
            d = uix.Divider( 'Parent', parent );
            testCase.addTeardown( @() delete( d ) )

            % Invoke the isMouseOver() method, with some fake event data.
            eventData = struct( 'HitObject', 0 );
            tf = isMouseOver( d, eventData );

            % Verify that the output is a logical scalar.
            testCase.verifyClass( tf, 'logical', ...
                ['The isMouseOver() method did not return a ', ...
                'logical value.'] )
            testCase.verifySize( tf, [1, 1], ...
                ['The isMouseOver() method did not return a ', ...
                'scalar value.'] )

        end % tIsMouseOverMethodReturnsLogicalScalar

        function tResizingDividerIsWarningFree( testCase )

            % Create a divider.
            parent = testCase.ParentFixture.Parent;
            d = uix.Divider( 'Parent', parent );
            testCase.addTeardown( @() delete( d ) )

            % Verify that resizing the divider is warning-free.
            resizer = @() set( d, 'Units', 'normalized', ...
                'Position', [0, 0, 1, 1] );
            testCase.verifyWarningFree( resizer, ...
                ['The uix.Divider object was not warning-free when ', ...
                'it was resized.'] )

        end % tResizingDividerIsWarningFree

        function tDeletingNonGraphicsControl( testCase )

            % Assume that we're in one particular case.
            testCase.assumeGraphicsAreFigureBased()

            % Create a divider.
            parent = testCase.ParentFixture.Parent;
            d = uix.Divider( 'Parent', parent );
            testCase.addTeardown( @() delete( d ) )

            % Set the 'Control' property to a nongraphics value.
            d.Control = glttestutilities.ActivePositionPropertyDummy();

            % Verify that deleting the divider is warning-free.
            f = @() delete( d );
            testCase.verifyWarningFree( f, ['Deleting a uix.Divider', ...
                ' object was not warning-free.'] )

        end % tDeletingNonGraphicsControl

        function tIsMouseOverEdgeCases( testCase )

            % Assume that we're in one particular case.
            testCase.assumeGraphicsAreFigureBased()

            % Create a divider.
            parent = testCase.ParentFixture.Parent;
            d1 = uix.Divider( 'Parent', parent );
            testCase.addTeardown( @() delete( d1 ) )

            % Delete the divider.
            delete( d1 )
            f = @() d1.isMouseOver();
            testCase.verifyWarningFree( f, ['Calling the ''', ...
                'isMouseOver'' method on a deleted divider was ', ...
                'not warning-free.'] )

            % Create a divider.
            d2 = uix.Divider( 'Parent', parent );
            testCase.addTeardown( @() delete( d2 ) )

            % Call isMouseOver with fake event data.
            eventData = struct( 'HitObject', [] );
            f = @() d2.isMouseOver( eventData );
            testCase.verifyWarningFree( f, ['Calling the ''', ...
                'isMouseOver'' method on a divider with event data', ...
                ' with empty ''HitObject'' was not warning-free.'] )

            % Create a divider.
            d3 = uix.Divider( 'Parent', parent );
            testCase.addTeardown( @() delete( d3 ) )

            % Call isMouseOver with fake event data.
            eventData = struct( 'HitObject', 1 );
            f = @() d3.isMouseOver( eventData );
            testCase.verifyWarningFree( f, ['Calling the ''', ...
                'isMouseOver'' method on a divider with event data', ...
                ' with nonempty ''HitObject'' was not warning-free.'] )

            % Create a divider.
            d4 = uix.Divider( 'Parent', parent );
            testCase.addTeardown( @() delete( d4 ) )

            % Call isMouseOver with fake event data.
            eventData = struct( 'HitObject', d4.Control );
            f = @() d4.isMouseOver( eventData );
            testCase.verifyWarningFree( f, ['Calling the ''', ...
                'isMouseOver'' method on a divider with event data', ...
                'containing the internal control (container) in the ', ...
                '''HitObject'' field was not warning-free.'] )

        end % tIsMouseOverEdgeCases

    end % methods ( Test, Sealed )

end % classdef