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
            
            % Check
            assert( ishghandle( subject ) && ...
                isequal( size( subject ), [1 1] ) && ...
                ~isa( subject, 'matlab.ui.Root' ), ...
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
            
            % Capture old ancestors
            oldAncestors = obj.Ancestors;
            
            % Identify new ancestors
            subject = obj.Subject;
            [newAncestors, figure] = uix.ancestors( subject );
            
            % Create listeners
            listeners = event.proplistener.empty( [0 1] ); % initialize
            for ii = 1:numel( newAncestors )
                newAncestor = newAncestors(ii);
                listeners(end+1,:) = event.proplistener( newAncestor, ...
                    findprop( newAncestor, 'Parent' ), 'PostSet', ...
                    @obj.onParentChange ); %#ok<AGROW>
            end
            listeners(end+1,:) = event.proplistener( subject, ...
                findprop( subject, 'Parent' ), 'PostSet', ...
                @obj.onParentChange );
            
            % Store properties
            obj.Figure = figure;
            obj.Ancestors = newAncestors;
            obj.ParentListeners = listeners;
            
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