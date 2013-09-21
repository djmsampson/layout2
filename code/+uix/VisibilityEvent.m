classdef( Hidden, Sealed ) VisibilityEvent < event.EventData
    %uix.VisibilityEvent  Event data for visibility event
    %
    %  e = uix.VisibilityEvent(v) creates event data including the
    %  visibility v.
    
    %  Copyright 2009-2013 The MathWorks, Inc.
    %  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $
    
    properties( SetAccess = private )
        Visible % visibility
    end
    
    methods
        
        function obj = VisibilityEvent( visible )
            %uix.VisibilityEvent  Event data for visibility event
            %
            %  e = uix.VisibilityEvent(v) creates event data including the
            %  visibility v.
            
            % Set properties
            obj.Visible = visible;
            
        end % constructor
        
    end % structors
    
end % classdef