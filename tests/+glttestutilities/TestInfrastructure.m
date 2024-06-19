classdef ( Abstract ) TestInfrastructure < matlab.unittest.TestCase
    %TESTINFRASTRUCTURE Common test infrastructure for the GUI Layout
    %Toolbox test classes.

    properties ( ClassSetupParameter )
        % Top-level graphics parent type
        % ('legacy'|'web'|'unrooted'|'panel'). The corresponding name
        % ('JavaFigure'|'WebFigure'|'Empty'|'UnparentedPanel') appears
        % in test results and diagnostics.
        ParentType = struct( 'JavaFigure', 'legacy', ...
            'WebFigure', 'web', ...
            'Empty', 'unrooted', ...
            'UnparentedPanel', 'panel' )
    end % properties ( ClassSetupParameter )

    properties ( Access = protected )
        % Parent fixture, providing the top-level parent
        % graphics object for the components during the test procedures.
        % See also the ParentType class setup parameter and
        % glttestutilities.ParentFixture.
        ParentFixture
    end % properties ( Access = protected )

    methods ( Sealed, TestClassSetup )

        function assumeMinimumMATLABVersion( testCase )

            % This collection of tests requires MATLAB R2014b or later.
            testCase.assumeMATLABVersionIsAtLeast( 'R2014b' )

        end % assumeMinimumMATLABVersion

        function clearPersistentData( ~ )

            % Clear classes and functions containing persistent data.
            clear( 'Container', 'TabPanel' )

        end % clearPersistentData

        function addToolboxPath( testCase )

            % Apply a path fixture for the GUI Layout Toolbox main folder.
            % This folder (and its subfolders) needs to be on the MATLAB
            % path for the duration of the test procedure.

            % Locate the GLT folder based on the current location.
            testsFolder = fileparts( fileparts( ...
                mfilename( 'fullpath' ) ) );
            projectFolder = fileparts( testsFolder );
            toolboxFolder = fullfile( projectFolder, 'tbx', 'layout' );

            % Ensure that 'layout' folder is added to the path during the
            % test procedures, and removed/restored when the tests
            % complete.
            testCase.applyFixture( matlab.unittest.fixtures...
                .PathFixture( toolboxFolder ) );

        end % addToolboxPath

        function applyParentFixture( testCase, ParentType )

            % Apply a custom fixture to provide the top-level parent
            % graphics object for the GUI Layout Toolbox components during
            % the test procedures.
            % See also matlab.unittest.fixtures.ParentFixture

            if strcmp( ParentType, 'web' )
                % Filter all tests using a web figure graphics parent,
                % unless the MATLAB version supports the creation of
                % uicontrol objects in web figures.
                testCase.assumeMATLABVersionIsAtLeast( 'R2022a' )
            end % if

            % Create the parent fixture using the corresponding parent
            % type.
            parentFixture = glttestutilities.ParentFixture( ParentType );
            testCase.ParentFixture = ...
                testCase.applyFixture( parentFixture );

        end % applyParentFixture

        function disableMATLABConnectorWarning( testCase )

            % When running in the new desktop environment (tested from
            % R2023b onwards), disable a warning related to MATLAB
            % Connector.
            if ~verLessThan( 'matlab', '23.2' ) && ...
                    feature( 'webui' ) %#ok<VERLESSMATLAB>
                warningID = ...
                    'MATLAB:connector:connector:ConnectorNotRunning';
                warningState = warning( 'query', warningID );
                testCase.addTeardown( @() warning( warningState ) )
                warning( 'off', warningID )
            end % if

        end % disableMATLABConnectorWarning

        function disableOpenGLWarning( testCase )

            % Disable the OpenGL software warning.
            warningID = 'MATLAB:hg:AutoSoftwareOpenGL';
            warningState = warning( 'query', warningID );
            testCase.addTeardown( @() warning( warningState ) )
            warning( 'off', warningID )

        end % disableOpenGLWarning

    end % methods ( Sealed, TestClassSetup )

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
                case 'R2015a'
                    versionNumber = '8.5';
                case 'R2015b'
                    versionNumber = '8.6';
                case 'R2016a'
                    versionNumber = '9.0';
                case 'R2016b'
                    versionNumber = '9.1';
                case 'R2017a'
                    versionNumber = '9.2';
                case 'R2017b'
                    versionNumber = '9.3';
                case 'R2018a'
                    versionNumber = '9.4';
                case 'R2018b'
                    versionNumber = '9.5';
                case 'R2019a'
                    versionNumber = '9.6';
                case 'R2019b'
                    versionNumber = '9.7';
                case 'R2020a'
                    versionNumber = '9.8';
                case 'R2020b'
                    versionNumber = '9.9';
                case 'R2021a'
                    versionNumber = '9.10';
                case 'R2021b'
                    versionNumber = '9.11';
                case 'R2022a'
                    versionNumber = '9.12';
                case 'R2022b'
                    versionNumber = '9.13';
                case 'R2023a'
                    versionNumber = '9.14';
                case 'R2023b'
                    versionNumber = '23.2';
                case 'R2024a'
                    versionNumber = '24.1';
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
            rooted = ismember( testCase.ParentFixture.Type, ...
                {testCase.ParentType.JavaFigure, ...
                testCase.ParentType.WebFigure} );
            testCase.assumeTrue( rooted, ...
                'This test is not applicable to unrooted components.' )

        end % assumeGraphicsAreRooted

        function assumeComponentHasEmptyParent( testCase )

            % Assume that the figure fixture provides an empty figure
            % parent.
            hasEmptyParent = strcmp( testCase.ParentFixture.Type, ...
                testCase.ParentType.Empty );
            testCase.assumeTrue( hasEmptyParent, ...
                ['This test is only applicable to components with ', ...
                'an empty parent.'] )

        end % assumeComponentHasEmptyParent

        function assumeGraphicsAreWebBased( testCase )

            % Assume that the component under test has a top-level web
            % figure ancestor.
            webBased = strcmp( testCase.ParentFixture.Type, ...
                testCase.ParentType.WebFigure );
            testCase.assumeTrue( webBased, ...
                ['This test is only applicable to components ', ...
                'based in web figures.'] )

        end % assumeGraphicsAreWebBased

        function assumeGraphicsAreNotWebBased( testCase )

            % Assume that the component under test does not have a
            % top-level web figure ancestor.
            webBased = strcmp( testCase.ParentFixture.Type, ...
                testCase.ParentType.WebFigure );
            testCase.assumeFalse( webBased, ...
                ['This test is not applicable to components ', ...
                'based in web figures.'] )

        end % assumeGraphicsAreNotWebBased

        function assumeJavaScriptDesktop( testCase )

            testCase.assumeMATLABVersionIsAtLeast( 'R2023b' )
            isJSD = feature( 'webui' );
            testCase.assumeTrue( isJSD, ...
                ['This test is only applicable in the new desktop ', ...
                'environment for MATLAB (the JavaScript Desktop).'] )

        end % assumeJavaScriptDesktop

        function assumeNotMac( testCase )

            % Assume that the platform is not Mac.
            testCase.assumeFalse( ismac(), ...
                'This test is not applicable on the Mac platform.' )

        end % assumeNotMac

        function assumeNotRunningOnGitHubCI( testCase )

            testCase.assumeFalse( testCase.isCodeRunningOnGitHubCI, ...
                ['This test is not applicable to code running ', ...
                'on GitHub CI.'] )

        end % assumeNotRunningOnGitHubCI

        function assumeNotRunningOnGitLabCI( testCase )

            testCase.assumeFalse( testCase.isCodeRunningOnGitLabCI, ...
                ['This test is not applicable to code running ', ...
                'on GitLab CI.'] )

        end % assumeNotRunningOnGitLabCI

        function assumeNotRunningOnCI( testCase )

            testCase.assumeFalse( testCase.isCodeRunningOnCI(), ...
                ['This test is not applicable to code running on ', ...
                'GitHub or GitLab CI.'] )

        end % assumeNotRunningOnCI

        function component = constructComponent( ...
                testCase, constructorName, varargin )

            % Construct the component under test, using the parent fixture,
            % and passing through any arguments for the component
            % constructor.
            component = feval( constructorName, ...
                'Parent', testCase.ParentFixture.Parent, varargin{:} );
            testCase.addTeardown( @() delete( component ) )

        end % constructComponent

    end % methods ( Sealed, Access = protected )

    methods ( Sealed, Static )

        function tf = isCodeRunningOnGitHubCI()

            tf = strcmp( getenv( 'GITHUB_ACTIONS' ), 'true' );

        end % isCodeRunningOnGitHubCI

        function tf = isCodeRunningOnGitLabCI()

            tf = strcmp( getenv( 'GITLAB_CI' ), 'true' );

        end % isCodeRunningOnGitLabCI

        function tf = isCodeRunningOnCI()

            tf = glttestutilities.TestInfrastructure...
                .isCodeRunningOnGitHubCI || ...
                glttestutilities.TestInfrastructure...
                .isCodeRunningOnGitLabCI;

        end % isCodeRunningOnCI

    end % methods ( Sealed, Static )

end % classdef