classdef ChildEvent < event.EventData
    
    properties( GetAccess = public, SetAccess = private )
        Child        
    end
    
    methods
        
        function obj = ChildEvent( child )
            
            % Set properties            
            obj.Child = child;
            
        end % constructor
        
    end % methods
    
end % classdef