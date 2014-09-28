classdef Container < matlab.ui.container.internal.UIContainer & uix.mixin.Container
    
    %  Copyright 2009-2013 The MathWorks, Inc.
    %  $Revision$ $Date$
    
    methods
        
        function obj = Container( varargin )
            
            % Call superclass constructors
            obj@matlab.ui.container.internal.UIContainer()
            obj@uix.mixin.Container()
            
            % Set properties
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
    end % structors
    
end % classdef