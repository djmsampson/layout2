classdef tLoadIcon < glttestutilities.TestInfrastructure
    %TLOADICON Tests for uix.loadIcon.

    methods ( Test, Sealed )

        function tLoadIconErrorsWithIncorrectNargin( testCase )

            % Not enough input arguments.
            f = @() uix.loadIcon();
            testCase.verifyError( f, ...
                'MATLAB:narginchk:notEnoughInputs', ...
                'uix.loadIcon has accepted zero input arguments.' )

            % Too many input arguments.
            f = @() uix.loadIcon( 0, 0, 0 );
            testCase.verifyError( f, ...
                'MATLAB:TooManyInputs', ...
                ['uix.loadIcon has accepted more ', ...
                'than two input arguments.'] )

        end % tLoadIconErrorsWithIncorrectNargin

        function tLoadIconErrorsWithMissingImage( testCase )

            % Verify that an error is thrown when a non-existent file is
            % specified.
            nonExistentImageFile = '___bananas.jpg';
            f = @() uix.loadIcon( nonExistentImageFile );
            testCase.verifyError( f, 'uix:FileNotFound', ...
                'uix.loadIcon has not errored with a missing file.' )

        end % tLoadIconErrorsWithMissingImage

        function tLoadIconAcceptsAnImageOnPath( testCase )

            % Prepare the image data.
            testImageFile = 'peppers.png';
            testImage = imread( testImageFile );
            cdata = uix.loadIcon( testImageFile );

            % Verify that the type of the output is as expected.
            testCase.verifyDoubleValue( cdata )

            % Verify that the size of the output is as expected.
            testCase.verifyOutputSize( cdata, size( testImage ) )

        end % tLoadIconAcceptsAnImageOnPath

        function tLoadIconAcceptsAnImageInResourcesFolder( testCase )

            % Prepare the image data.
            testImageFile = 'tab_NoEdge_NotSelected.png';
            testImagePath = fullfile( layoutRoot(), '+uix', ...
                'Resources', testImageFile );
            testImage = imread( testImagePath );
            cdata = uix.loadIcon( testImageFile );

            % Verify that the type of the output is as expected.
            testCase.verifyDoubleValue( cdata )

            % Verify that the size of the output is as expected.
            testCase.verifyOutputSize( cdata, size( testImage ) )

        end % tLoadIconAcceptsAnImageInResourcesFolder

        function tLoadIconAcceptsIndexedImages( testCase )

            % Prepare the image data.
            testImageFile = 'corn.tif';
            [testImage, testMap] = imread( testImageFile );
            testCase.assumeNotEmpty( testMap, ...
                'Reading the test image has produced a non-empty map.' )
            cdata = uix.loadIcon( testImageFile );

            % Verify that the type of the output is as expected.
            testCase.verifyDoubleValue( cdata )

            % Verify that the size of the output is as expected.
            actualSize = size( cdata );
            expectedSize = [size( testImage, 1 ), size( testImage, 2 ), 3];
            testCase.verifyEqual( actualSize, expectedSize, ...
                ['uix.loadIcon has returned an output ', ...
                'with the incorrect size.'] )

        end % tLoadIconAcceptsIndexedImages

        function tLoadIconAcceptsImagesWithTransparency( testCase )

            % Prepare the image data.
            currentFolder = fileparts( mfilename( 'fullpath' ) );
            parentFolder = fileparts( currentFolder );
            testImageFile = fullfile( parentFolder, ...
                '+glttestutilities', 'Icons', 'GreenTileAlpha.png' );
            testImage = imread( testImageFile );
            cdata = uix.loadIcon( testImageFile );

            % Verify that the type of the output is as expected.
            testCase.verifyDoubleValue( cdata )

            % Verify that the size of the output is as expected.
            testCase.verifyOutputSize( cdata, size( testImage ) )

            % Verify that the values are as expected.
            testCase.verifyEqual( cdata(1, 1, 1), NaN, ...
                ['uix.loadIcon has not returned NaN values ', ...
                'for green input data.'] )

        end % tLoadIconAcceptsImagesWithTransparency

        function tLoadIconAppliesGreenScreen( testCase )

            testCase.verifyCorrectImageProcessing( 'GreenTileUint8.png' )

        end % tLoadIconAppliesGreenScreen

        function tLoadIconAcceptsUnsigned16BitImages( testCase )

            testCase.verifyCorrectImageProcessing( 'GreenTileUint16.png' )

        end % tLoadIconAcceptsUnsigned16BitImages

        function tLoadIconErrorsOnUnsupportedImageType( testCase )

            % Attempt to load a binary image (an unsupported type).
            testImageFile = 'Binary.png';
            currentFolder = fileparts( mfilename( 'fullpath' ) );
            parentFolder = fileparts( currentFolder );
            testImagePath = fullfile( parentFolder, ...
                '+glttestutilities', 'Icons', testImageFile );
            f = @() uix.loadIcon( testImagePath );
            testCase.verifyError( f, 'uix:InvalidArgument', ...
                ['uix.loadIcon has not errored when ', ...
                'passed an unsupported image type.'] )

        end % tLoadIconErrorsOnUnsupportedImageType

    end % methods ( Test, Sealed )

    methods ( Access = private )

        function verifyDoubleValue( testCase, cdata )

            testCase.verifyClass( cdata, 'double', ...
                'uix.loadIcon has returned a non-double output.' )

        end % verifyDoubleValue

        function verifyOutputSize( testCase, cdata, outputSize )

            testCase.verifySize( cdata, outputSize, ...
                ['uix.loadIcon has returned an output ', ...
                'with the incorrect size.'] )

        end % verifyOutputSize

        function verifyCorrectImageProcessing( testCase, filename )

            % Prepare the image data.
            currentFolder = fileparts( mfilename( 'fullpath' ) );
            parentFolder = fileparts( currentFolder );
            testImageFile = fullfile( parentFolder, ...
                '+glttestutilities', 'Icons', filename );
            testImage = imread( testImageFile );
            cdata = uix.loadIcon( testImageFile );

            % Verify that the type of the output is as expected.
            testCase.verifyDoubleValue( cdata )

            % Verify that the size of the output is as expected.
            testCase.verifyOutputSize( cdata, size( testImage ) )

            % Verify that the values are as expected.
            testCase.verifyEqual( cdata, NaN( size( testImage ) ), ...
                ['uix.loadIcon has not applied the green screen ', ...
                'transparency method correctly.'] )

        end % verifyCorrectImageProcessing

    end % methods ( Access = private )

end % class