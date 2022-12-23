classdef ( Abstract ) TestInfrastructure < matlab.unittest.TestCase
    %TESTINFRASTRUCTURE Common test infrastructure for the GUI Layout
    %Toolbox test classes.

    properties ( ClassSetupParameter )
        % Top-level graphics parent type ('legacy'|'web'|'unrooted'). The
        % corresponding name ('JavaFigure'|'WebFigure'|'Unrooted') appears
        % in test results and diagnostics.
        ParentType = struct( 'JavaFigure', 'legacy', ...
            'WebFigure', 'web', ...
            'Unrooted', 'unrooted' )
    end % properties ( ClassSetupParameter )

    properties ( Access = protected )
        % Figure fixture, providing the top-level parent
        % graphics object for the components during the test procedures.
        % See also the ParentType class setup parameter and
        % matlab.unittest.fixtures.FigureFixture.
        FigureFixture
        % Current GUI Layout Toolbox tracking status, to be restored after
        % the tests run. Tracking will be disabled whilst the tests run.
        CurrentTrackingStatus = 'unset'
    end % properties ( Access = protected )

    methods ( TestClassSetup )

        function assumeMinimumMATLABVersion( testCase )

            % This collection of tests requires MATLAB R2014b or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2014b' )

        end % assumeMinimumMATLABVersion

        function addToolboxPath( testCase )

            % Apply a path fixture for the GUI Layout Toolbox main folder.
            % This folder (and its subfolders) needs to be on the MATLAB
            % path for the duration of the test procedure.

            % Locate the GLT folder based on the current location.
            testsFolder = fileparts( fileparts( fileparts( ...
                mfilename( 'fullpath' ) ) ) );
            projectFolder = fileparts( testsFolder );
            toolboxFolder = fullfile( projectFolder, 'tbx', 'layout' );

            % Ensure that 'layout' folder is added to the path during the
            % test procedures, and removed/restored when the tests
            % complete.
            testCase.applyFixture( matlab.unittest.fixtures...
                .PathFixture( toolboxFolder ) );

        end % addToolboxPath

        function applyFigureFixture( testCase, ParentType )

            % Apply a custom fixture to provide the top-level parent
            % graphics object for the GUI Layout Toolbox components during
            % the test procedures.
            % See also matlab.unittest.fixtures.FigureFixture

            if strcmp( ParentType, 'web' )
                % Filter all tests using a web figure graphics parent,
                % unless the MATLAB version supports the creation of
                % uicontrol objects in web figures.
                testCase.assumeMATLABVersionIsAtLeast( 'R2022a' )
            end % if

            % Create the figure fixture using the corresponding parent
            % type.
            figureFixture = matlab.unittest.fixtures...
                .FigureFixture( ParentType );
            testCase.FigureFixture = ...
                testCase.applyFixture( figureFixture );

        end % applyFigureFixture

        function disableTracking( testCase )

            % Disable GUI Layout Toolbox tracking during the test
            % procedures. Restore the previous tracking state when the
            % tests are complete.

            % Store the current tracking status.
            testCase.CurrentTrackingStatus = uix.tracking( 'query' );

            % Disable tracking for the duration of the tests.
            uix.tracking( 'off' )
            testCase.addTeardown( @restoreTrackingStatus )

            function restoreTrackingStatus()

                uix.tracking( testCase.CurrentTrackingStatus )
                testCase.CurrentTrackingStatus = 'unset';

            end % restoreTrackingStatus

        end % disableTracking

    end % methods ( TestClassSetup )

    methods ( Sealed, Access = protected )

        function assumeMATLABVersionIsAtLeast( testCase, versionString )
            %ASSUMEMATLABVERSIONISATLEAST Assume that the MATLAB version is
            %at least the version specified by versionString. This
            %assumption is used in different locations across the test
            %suite.

            % Determine the version number corresponding to the version
            % specified.
            switch versionString
                case 'R2014b'
                    versionNumber = '8.4';
                case 'R2022a'
                    versionNumber = '9.12';
                otherwise
                    error( ['AssumeMATLABVersionIsAtLeast:', ...
                        'InvalidVersionString'], ...
                        'Unsupported version string %s.', versionString )
            end % switch/case

            % Enforce that a minimum MATLAB version is required.
            testCase.assumeFalse( ...
                verLessThan( 'matlab', versionNumber ), ...
                ['This test is not applicable prior to MATLAB ', ...
                versionString, '.'] )

        end % assumeMATLABVersionIsAtLeast

        function assumeGraphicsAreRooted( testCase )

            % Assume that the component under test is rooted (i.e., there
            % is a nonempty top-level figure or uifigure ancestor).
            unrooted = strcmp( testCase.FigureFixture.Type, ...
                testCase.ParentType.Unrooted );
            testCase.assumeFalse( unrooted, ...
                'This test is not applicable to unrooted components.' )

        end % assumeGraphicsAreRooted

        function assumeGraphicsAreNotWebBased( testCase )

            % Assume that the component under test does not have a
            % top-level web figure ancestor.
            webBased = strcmp( testCase.FigureFixture.Type, ...
                testCase.ParentType.WebFigure );
            testCase.assumeFalse( webBased, ...
                ['This test is not applicable to components ', ...
                'based in web figures.'] )

        end % assumeGraphicsAreNotWebBased

        function assumeTestEnvironmentHasDisplay( testCase )

            % Check that the test environment has a display. This is
            % required for the mouse tests used for the flexible
            % containers.
            currentFolder = fileparts( mfilename( 'fullpath' ) );
            BaTFolder = fullfile( matlabroot(), 'test', ...
                'fileexchangeapps', 'GUI_layout_toolbox', 'tests' );
            inBaTFolder = strcmp( currentFolder, BaTFolder );
            testCase.assumeFalse( inBaTFolder, ...
                ['This test is not applicable in the BaT ', ...
                'environment. A display is required to run ', ...
                'the mouse tests.'] )

            % Check that the test environment is not Jenkins.
            isJenkins = ~isempty( getenv( 'JENKINS_HOME' ) );
            testCase.assumeFalse( isJenkins, ...
                ['This test is not applicable when running in ', ...
                'the Jenkins environment.'] )

        end % assumeTestEnvironmentHasDisplay

        function component = constructComponent( ...
                testCase, constructorName, varargin )

            % Construct the component under test, using the figure fixture,
            % and passing through any arguments for the component
            % constructor.
            component = feval( constructorName, ...
                'Parent', testCase.FigureFixture.Figure, varargin{:} );
            testCase.addTeardown( @() delete( component ) )

        end % constructComponent

    end % methods ( Sealed, Access = protected )

end % class