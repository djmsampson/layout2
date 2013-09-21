classdef( Hidden, Sealed ) FigureEvent < event.EventData
    %uix.FigureEvent  Event data for figure event
    %
    %  e = uix.FigureEvent(f) creates event data including the figure f.
    
    %  Copyright 2009-2013 The MathWorks, Inc.
    %  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $
    
    properties( SetAccess = private )
        Figure % figure
    end
    
    methods
        
        function obj = FigureEvent( figure )
            %uix.FigureEvent  Event data for figure event
            %
            %  e = uix.FigureEvent(f) creates event data including the
            %  figure f.
            
            % Set properties
            obj.Figure = figure;
            
        end % constructor
        
    end % structors
    
end % classdef