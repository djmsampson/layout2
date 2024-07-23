classdef ( Abstract ) SharedButtonBoxTests < sharedtests.SharedContainerTests
    %SHAREDBUTTONBOXTESTS Tests common to button boxes.   

    methods ( Test, Sealed )

        function tShrinkToFitIsWarningFree( testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Verify that adding many buttons is warning-free (this will
            % call the shrink-to-fit code). Do this for each possible
            % 'HorizontalAlignment' and 'VerticalAlignment' value.
            buttonAdder = @addLotsOfButtons;
            hAlignments = {'left', 'center', 'right'};
            vAlignments = {'top', 'middle', 'bottom'};
            for k1 = 1 : numel( hAlignments )
                for k2 = 1 : numel( vAlignments )
                    delete( component.Children )
                    component.HorizontalAlignment = hAlignments{k1};
                    component.VerticalAlignment = vAlignments{k2};
                    testCase.verifyWarningFree( buttonAdder, ...
                        ['Adding many buttons to the ', ...
                        ConstructorName, ' component was not ', ...
                        'warning-free. There could ', ...
                        'be a problem in the shrink-to-fit code.'] )
                end % for k2
            end % for k1

            function addLotsOfButtons()

                for kk = 1 : 25
                    uicontrol( component )
                end % for

            end % addLotsOfButtons

        end % tShrinkToFitIsWarningFree

        function tShrinkToFitForLargeButtonsIsWarningFree( ...
                testCase, ConstructorName )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Set a large value for the button dimension.
            hComponentNames = {'uiextras.HButtonBox', 'uix.HButtonBox'};
            if ismember( ConstructorName, hComponentNames )
                % Add a tall button in HButtonBoxes.
                index = 2;
            else
                % Add a wide button in VButtonBoxes.
                index = 1;
            end % if
            component.ButtonSize(index) = 2000;

            % Verify that adding a button is warning-free.
            buttonAdder = @() uicontrol( component );
            testCase.verifyWarningFree( buttonAdder, ...
                ['Adding a tall button to the ', ConstructorName, ...
                ' component was not warning-free. There could be ', ...
                'a problem in the shrink-to-fit code.'] )

        end % tShrinkToFitForLargeButtonsIsWarningFree

        function tStringSupportForAlignmentProperties( ...
                testCase, ConstructorName )

            % Assume we are in R2016b or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2016b' )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Set the 'HorizontalAlignment' and 'VerticalAlignment'
            % properties as strings.
            diagnostic = @( prop ) ['The ', ConstructorName, ...
                ' component did not accept a string value for the ''', ...
                prop, ''' property.'];
            expectedValue = 'left';
            component.HorizontalAlignment = ...
                string( expectedValue ); %#ok<*STRQUOT>
            testCase.verifyEqual( component.HorizontalAlignment, ...
                expectedValue, diagnostic( 'HorizontalAlignment' ) )

            expectedValue = 'top';
            component.VerticalAlignment = string( expectedValue );
            testCase.verifyEqual( component.VerticalAlignment, ...
                expectedValue, diagnostic( 'VerticalAlignment' ) )

        end % tStringSupportForAlignmentProperties

        function tValidationForAlignmentProperties( testCase, ...
                ConstructorName )

            % Assume we are in R2016b or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2016b' )

            % Create a component.
            component = testCase.constructComponent( ConstructorName );

            % Define a set of invalid values for testing.
            invalidValues = {string( missing ), '', 'lift', ...
                string( 'centre' ), string( {'a', 'b'} ), ...
                reshape( 'abc', 1, 1, 3 )}; %#ok<STRCLQT>

            % Define the diagnostic message.
            diagnostic = @( prop ) ['The ', ConstructorName, ...
                ' component did not error when given an invalid ', ...
                'value for the ''', prop, ''' property.'];

            % Iterate over the invalid values and test both alignment
            % properties.
            exceptionID = 'uix:InvalidPropertyValue';
            for k = 1 : numel( invalidValues )
                value = invalidValues{k};
                f = @() set( component, 'HorizontalAlignment', value );
                testCase.verifyError( f, exceptionID, ...
                    diagnostic( 'HorizontalAlignment' ) )
                f = @() set( component, 'VerticalAlignment', value );
                testCase.verifyError( f, exceptionID, ...
                    diagnostic( 'VerticalAlignment' ) )
            end % for

        end % tValidationForAlignmentProperties

    end % methods ( Test, Sealed )

end % classdef