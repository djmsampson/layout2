classdef tLayoutRoot < matlab.unittest.TestCase
    %TLAYOUTROOT Tests for the layoutRoot function.

    methods ( Test )

        function tLayoutRootReturnsCorrectType( testCase )

            % Verify that the output variable type is char.
            folder = layoutRoot();
            testCase.verifyClass( folder, 'char', ...
                ['The layoutRoot function has not returned ', ...
                'a variable of type char.'] )

        end % tLayoutRootReturnsCorrectType

        function tLayoutRootReturnsRowVector( testCase )

            % Verify that the output variable is a row vector.
            folder = layoutRoot();
            numRows = size( folder, 1 );
            testCase.verifyEqual( numRows, 1, ...
                ['The layoutRoot function has not returned ', ...
                'a row vector.'] )

        end % tLayoutRootReturnsRowVector

        function tLayoutRootReturnsCorrectFolder( testCase )

            % Verify that the output of layoutRoot represents the correct
            % installation folder.
            installationFolder = fileparts( which( 'layoutRoot' ) );
            testCase.verifyEqual( installationFolder, layoutRoot(), ...
                ['The layoutRoot function has returned ', ...
                'an incorrect path.'] )

        end % tLayoutRootReturnsCorrectFolder

    end % methods ( Test )

end % class
