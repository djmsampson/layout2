classdef( Hidden, Sealed ) FigureObserver < handle
    
    properties( Access = private )
        Object
        PreSetListeners = event.proplistener.empty( [0 1] )
        PostSetListeners = event.proplistener.empty( [0 1] )
        OldFigure = matlab.graphics.GraphicsPlaceholder.empty( [0 0] )
    end
    
    events( NotifyAccess = private )
        FigureChanged % figure changed
    end
    
    methods
        
        function obj = FigureObserver( object )
            %uix.FigureObserver  Figure observer
            %
            %  fo = uix.FigureObserver(o) creates a figure observer for the
            %  graphics object o.  A figure observer raises an event
            %  FigureChanged when ancestor(o,'figure') changes.  o
            
            % Check
            assert( ishghandle( object ) && ...
                isequal( size( object ), [1 1] ) && ...
                ~isa( object, 'matlab.ui.Figure' ) && ...
                ~isequal( object, groot() ), 'uix.InvalidArgument', ...
                'Object must be a graphics object.' )
            
            % Store properties
            obj.Object = object;
            
            % Set up
            obj.setup()
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function setup( obj )
            %setup  Set up figure observer
            
            % Identify ancestors
            parents = obj.Object; % initialize
            while true
                parent = parents(end,:).Parent;
                if isempty( parent ) || isa( parent, 'matlab.ui.Figure' )
                    break
                else
                    parents(end+1,:) = parent; %#ok<AGROW>
                end
            end
            
            % Create listeners
            for ii = 1:numel( parents )
                parent = parents(ii);
                preSetListeners(ii,:) = event.proplistener( parent, ...
                    findprop( parent, 'Parent' ), 'PreSet', ...
                    @obj.onParentPreSet ); %#ok<AGROW>
                postSetListeners(ii,:) = event.proplistener( parent, ...
                    findprop( parent, 'Parent' ), 'PostSet', ...
                    @obj.onParentPostSet ); %#ok<AGROW>
            end
            obj.PreSetListeners = preSetListeners;
            obj.PostSetListeners = postSetListeners;
            
            % Reset old figure
            obj.OldFigure = matlab.graphics.GraphicsPlaceholder.empty( [0 0] );
            
        end % setup
        
    end % operations
    
    methods( Access = private )
        
        function onParentPreSet( obj, ~, ~ )
            
            obj.OldFigure = ancestor( obj.Object, 'figure' );
            
        end % onParentPreSet
        
        function onParentPostSet( obj, ~, ~ )
            
            % Raise event
            if ~isequal( obj.OldFigure, ancestor( obj.Object, 'figure' ) )
                notify( obj, 'FigureChanged' )
            end
            
            % Reset
            obj.setup()
            
        end % onParentPostSet
        
    end % event handlers
    
end % classdef