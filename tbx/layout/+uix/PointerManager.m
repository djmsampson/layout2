classdef ( Hidden, Sealed ) PointerManager < handle
    %uix.PointerManager  Pointer manager
    %
    %  A pointer manager
    
    %  Copyright 2016 The MathWorks, Inc.
    %  $Revision: 115 $ $Date: 2015-07-29 05:03:09 +0100 (Wed, 29 Jul 2015) $
    
    properties( SetAccess = private )
        Figure % figure
    end
    
    properties( Access = private )
        Setters % setters
        Pointers % pointers
        FigureDeletedListener % listener
        PointerListener % listener
        SetterFigureObservers % observers
        SetterFigureChangedListeners % listeners
        SetterDeletedListeners % listeners
    end
    
    properties( Constant, Access = private )
        Unknown = gobjects % placeholder
    end
    
    methods( Access = private )
        
        function obj = PointerManager( figure )
            %uix.PointerManager  Create pointer manager
            %
            %  m = uix.PointerManager(f) creates a pointer manager for the
            %  figure f.
            
            obj.Figure = figure;
            obj.Setters = obj.Unknown;
            obj.Pointers = {figure.Pointer};
            obj.PointerListener = event.proplistener( figure, ...
                findprop( figure, 'Pointer' ), 'PostSet', ...
                @obj.onPointerChanged );
            obj.FigureDeletedListener = event.listener( figure, ...
                'ObjectBeingDestroyed', @obj.onFigureDeleted );
            obj.SetterFigureObservers = {[]};
            obj.SetterFigureChangedListeners = {[]};
            obj.SetterDeletedListeners = {[]};
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function doSetPointer( obj, setter, pointer )
            %doSetPointer  Set pointer
            %
            %  m.doSetPointer(s,p) sets the pointer of the setter s to p.
            
            % Remove old entry
            tf = obj.Setters == setter;
            obj.Setters(tf) = [];
            obj.Pointers(tf) = [];
            obj.SetterFigureObservers(tf) = [];
            obj.SetterFigureChangedListeners(tf) = [];
            obj.SetterDeletedListeners(tf) = [];
            
            % Add new entry
            obj.Setters(end+1) = setter;
            obj.Pointers{end+1} = pointer;
            if setter == obj.Unknown
                obj.SetterFigureObservers{end+1} = [];
                obj.SetterFigureChangedListeners{end+1} = [];
                obj.SetterDeletedListeners{end+1} = [];
            else
                figureObserver = uix.FigureObserver( setter );
                obj.SetterFigureObservers{end+1} = figureObserver;
                obj.SetterFigureChangedListeners{end+1} = ...
                    event.listener( figureObserver, 'FigureChanged', ...
                    @obj.onSetterFigureChanged );
                obj.SetterDeletedListeners{end+1} = ...
                    event.listener( setter, 'ObjectBeingDestroyed', ...
                    @obj.onSetterDeleted );
            end
            
            % Set pointer
            obj.PointerListener.Enabled = false;
            obj.Figure.Pointer = pointer;
            obj.PointerListener.Enabled = true;
            
        end % doSetPointer
        
        function doUnsetPointer( obj, setter )
            %doUnsetPointer  Unset pointer
            %
            %  m.doUnsetPointer(s) unsets the pointer of the setter s.
            
            % Remove old entry
            tf = obj.Setters == setter;
            obj.Setters(tf) = [];
            obj.Pointers(tf) = [];
            obj.SetterFigureObservers(tf) = [];
            obj.SetterFigureChangedListeners(tf) = [];
            obj.SetterDeletedListeners(tf) = [];
            
            % Update pointer
            obj.PointerListener.Enabled = false;
            obj.Figure.Pointer = obj.Pointers{end};
            obj.PointerListener.Enabled = true;
            
        end % doUnsetPointer
        
    end % private methods
    
    methods
        
        function onFigureDeleted( obj, ~, ~ )
            %onFigureDeleted  Event handler
            
            % Delete pointer manager
            delete( obj )
            
        end % onFigureDeleted
        
        function onPointerChanged( obj, ~, ~ )
            %onPointerChanged  Event handler
            
            % Log as unknown setter
            obj.doSetPointer( obj.Unknown, obj.Figure.Pointer )
            
        end % onPointerChanged
        
        function onSetterFigureChanged( obj, source, ~ )
            %onSetterFigureChanged  Event handler
            
            % Unset for this setter
            obj.doUnsetPointer( source.Subject )
            
        end % onSetterFigureChanged
        
        function onSetterDeleted( obj, source, ~ )
            %onSetterDeleted  Event handler
            
            % Unset for this setter
            obj.doUnsetPointer( source )
            
        end % onSetterDeleted
        
    end % event handlers
    
    methods( Static )
        
        function setPointer( setter, pointer )
            %setPointer  Set pointer
            %
            %  uix.PointerManager.setPointer(s,p) sets the pointer of the
            %  setter s to p.
            
            % Get pointer manager
            obj = uix.PointerManager.getInstance( setter );
            
            % Set
            obj.doSetPointer( setter, pointer )
            
        end % setPointer
        
        function unsetPointer( setter )
            %unsetPointer  Unset pointer
            %
            %  uix.PointerManager.unsetPointer(s) unsets the pointer of the
            %  setter s.
            
            % Get pointer manager
            obj = uix.PointerManager.getInstance( setter );
            
            % Check setter
            assert( any( setter == obj.Setters ) && ...
                isequal( size( setter ), [1 1] ), ...
                'uix:InvalidArgument', 'Setter not found.' )
            
            % Unset
            obj.doUnsetPointer( setter )
            
        end % unsetPointer
        
        function obj = getInstance( setter )
            %getInstance  Get pointer manager
            %
            %  m = uix.PointerManager.getInstance(s) gets the pointer
            %  manager for the setter s.
            
            % Get figure
            figure = ancestor( setter, 'figure' );
            
            % Get pointer manager
            name = 'PointerManager';
            if isprop( figure, name ) % existing, retrieve
                obj = figure.( name );
            else % new, create and store
                obj = uix.PointerManager( figure );
                p = addprop( figure, name );
                p.Hidden = true;
                figure.( name ) = obj;
            end
            
        end % getInstance
        
    end % static methods
    
end % classdef