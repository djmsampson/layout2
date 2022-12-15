classdef FigureFixture < matlab.unittest.fixtures.Fixture
    %FIGUREFIXTURE Provide either a Java figure (created with the figure
    %function), or a web figure (created with the uifigure function) to act
    %as the top-level graphics parent for the components under test.
    %Alternatively, return an empty figure object (0-by-1) for testing
    %components in an unrooted state.

    properties ( SetAccess = private )
        % Top-level graphics object, acting as the parent object of the
        % component under test.
        Figure
        % Parent type, specified as a string.
        Type
    end % properties ( SetAccess = private )

    methods

        function setup( fixture )
            %SETUP Set up the fixture. Either create a new Java figure, a
            %new web figure with its "AutoResizeChildren" property set to
            %"off", or return an empty figure.

            switch fixture.Type
                case 'legacy'
                    fixture.Figure = figure();
                case 'web'
                    % Create a new web figure.
                    fixture.Figure = uifigure( ...
                        "AutoResizeChildren", "off" );
                case 'unrooted'
                    % Create an empty figure.
                    fixture.Figure = matlab.ui.Figure.empty( 0, 1 );
                otherwise
                    error( 'FigureFixture:UnrecognizedOption', ...
                        'Unrecognized figure fixture option %s.', ...
                        fixture.Type )
            end % switch/case

            % Delete the figure when the fixture is torn down.
            fixture.addTeardown( @() delete( fixture.Figure ) );

        end % setup

        function fixture = FigureFixture( type )
            %FIGUREFIXTURE Construct the fixture, given (optionally) the
            %type ('legacy', 'web', or 'unrooted'). The default fixture
            %type is 'unrooted'.

            if nargin == 1
                type = validatestring( type, ...
                    {'legacy', 'web', 'unrooted'}, ...
                    'FigureFixture', 'the parent type', 1 );
            else
                type = 'unrooted';
            end % if

            % Assign the type.
            fixture.Type = type;

            % Add the setup and teardown descriptions.
            switch fixture.Type
                case 'legacy'
                    fixture.SetupDescription = 'Create a new figure.';
                case 'web'
                    fixture.SetupDescription = ['Create a new ', ...
                        'uifigure with ''AutoResizeChildren''', ...
                        ' set to ''off''.'];
                case 'unrooted'
                    fixture.SetupDescription = ...
                        'Return an empty figure (0-by-1).';
            end % switch/case

            fixture.TeardownDescription = 'Delete the figure.';

        end % constructor

    end % methods

    methods ( Access = protected )

        function tf = isCompatible( fixture1, fixture2 )
            %ISCOMPATIBLE Determine whether two FigureFixture objects are
            %compatible.

            tf = strcmp( fixture1.Type, fixture2.Type );

        end % isCompatible

    end % methods ( Access = protected )

end % class