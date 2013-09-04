classdef TerminalNode < uix.AbstractNode
    
    methods
        
        function obj = TerminalNode( object, nodeFactory )
            
            % Store properties
            obj.Object = object;
            obj.NodeFactory = nodeFactory;
            
            % Set children
            obj.Children = uix.TerminalNode.empty( [0 1] );
            
            % Add listeners
            if ishghandle( object )
                obj.Listeners(end+1,:) = event.proplistener( object, ...
                    findprop( object, 'HandleVisibility' ), 'PostSet', ...
                    @obj.onVisibilityChanged );
            end
            
        end % constructor
        
    end % structors
    
end % classdef