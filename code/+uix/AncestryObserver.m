classdef ( Hidden, Sealed ) AncestryObserver < handle
    
    properties( GetAccess = public, SetAccess = private )
        Subject
        Ancestors
    end
    
    properties( Access = private )
        ParentListeners
    end
    
    events( NotifyAccess = private )
        AncestryPreChange
        AncestryPostChange
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
            
            % Identify new ancestors
            subject = obj.Subject;
            newAncestors = uix.ancestors( subject );
            newAncestry = [newAncestors; subject];
            
            % Create listeners
            preListeners = event.listener.empty( [0 1] ); % initialize
            postListeners = event.listener.empty( [0 1] ); % initialize
            cbPreChange = @obj.onPreChange;
            cbPostChange = @obj.onPostChange;
            for ii = 1:numel( newAncestry )
                ancestor = newAncestry(ii);
                preListeners(ii,:) = event.proplistener( ancestor, ...
                    findprop( ancestor, 'Parent' ), 'PreSet', cbPreChange );
                postListeners(ii,:) = event.proplistener( ancestor, ...
                    findprop( ancestor, 'Parent' ), 'PostSet', cbPostChange );
            end
            
            % Store properties
            obj.Ancestors = newAncestors;
            obj.ParentListeners = [preListeners postListeners];
            
        end % update
        
    end % methods
    
    methods
        
        function onPreChange( obj, ~, ~ )
            
            % Raise event
            notify( obj, 'AncestryPreChange' )
            
        end % onPreChange
        
        function onPostChange( obj, ~, ~ )
            
            % Update
            obj.update()
            
            % Raise event
            notify( obj, 'AncestryPostChange' )
            
        end % onPostChange
        
    end % event handlers
    
end % classdef