classdef PanelTests < matlab.unittest.TestCase
    %PANELTESTS Extra tests for panels

    properties ( TestParameter, Abstract )
        % The constructor name, or class, of the component under test.
        ConstructorName
    end % properties ( TestParameter, Abstract )

    properties ( TestParameter )
        failingSelection = {2.4, int32(2), [2, 3, 4], 5}
    end

    properties
        G1218142
    end

    methods ( TestClassSetup )

        function suppressWarnings( testCase )
            testCase.G1218142 = warning('off','uix:G1218142');
        end

    end

    methods ( TestClassTeardown )

        function restoreWarnings(testcase)
            warning(testcase.G1218142)
        end

    end

    methods ( Test )

        function testLayoutInPanel( testCase, ConstructorName )
            %testLayoutInTab  Test layout in panel
            obj = testCase.constructComponent(ConstructorName);

            b = uiextras.HBox( 'Parent', obj );
            testCase.verifyEqual( obj.Contents, b );
        end

        function testSelectablePanelContents( testCase, ConstructorName )
            %testChildren  Test adding and removing children
            [obj, actualContents] = testCase.constructComponentWithChildren(ConstructorName);
            testCase.assertEqual( obj.Contents, actualContents );

            obj.Selection = 2;

            % if the panel is unparented all children are automatically
            % visible, but on reparenting we need to make sure the
            % visibility is correctly set. So reparent obj at this point.
            % Make a copy of the obj to test with both figure and uifigure

            if strcmp(testCase.ParentType, 'unrooted')
                fxFig = testCase.applyFixture(matlab.unittest.fixtures.FigureFixture('legacy'));
                obj.Parent = fxFig.FigureHandle;
            end

            % Make sure the "selected" child is visible
            testCase.verifyEqual(char(obj.Contents(2).Visible), 'on');
            % Make sure the "hidden" children are invisible
            testCase.verifyEqual(char(obj.Contents(1).Visible), 'off');
            testCase.verifyEqual(char(obj.Contents(3).Visible), 'off');

        end

        function testSelectableEmptyPanelSetSelectionErrors( testCase, ConstructorName, failingSelection)
            objEmpty = testCase.constructComponent(ConstructorName);

            testCase.verifyError(@()set(objEmpty, 'Selection', failingSelection), 'uix:InvalidPropertyValue');
        end

        function testSelectableRGBPanelSetSelectionErrors(testCase, ConstructorName, failingSelection)
            [obj4Children, ~] = testCase.constructComponentWithChildren(ConstructorName);

            testCase.verifyError(@()set(obj4Children, 'Selection', failingSelection), 'uix:InvalidPropertyValue');
        end

        function testSelectablePanelSetSelectionSucceeds(testCase, ConstructorName)
            objEmpty = testCase.constructComponent(ConstructorName);
            [obj4Children, ~] = testCase.constructComponentWithChildren(ConstructorName);
            set(objEmpty, 'Selection', 0);
            set(obj4Children, 'Selection', 2);

            testCase.verifyEqual(get(objEmpty, 'Selection'), 0);
            testCase.verifyEqual(get(obj4Children, 'Selection'), 2);
        end

        function testAddInvisibleUicontrolToPanel(testCase, ConstructorName)
            % test for g1129721 where adding an invisible uicontrol to a
            % panel causes a segv.
            obj = testCase.constructComponent(ConstructorName);
            f = ancestor(obj, 'figure');
            % b1 = uicontrol('Parent', f, 'Visible', 'off');
            b1 = uicontainer('Parent', f, 'Visible', 'off');
            b1.Parent = obj; % used to crash
            testCase.verifyLength(obj.Contents, 1)
            b2 = uicontrol('Parent', f, 'Internal', true, 'Visible', 'off');
            b2.Parent = obj; % used to crash
            testCase.verifyLength(obj.Contents, 1)
            b2.Internal = false;
            testCase.verifyLength(obj.Contents, 2)
        end

    end % methods ( Test )

end % class