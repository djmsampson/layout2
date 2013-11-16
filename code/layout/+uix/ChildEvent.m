classdef( Hidden, Sealed ) ChildEvent < event.EventData
    %uix.ChildEvent  Event data for child event
    %
    %  e = uix.ChildEvent(c) creates event data including the child c.
    
    %  Copyright 2009-2013 The MathWorks, Inc.
    %  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $
    
    properties( SetAccess = private )
        Child % child
    end
    
    methods
        
        function obj = ChildEvent( child )
            %uix.ChildEvent  Event data for child event
            %
            %  e = uix.ChildEvent(c) creates event data including the child
            %  c.
            
            % Set properties
            obj.Child = child;
            
        end % constructor
        
    end % structors
    
end % classdef