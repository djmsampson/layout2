classdef CardPanel < uix.CardPanel
    %uiextras.CardPanel  Show one element (card) from a list
    %
    %   obj = uiextras.CardPanel() creates a new card panel which allows
    %   selection between the different child objects contained, making the
    %   selected child fill the space available and all other children
    %   invisible. This is commonly used for creating wizards or quick
    %   switching between different views of a single data-set.
    %
    %   obj = uiextras.CardPanel(param,value,...) also sets one or more
    %   property values.
    %
    %   See the <a href="matlab:doc uiextras.CardPanel">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> p = uiextras.CardPanel( 'Parent', f, 'Padding', 5 );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'r' );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'b' );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'g' );
    %   >> p.SelectedChild = 2;
    %
    %   See also: uiextras.Panel
    %             uiextras.BoxPanel
    %             uiextras.TabPanel
    
    %   Copyright 2009-2013 The MathWorks, Inc.
    %   $Revision: 380 $ $Date: 2013-02-27 10:29:08 +0000 (Wed, 27 Feb 2013) $
    
    properties( Hidden, Access = public, Dependent )
        SelectedChild % deprecated
    end
    
    methods
        
        function obj = CardPanel( varargin )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'uiextras.CardPanel is deprecated.  Please use uix.CardPanel instead.' )
            
            % Do
            obj@uix.CardPanel( varargin{:} )
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.SelectedChild( obj )
            
            % Warn
            warning( 'uix:Deprecated', ...
                'Property ''SelectedChild'' is deprecated.  Use ''Selection'' instead.' )
            
            % Get
            value = obj.Selection;
            
        end % get.SelectedChild
        
        function set.SelectedChild( obj, value )
            
            % Warn
            warning( 'uiextras:Deprecated', ...
                'Property ''SelectedChild'' is deprecated.  Use ''Selection'' instead.' )
            
            % Set
            obj.Selection = value;
            
        end % set.SelectedChild
        
    end % accessors
    
end % classdef