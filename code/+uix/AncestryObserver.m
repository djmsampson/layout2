classdef ( Hidden, Sealed ) AncestryObserver < handle
    
    properties( GetAccess = public, SetAccess = private )
        Subject
        Figure
        Ancestors
    end
    
    properties( Access = private )
        ParentListeners
    end
    
    events( NotifyAccess = private )
        AncestryChange
    end
    
    methods
        
        function obj = AncestryObserver( subject )
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            % Check
            assert( ishghandle( subject ) && ...
                isequal( size( subject ), [1 1] ) && ...
                ~isequal( subject, ROOT ), ...
                'uix.InvalidArgument', ...
                'Subject must be a graphics object.' )
            
            % Store properties
            obj.Subject = subject;
            
            % Force update
            obj.update()
            
        end % constructor
        
    end
    
    methods( Access = private )
        
        function update( obj )
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            % Capture old ancestors
            oldAncestors = obj.Ancestors;
            
            % Identify new ancestors
            subject = obj.Subject;
            newAncestors = uix.ancestors( subject );
            newAncestry = [newAncestors; subject];
            if isa( newAncestry(1), 'matlab.ui.Figure' )
                newFigure = newAncestry(1);
            else
                newFigure = matlab.graphics.GraphicsPlaceholder.empty( [0 0] );
            end
            
            % Create listeners
            parentListeners = event.listener.empty( [0 1] ); % initialize
            cbParentChange = @obj.onParentChange;
            for ii = 1:numel( newAncestry )
                newAncestor = newAncestry(ii);
                parentListeners(ii,:) = event.proplistener( newAncestor, ...
                    findprop( newAncestor, 'Parent' ), 'PostSet', ...
                    cbParentChange );
            end
            
            % Store properties
            obj.Figure = newFigure;
            obj.Ancestors = newAncestors;
            obj.ParentListeners = parentListeners;
            
            % Raise event
            if ~isequal( oldAncestors, newAncestors )
                notify( obj, 'AncestryChange' )
            end
            
        end % update
        
    end % methods
    
    methods
        
        function onParentChange( obj, ~, ~ )
            
            % Update
            obj.update()
            
        end % onParentChange
        
    end % event handlers
    
end % classdef