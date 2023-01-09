classdef tText < utilities.mixin.TestInfrastructure
    %TTEXT Tests for uix.Text.

    properties ( Constant )
        % Name-value pairs to use when testing the constructor and the
        % get/set methods.
        NameValuePairs = {
            'BackgroundColor', [1, 0, 0], ...
            'Callback', @utilities.noop, ...
            'DeleteFcn', @utilities.noop, ...
            'Enable', 'off', ...
            'FontAngle', 'italic', ...
            'FontName', 'Courier', ...
            'FontUnits', 'normalized', ...
            'FontSize', 0.5, ...
            'FontWeight', 'bold', ...
            'ForegroundColor', [1, 1, 1], ...
            'HandleVisibility', 'off', ...
            'HorizontalAlignment', 'left', ...
            'Units', 'pixels', ...
            'Position', [10, 10, 20, 20], ...
            'String', 'Text test', ...
            'Tag', 'Text test', ...
            'TooltipString', 'Text test', ...
            'UIContextMenu', [], ...
            'UserData', 'Text test', ...
            'VerticalAlignment', 'middle', ...
            'Visible', 'off'
            }
    end % properties ( Constant )

    methods ( TestClassSetup )

        function clearText( ~ )

            % Clear uix.Text from memory so that Constant properties are
            % reloaded during the test process.
            evalin( 'base', 'clear( ''Text'' )' )

        end % clearText

    end % methods ( TestClassSetup )

    methods ( Test, Sealed )

        function tConstructorReturnsScalarObject( testCase )

            % Create an object.
            fig = testCase.FigureFixture.Figure;
            t = uix.Text( 'Parent', fig );

            % Verify that the output is scalar.
            testCase.verifySize( t, [1, 1], ...
                ['The uix.Text constructor did not return a ', ...
                'scalar object.'] )

        end % tConstructorReturnsScalarObject

        function tConstructorErrorsForInvalidInput( testCase )

            % Verify that calling the constructor with invalid arguments
            % results in an error.
            f = @() uix.Text( 'Parent' );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['The uix.Text constructor did not issue an exception', ...
                ' with ID uix:InvalidArgument when called with ', ...
                'invalid arguments.'] )

        end % tConstructorErrorsForInvalidInput

        function tConstructorAssignsNameValuePairs( testCase )

            % Create an object.
            fig = testCase.FigureFixture.Figure;
            pairs = testCase.NameValuePairs;
            t = uix.Text( 'Parent', fig, pairs{:} );

            % Verify that each name-value pair has been set correctly.
            for k = 1 : 2 : length( pairs )-1
                name = pairs{k};
                value = pairs{k+1};
                expectedType = class( value );
                actualValue = t.(name);
                if ~isa( value, 'function_handle' )
                    actualValue = feval( expectedType, actualValue );
                end % if
                testCase.verifyEqual( actualValue, value, ...
                    ['The uix.Text constructor has not assigned ', ...
                    'the ''', name, ''' property correctly.'] )
            end % for

        end % tConstructorAssignsNameValuePairs

        function tGetBeingDeletedReturnsCorrectValue( testCase )

            % Create an object.
            fig = testCase.FigureFixture.Figure;
            t = uix.Text( 'Parent', fig );

            % Verify that 'BeingDeleted' is either 'on' or 'off'.
            beingDeleted = char( t.BeingDeleted );
            testCase.verifyMatches( beingDeleted, '(on|off)', ...
                ['The ''BeingDeleted'' property of uix.Text ', ...
                'is neither ''on'' nor ''off''.'] )

        end % tGetBeingDeletedReturnsCorrectValue

        function tGetExtentReturnsCorrectValue( testCase )

            % Create an object.
            fig = testCase.FigureFixture.Figure;
            t = uix.Text( 'Parent', fig );

            % Verify that 'Extent' is a 4-element numeric vector containing
            % nonnegative values.
            extent = t.Extent;
            testCase.verifyClass( extent, 'double', ...
                ['The ''Extent'' property of uix.Text is not of ', ...
                'type double.'] )
            testCase.verifySize( extent, [1, 4], ...
                ['The ''Extent'' property of uix.Text is not a ', ...
                '1-by-4 vector.'] )
            testCase.verifyGreaterThanOrEqual( extent, 0, ...
                ['The elements of the ''Extent'' property of ', ...
                'uix.Text are not all greater than or equal to zero.'] )

        end % tGetExtentReturnsCorrectValue

        function tGetTypeReturnsCorrectValue( testCase )

            % Create an object.
            fig = testCase.FigureFixture.Figure;
            t = uix.Text( 'Parent', fig );

            % Verify the 'Type' property is correct.
            testCase.verifyEqual( t.Type, 'uicontrol', ...
                ['The ''Type'' property of uix.Text is not ', ...
                '''uicontrol''.'] )

        end % tGetTypeReturnsCorrectValue

        function tRedrawOccursWhenComponentIsRooted( testCase )

            % Create an unrooted object, and dirty it.
            t = uix.Text( 'Parent', [], 'FontAngle', 'italic' );
            testCase.addTeardown( @() delete( t ) )

            % Reparent the object.
            fig = figure();
            testCase.addTeardown( @() delete( fig ) )
            t.Parent = fig;

            % Verify that the property has been updated.
            testCase.verifyEqual( t.FontAngle, 'italic', ...
                ['Parenting a uix.Text object from the unrooted ', ...
                'state did not trigger a redraw.'] )

        end % tRedrawOccursWhenComponentIsRooted

        function tSettingHorizontalAlignmentTriggersRedraw( testCase )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Create an object.
            fig = testCase.FigureFixture.Figure;
            t = uix.Text( 'Parent', fig );

            % Set the 'HorizontalAlignment' property.
            hAlignments = {'left', 'center', 'right'};
            for k = 1 : length( hAlignments )
                t.HorizontalAlignment = hAlignments{k};
                testCase.verifyEqual( t.HorizontalAlignment, ...
                    hAlignments{k}, ...
                    ['Setting the ''HorizontalAlignment'' property ', ...
                    'on a uix.Text object did not trigger a redraw.'] )
            end % for

        end % tSettingHorizontalAlignmentTriggersRedraw

        function tSettingVerticalAlignmentTriggersRedraw( testCase )

            % Assume that the graphics are rooted.
            testCase.assumeGraphicsAreRooted()

            % Create an object.
            fig = testCase.FigureFixture.Figure;
            t = uix.Text( 'Parent', fig );

            % Set the 'VerticalAlignment' property.
            vAlignments = {'bottom', 'middle', 'top'};
            for k = 1 : length( vAlignments )
                t.VerticalAlignment = vAlignments{k};
                testCase.verifyEqual( t.VerticalAlignment, ...
                    vAlignments{k}, ...
                    ['Setting the ''VerticalAlignment'' property ', ...
                    'on a uix.Text object did not trigger a redraw.'] )
            end % for

        end % tSettingVerticalAlignmentTriggersRedraw

    end % methods ( Test, Sealed )

end % class