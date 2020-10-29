classdef tCardPanel < ContainerSharedTests ...
        & PanelTests
    %TCARDPANEL unit tests for uiextras.CardPanel
    
    properties (TestParameter)
        ContainerType   = {'uiextras.CardPanel'};
        GetSetArgs = {
            {'BackgroundColor', [1 1 0], ...
            'SelectedChild',   2 ...
            }};
        ConstructorArgs = {
            {'Units',           'pixels', ...
            'Position',        [10 10 400 400], ...
            'Padding',         5, ...
            'Tag',             'Test', ...
            'Visible',         'on', ...
            }};
    end
    
    methods (Test)
        
       function testSelectionBehaviourNewChild(testcase)
            % g1342432 Tests that adding a new child changes current selection to
            % new child
            testcase.assumeFalse(strcmp(testcase.parentStr,'[]'),...
                'Not applicable to unparented.');
            % Create a CardPanel with two panels
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            fig = fx.FigureHandle;
            
            cp = uix.CardPanel('Parent',fig);
            c1 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'r' );
            c2 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'g' );
            % Add new third panel
            c3 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'b' );
            % Test that the third panel is now selected
            testcase.verifyEqual(3, cp.Selection);
        end
        
        function testSelectionBehaviourDeleteLowerChild(testcase)
            % g1342432 Tests that deleting a child with a lower index than the
            % current selection causes the selection index to decrease by 1
            testcase.assumeFalse(strcmp(testcase.parentStr,'[]'),...
                'Not applicable to unparented.');
            % Create a CardPanel with two panels
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            fig = fx.FigureHandle;
            % Create a CardPanel with three panels
            cp = uix.CardPanel('Parent',fig);
            c1 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'r' );
            c2 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'g' );
            c3 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'b' );
            % Select the 2nd child, then delete the first
            cp.Selection = 2; 
            oldSelection = cp.Selection;
            delete(c1)
            
            testcase.verifyEqual(oldSelection - 1, cp.Selection);
        end
        
        function testSelectionBehaviourDeleteSelectedChild(testcase)
            % g1342432 Tests that deleting the currently selected child
            % causes the selection index to stay the same. 
            testcase.assumeFalse(strcmp(testcase.parentStr,'[]'),...
                'Not applicable to unparented.');
            % Create a CardPanel with two panels
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            fig = fx.FigureHandle;
            % Create a CardPanel with three panels
            cp = uix.CardPanel('Parent',fig);
            c1 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'r' );
            c2 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'g' );
            c3 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'b' );
            % Select the 2nd child, then delete the 1st
            cp.Selection = 2; 
            oldSelection = cp.Selection;
            delete(c2)
            
            testcase.verifyEqual(oldSelection, cp.Selection);
        end
        
        function testSelectionBehaviourDeleteOnlyChild(testcase)
            % g1342432 Tests that deleting the only child
            % causes the selection index to go to 0. 
            testcase.assumeFalse(strcmp(testcase.parentStr,'[]'),...
                'Not applicable to unparented.');
            % Create a CardPanel with two panels
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            fig = fx.FigureHandle;
            % Create a CardPanel with a single panel
            cp = uix.CardPanel('Parent',fig);
            c1 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'r' );
            % Ensure that the 1st child is selected. 
            cp.Selection = 1; 
            delete(c1)
            
            testcase.verifyEqual(0, cp.Selection);
        end
        
        function testSelectionBehaviourDeleteHigherChild(testcase)
            % g1342432 Tests that deleting a child with a higher index than the
            % current selection causes the selection index remain same. 
            testcase.assumeFalse(strcmp(testcase.parentStr,'[]'),...
                'Not applicable to unparented.');
            % Create a CardPanel with two panels
            fx = testcase.applyFixture(FigureFixture(testcase.parentStr));
            fig = fx.FigureHandle;
            % Create a CardPanel with three panels
            cp = uix.CardPanel('Parent',fig);
            c1 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'r' );
            c2 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'g' );
            c3 = uicontrol( 'Style', 'frame', 'Parent', cp, 'Background', 'b' );
            % Select the 2nd child, then delete the 3rd
            cp.Selection = 2; 
            oldSelection = cp.Selection;
            delete(c3)
            
            testcase.verifyEqual(oldSelection, cp.Selection);
        end
        
        
    end
    
end