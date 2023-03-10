classdef tNode < glttestutilities.TestInfrastructure
    %TNODE Tests for uix.Node.

    methods ( Test, Sealed )

        function tConstructorReturnsScalarObject( testCase )

            % Create a node.
            N = testCase.createNode();

            % Verify the type and size of the constructor output.
            testCase.verifyClass( N, 'uix.Node', ...
                ['The uix.Node constructor did not return an ', ...
                ' object of the expected type.'] )
            testCase.verifySize( N, [1, 1], ...
                ['The uix.Node constructor did not return a ', ...
                'scalar object.'] )

        end % tConstructorReturnsScalarObject

        function tConstructorStoresInputObject( testCase )

            % Create a node.
            [N, fig] = testCase.createNode();

            % Verify that the figure was stored.
            testCase.verifySameHandle( N.Object, fig, ...
                ['The uix.Node constructor did not assign the ', ...
                'input graphics object to its ''Object'' property ', ...
                'correctly.'] )

        end % tConstructorStoresInputObject

        function tAddChildErrorsForInvalidInput( testCase )

            % Create a node.
            N = testCase.createNode();

            % The non-Node case.
            f = @() N.addChild( 0 );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['The addChild() method of uix.Node did not ', ...
                'error when passed a non-Node input.'] )

            % The non-scalar case.
            f = @() N.addChild( [N, N] );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['The addChild() method of uix.Node did not ', ...
                'error when passed a non-scalar Node input.'] )

        end % tAddChildErrorsForInvalidInput

        function tAddChildStoresChild( testCase )

            % Create a node with a child.
            [N, newNode] = testCase.createNodeWithChild();

            % Verify that the 'Children' property has been updated.
            testCase.verifySameHandle( N.Children, newNode )

        end % tAddChildStoresChild

        function tRemoveChildErrorsForInvalidInput( testCase )

            % Create a node.
            N = testCase.createNode();

            % The non-Node case.
            f = @() N.removeChild( 0 );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['The removeChild() method of uix.Node did not ', ...
                'error when passed a non-Node input.'] )

            % The non-scalar case.
            f = @() N.removeChild( [N, N] );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['The removeChild() method of uix.Node did not ', ...
                'error when passed a non-scalar input.'] )

            % The case when the candidate node is not a member of the
            % existing children.
            ax = axes( 'Parent', [] );
            testCase.addTeardown( @() delete( ax ) )
            extraNode = uix.Node( ax );
            f = @() N.removeChild( extraNode );
            testCase.verifyError( f, 'uix:ItemNotFound', ...
                ['The removeChild() method of uix.Node did not ', ...
                'error when passed a node that was not already ', ...
                'a child.'] )

        end % tRemoveChildErrorsForInvalidInput

        function tRemoveChildRemovesChild( testCase )

            % Create a node with a child.
            [N, newNode] = testCase.createNodeWithChild();

            % Remove the child.
            N.removeChild( newNode )

            % Verify that the 'Children' property has been updated.
            testCase.verifyEqual( N.Children, uix.Node.empty( 0, 1 ), ...
                ['The removeChild() method of uix.Node did not ', ...
                'remove the specified child from the ', ...
                '''Children'' property.'] )

        end % tRemoveChildRemovesChild

        function tDeletingChildRemovesChild( testCase )

            % Create a node with a child.
            [N, newNode] = testCase.createNodeWithChild();

            % Delete the new node.
            delete( newNode )

            % Verify that the 'Children' property has been updated.
            testCase.verifyEqual( N.Children, uix.Node.empty( 0, 1 ), ...
                ['Deleting a child referenced by uix.Node did not ', ...
                'remove the specified child from the ', ...
                '''Children'' property.'] )




        end % tDeletingChildRemovesChild


    end % methods ( Test, Sealed )

    methods ( Access = private )

        function [N, fig] = createNode( testCase )

            % Assume we are in the rooted case.
            testCase.assumeGraphicsAreRooted()

            % Create a node.
            fig = testCase.ParentFixture.Parent;
            N = uix.Node( fig );

        end % createNode

        function [N, newNode] = createNodeWithChild( testCase )

            N = testCase.createNode();

            % Add a child node.
            ax = axes( 'Parent', [] );
            testCase.addTeardown( @() delete( ax ) )
            newNode = uix.Node( ax );
            N.addChild( newNode )

        end % createNodeWithChild

    end % methods ( Access = private )

end % class