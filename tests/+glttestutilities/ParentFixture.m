classdef ParentFixture < matlab.unittest.fixtures.Fixture
    %PARENTFIXTURE Provide either a Java figure (created with the figure
    %function), a web figure (created with the uifigure function), an empty
    %figure object (0-by-1), or an unparented panel to act as the top-level
    %graphics parent for the components under test.

    properties ( SetAccess = private )
        % Top-level graphics object, acting as the parent object of the
        % component under test.
        Parent
        % Parent type, specified as a string.
        Type
    end % properties ( SetAccess = private )

    methods

        function setup( fixture )
            %SETUP Set up the fixture. Either create a new Java figure, a
            %new web figure with its 'AutoResizeChildren' property set to
            %'off', an empty figure, or an unrooted panel.

            switch fixture.Type
                case 'legacy'
                    fixture.Parent = figure();
                case 'web'
                    % Create a new web figure.
                    fixture.Parent = uifigure( ...
                        'AutoResizeChildren', 'off' );
                case 'unrooted'
                    % Create an empty figure.
                    fixture.Parent = matlab.ui.Figure.empty( 0, 1 );
                case 'panel'
                    fixture.Parent = uipanel( 'Parent', [] );
                otherwise
                    error( 'ParentFixture:UnrecognizedOption', ...
                        'Unrecognized parent fixture option %s.', ...
                        fixture.Type )
            end % switch/case

            % Delete the parent when the fixture is torn down.
            fixture.addTeardown( @() delete( fixture.Parent ) );

        end % setup

        function fixture = ParentFixture( type )
            %PARENTFIXTURE Construct the fixture, given (optionally) the
            %type ('legacy', 'web', 'unrooted', or 'panel'). The default
            %fixture type is 'unrooted'.

            if nargin == 1
                type = validatestring( type, ...
                    {'legacy', 'web', 'unrooted', 'panel'}, ...
                    'ParentFixture', 'the parent type', 1 );
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
                case 'panel'
                    fixture.SetupDescription = ...
                        'Create an unparented panel.';
            end % switch/case

            fixture.TeardownDescription = 'Delete the parent graphics.';

        end % constructor

    end % methods

    methods ( Access = protected )

        function tf = isCompatible( fixture1, fixture2 )
            %ISCOMPATIBLE Determine whether two ParentFixture objects are
            %compatible.

            tf = strcmp( fixture1.Type, fixture2.Type );

        end % isCompatible

    end % methods ( Access = protected )

end % classdef