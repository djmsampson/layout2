classdef Container < matlab.ui.container.internal.UIContainer & uix.mixin.Container
    %uix.Container  Container base class
    %
    %  uix.Container is a uicontainer with numerous properties and template
    %  methods mixed in that serves as a base class for most GUI Layout
    %  Toolbox containers.
    
    %  Copyright 2009-2014 The MathWorks, Inc.
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