classdef TerminalNode < uix.AbstractNode
    
    methods
        
        function obj = TerminalNode( object, nodeFactory )
            
            % Store properties
            obj.Object = object;
            obj.NodeFactory = nodeFactory;
            
            % Set children
            obj.Children = uix.TerminalNode.empty( [0 1] );
            
        end % constructor
        
    end % structors
    
end % classdef