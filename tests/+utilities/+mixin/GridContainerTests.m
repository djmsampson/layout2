classdef ( Abstract ) GridContainerTests < utilities.mixin.ContainerTests
    %GRIDCONTAINERTESTS Additional tests common to all grid containers.

    methods ( Test, Sealed )

        function tAddingChildUpdatesGridContents( ...
                testCase, ConstructorName )

            % Create the grid.
            [component, kids] = testCase...
                .createGridWithChildren( ConstructorName );

            % Add a new child.
            newKid = uicontrol( component );

            % Verify that the 'Contents' property has been updated.
            testCase.verifyEqual( component.Contents, [kids; newKid], ...
                ['Adding a new child to the ', ConstructorName, ...
                ' component did not update the ''Contents'' property ', ...
                'correctly.'] )
            
        end % tAddingChildUpdatesGridContents

        function tRemovingChildUpdatesGridContents( ...
                testCase, ConstructorName )

            % Create the grid.
            [component, kids] = testCase...
                .createGridWithChildren( ConstructorName );

            % Remove a child.
            delete( kids(5) )

            % Verify that the 'Contents' property has been updated.
            testCase.verifyEqual( component.Contents, kids([1:4, 6]), ...
                ['Removing a child from the ', ConstructorName, ...
                ' component did not update the ''Contents'' property ', ...
                'correctly.'] )

        end % tRemovingChildUpdatesGridContents

        function tReparentingChildUpdatesGridContents( ...
                testCase, ConstructorName )

            % Create the grid.
            [component, kids] = testCase...
                .createGridWithChildren( ConstructorName );

            % Reparent a child.
            kids(5).Parent = [];
            testCase.addTeardown( @() delete( kids(5) ) )

            % Verify that the 'Contents' property has been updated.
            testCase.verifyEqual( component.Contents, kids([1:4, 6]), ...
                ['Reparenting a child from the ', ConstructorName, ...
                ' component did not update the ''Contents'' property ', ...
                'correctly.'] )

        end % tReparentingChildUpdatesGridContents

    end % methods ( Test, Sealed )

    methods ( Sealed, Access = protected )

        function [component, kids] = createGridWithChildren( ...
                testCase, ConstructorName )

            % Create the component.
            component = testCase.constructComponent( ConstructorName );

            % Add six controls.
            kids = gobjects( 6, 1 );
            for k = 1 : length( kids )
                kids(k) = uicontrol( 'Parent', component );
            end % for

            % Reshape the grid to be 2-by-3.
            set( component, 'RowSizes', [-1, 200], ...
                'ColumnSizes', [-1, 100, 1] )

        end % createGridWithChildren

    end % methods ( Sealed, Access = protected )

end % class