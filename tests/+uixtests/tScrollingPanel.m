classdef tScrollingPanel < utilities.mixin.SharedPanelTests
    %TSCROLLINGPANEL Tests for uix.ScrollingPanel.

    properties ( TestParameter )
        % The constructor name, or class, of the component under test.
        ConstructorName = {'uix.ScrollingPanel'}
        % Name-value pair arguments to use when testing the component's
        % constructor and get/set methods.
        NameValuePairs = {{
            'Units', 'pixels', ...
            'Position', [10, 10, 400, 400], ...
            'Tag', 'Test', ...
            'Visible', 'on', ...
            'Heights', 50 * ones( 4, 1 ), ...
            'MinimumHeights', 20 * ones( 4, 1 ), ...
            'VerticalOffsets', [5; 5; 5; 0], ...
            'VerticalSteps', 5 * ones( 4, 1 ), ...
            'Widths', 50 * ones( 4, 1 ), ...
            'MinimumWidths', 20 * ones( 4, 1 ), ...
            'HorizontalOffsets', [5; 5; 5; 0], ...
            'HorizontalSteps', 5 * ones( 4, 1 ), ...
            'MouseWheelEnabled', 'on', ...
            'BackgroundColor', [1, 1, 0]
            }}
        % Properties accepting both a row vector and a column vector.
        VectorAcceptingProperties = {
            'VerticalSteps', ...
            'HorizontalSteps'
            }
    end % properties ( TestParameter )

    methods ( Test, Sealed )

        function tSettingPropertyAsRowStoresValue( ...
                testCase, ConstructorName, VectorAcceptingProperties )

            % Create the component with children.
            [component, kids] = testCase.constructComponentWithChildren( ...
                ConstructorName );

            % Set the property as a row vector.
            value = 5 * ones( 1, length( kids ) );
            component.(VectorAcceptingProperties) = value;

            % Verify that a column vector has been stored.
            testCase.verifyEqual( ...
                component.(VectorAcceptingProperties), ...
                transpose( value ), ...
                ['Setting the ''', VectorAcceptingProperties, ...
                ''' property of the ', ConstructorName, ...
                ' component as a row vector did ', ...
                'not store the value as a column vector.'] )

        end % tSettingPropertyAsRowStoresValue

        function testFillingPosition( testCase, ConstructorName )
            %testLayoutInTab  Test layout in panel
            testCase.assumeGraphicsAreRooted()

            obj = testCase.constructComponent(ConstructorName, testCase.NameValuePairs{1}{:});
            c = uicontrol( 'Parent', obj );
            testCase.verifyEqual( c.Position, [1 1 obj.Position(3:4)] )
            p = obj.Position;
            for ii = 1:8
                o = 50 * [sin( pi*ii/8 ) cos( pi*ii/8 )];
                obj.Position = p + [0 0 o];
                drawnow()
                testCase.verifyEqual( c.Position, [1 1 obj.Position(3:4)], 'AbsTol', 1e-10 )
            end
        end

        function testHorizontalPosition(testcase, ConstructorName)
            testcase.assumeGraphicsAreRooted()
            obj = testcase.constructComponent(ConstructorName);
            set( obj, 'Units', 'pixels', 'Position', [10 10 400 400] );
            c = uicontrol( 'Parent', obj );
            obj.Widths = 600;
            obj.Heights = 500;
            testcase.verifyEqual( c.Position, [1 -99 600 500] )
            obj.Position(3) = 420;
            testcase.verifyEqual( c.Position, [1 -99 600 500] )
            obj.Position(3) = 380;
            testcase.verifyEqual( c.Position, [1 -99 600 500] )
            obj.Position(3) = 400;
            testcase.verifyEqual( c.Position, [1 -99 600 500] )
            obj.HorizontalOffsets = 50;
            testcase.verifyEqual( c.Position, [-49 -99 600 500] )
            obj.Position(3) = 420;
            testcase.verifyEqual( c.Position, [-49 -99 600 500] )
            obj.Position(3) = 380;
            testcase.verifyEqual( c.Position, [-49 -99 600 500] )
            obj.Position(3) = 400;
            testcase.verifyEqual( c.Position, [-49 -99 600 500] )
            obj.Position(3) = 490;

        end

        function testMinimumWidths(testcase, ConstructorName)
            testcase.assumeGraphicsAreRooted()
            obj = testcase.constructComponent(ConstructorName);
            h = uix.HBoxFlex( 'Parent', obj, 'Padding', 10, 'Spacing', 10 );
            for ii = 1:4
                b(ii) = uicontrol( 'Parent', h, 'String', ii );
            end
            h.MinimumWidths(:) = 100;
            obj.MinimumWidths = 450;
            obj.MinimumHeights = 450;
            set( obj, 'Units', 'pixels', 'Position', [10 10 200 200] );

            testcase.verifyEqual( h.Position(3), 450 )
            testcase.verifyEqual( h.Position(4), 450 )
            for ii = 1:4
                testcase.verifyEqual( b(ii).Position(3), 100 )
            end

        end

        function testMinimumHeights(testcase, ConstructorName)
            testcase.assumeGraphicsAreRooted()
            obj = testcase.constructComponent(ConstructorName);
            v = uix.VBoxFlex( 'Parent', obj, 'Padding', 10, 'Spacing', 10 );
            for ii = 1:4
                b(ii) = uicontrol( 'Parent', v, 'String', ii );
            end
            v.MinimumHeights(:) = 100;
            obj.MinimumWidths = 450;
            obj.MinimumHeights = 450;
            set( obj, 'Units', 'pixels', 'Position', [10 10 200 200] );

            testcase.verifyEqual( v.Position(3), 450 )
            testcase.verifyEqual( v.Position(4), 450 )
            for ii = 1:4
                testcase.verifyEqual( b(ii).Position(4), 100 )
            end

        end

    end % methods ( Test, Sealed )

end % class