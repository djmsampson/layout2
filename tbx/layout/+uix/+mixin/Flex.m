classdef Flex < handle
    
    %  Copyright 2016 The MathWorks, Inc.
    %  $Revision: 1077 $ $Date: 2015-03-19 16:44:14 +0000 (Thu, 19 Mar 2015) $
    
    properties( Access = protected )
        Pointer = 'unset' % mouse pointer
        Token = -1 % mouse pointer token
    end
    
    methods
        
        function delete( obj )
            %delete  Destructor
            
            % Clean up
            if ~strcmp( obj.Pointer, 'unset' )
                obj.unsetPointer( ancestor( obj, 'figure' ) )
            end
            
        end % destructor
        
    end % structors
    
    methods( Access = protected )
        
        function setPointer( obj, figure, pointer )
            
            obj.Token = uix.PointerManager.setPointer( figure, pointer );
            obj.Pointer = pointer;
            
        end % setPointer
        
        function unsetPointer( obj, figure )
            
            uix.PointerManager.unsetPointer( figure, obj.Token );
            obj.Pointer = 'unset';
            obj.Token = -1;
            
        end % unsetPointer
        
    end % helper methods
    
end % classdef