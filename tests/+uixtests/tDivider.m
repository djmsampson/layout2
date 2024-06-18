classdef tDivider < glttestutilities.TestInfrastructure
    %TDIVIDER Tests for uix.Divider.

    properties ( Constant )
        % Name-value pairs.
        NameValuePairs = {
            'Units', 'pixels', ...
            'Position', [10, 10, 20, 20], ...
            'Visible', 'off', ...
            'BackgroundColor', [1, 0, 0], ...
            'HighlightColor', [0, 1, 0], ...
            'ShadowColor', [0, 0, 1], ...
            'Orientation', 'horizontal', ...
            'Markings', 10
            }
    end % properties ( Constant )

    methods ( Test, Sealed )

        function tConstructorReturnScalarObject( testCase )

            % Create a divider.
            d = uix.Divider();

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

            % Verify that resizing the divider is warning-free.
            resizer = @() set( d, 'Units', 'normalized', ...
                'Position', [0, 0, 1, 1] );
            testCase.verifyWarningFree( resizer, ...
                ['The uix.Divider object was not warning-free when ', ...
                'it was resized.'] )

        end % tResizingDividerIsWarningFree

        function tChangingOrientationIsWarningFree( testCase )

            % Create a divider.
            parent = testCase.ParentFixture.Parent;
            d = uix.Divider( 'Parent', parent );

            % Verify that changing the 'Orientation' property is
            % warning-free.
            currentOrientation = d.Orientation;
            if strcmp( currentOrientation, 'vertical' )
                newOrientation = 'horizontal';
            else
                newOrientation = 'vertical';
            end % if
            changer = @() set( d, 'Markings', 10, ...
                'Orientation', newOrientation );
            testCase.verifyWarningFree( changer, ...
                ['uix.Divider was not warning-free when its ', ...
                '''Orientation'' property was changed.'] )

        end % tChangingOrientationIsWarningFree

    end % methods ( Test, Sealed )

end % classdef