classdef Container < matlab.ui.container.internal.UIContainer
    %uix.Container  Container base class
    %
    %  uix.Container is base class for containers that extend uicontainer.
    
    %  Copyright 2009-2015 The MathWorks, Inc.
    %  $Revision$ $Date$
    
    methods
        
        function obj = Container()
            %uix.Container  Initialize
            %
            %  c@uix.Container() initializes the container c.
            
            % Call superclass constructor
            obj@matlab.ui.container.internal.UIContainer()
            
        end % constructor
        
    end % structors
    
end % classdef