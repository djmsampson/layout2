classdef VBoxFlex < uix.VBox
    
    properties( SetAccess = private )
        Flex
    end
    
    methods
        
        function obj = VBoxFlex( varargin )
            
            % Split input arguments
            [mypv, notmypv] = uix.pvsplit( varargin, mfilename( 'class' ) );
            
            % Call superclass constructor
            obj@uix.VBox( notmypv{:} )
            
            % Create flex
            flex = uix.Flex( obj );
            
            % Store properties
            obj.Flex = flex;
            
            % Set properties
            if ~isempty( mypv )
                set( obj, mypv{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods( Access = protected )
        
        function transplant( obj, oldAncestors, newAncestors )
            
            obj.Flex.transplant( oldAncestors, newAncestors )
            
        end % transplant
        
    end % template methods
    
    methods( Access = ?uix.Flex )
        
        function onMousePress( obj, source, eventData )
            %onMousePress  Handler for WindowMousePress events
            
            disp onMousePress
            
        end % onMousePress
        
        function onMouseRelease( obj, source, eventData )
            %onMousePress  Handler for WindowMouseRelease events
            
            disp onMouseRelease
            
        end % onMouseRelease
        
        function onMouseMotion( obj, source, eventData )
            %onMouseMotion  Handler for WindowMouseMotion events
            
            disp onMouseMotion
            
        end % onMouseMotion
        
        function onBackgroundColorChange( obj, source, eventData )
            
            disp onBackgroundColorChange
            
        end % onBackgroundColorChange
        
    end % event handlers
    
end % classdef