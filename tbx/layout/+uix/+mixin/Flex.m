classdef Flex < handle
    %uix.mixin.Flex  Flex mixin
    %
    %  uix.mixin.Flex is a mixin class used by flex containers to provide
    %  various properties and helper methods methods.
    
    %  Copyright 2016 The MathWorks, Inc.
    %  $Revision: 1077 $ $Date: 2015-03-19 16:44:14 +0000 (Thu, 19 Mar 2015) $
    
    properties( Access = protected )
        Figure = gobjects( 0 ); % mouse pointer figure
        Pointer = 'unset' % mouse pointer
        Token = -1 % mouse pointer token
    end
    
    methods
        
        function delete( obj )
            %delete  Destructor
            
            % Clean up
            if ~strcmp( obj.Pointer, 'unset' )
                obj.unsetPointer()
            end
            
        end % destructor
        
    end % structors
    
    methods( Access = protected )
        
        function setPointer( obj, figure, pointer )
            %setPointer  Set pointer
            %
            %  c.setPointer(f,p) sets the pointer for the figure f to p.
            
            obj.Token = uix.PointerManager.setPointer( figure, pointer );
            obj.Figure = figure;
            obj.Pointer = pointer;
            
        end % setPointer
        
        function unsetPointer( obj )
            %unsetPointer  Unset pointer
            %
            %  c.unsetPointer() undoes the previous pointer set.
            
            uix.PointerManager.unsetPointer( obj.Figure, obj.Token );
            obj.Figure = gobjects( 0 );
            obj.Pointer = 'unset';
            obj.Token = -1;
            
        end % unsetPointer
        
    end % helper methods
    
end % classdef