classdef Box < uix.Container & uix.mixin.Container
    %uix.Box  Box and grid base class
    %
    %  uix.Box is a base class for containers with spacing between
    %  contents.
    
    %  Copyright 2009-2015 The MathWorks, Inc.
    %  $Revision$ $Date$
    
    properties( Access = public, Dependent, AbortSet )
        Spacing = 0 % space between contents, in pixels
    end
    
    properties( Access = protected )
        Spacing_ = 0 % backing for Spacing
    end
    
    properties( GetAccess = public, SetAccess = private )
        MinimumTotalWidth = 0;
        MinimumTotalHeight = 0;
    end
    
    methods
        
        function value = get.Spacing( obj )
            
            value = obj.Spacing_;
            
        end % get.Spacing
        
        function set.Spacing( obj, value )
            
            % Check
            assert( isa( value, 'double' ) && isscalar( value ) && ...
                isreal( value ) && ~isinf( value ) && ...
                ~isnan( value ) && value >= 0, ...
                'uix:InvalidPropertyValue', ...
                'Property ''Spacing'' must be a non-negative scalar.' )
            
            % Set
            obj.Spacing_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Spacing
        
    end % accessors
    
    methods ( Access = protected )
    
        function updateMinimumTotalHeight( obj )
            % updateMinimumTotalHeight  Updates MinimumTotalHeight property
            %
            % See if this object has children with a MinimumHeights property
            minHeightChildren = arrayfun( @(x) ...
                isa( x, 'uix.VBox' ) || isa( x, 'uix.Grid' ), obj.Children );

            tempMinimumTotalHeight = 0;
            
            % Loop through children
            if any( minHeightChildren )
                for ii = 1:numel( minHeightChildren )                    
                    if true( minHeightChildren(ii) )
                        % Update this child's total minimum height
                        obj.Children(ii).updateMinimumTotalHeight;
                                                
                        % All lower tier children should be updated so get 
                        % the total for that tier
                        tempMinimumTotalHeight = tempMinimumTotalHeight ...
                            + obj.Children(ii).MinimumTotalHeight;
                    else
                        tempMinimumTotalHeight = tempMinimumTotalHeight + ...
                            obj.MinimumHeights(ii);
                    end
                end
            end
            
            % Check whether the sum of my MinimumHeights is greater than 
            % the sum of my children's TotalMinimumHeights
            if sum( obj.MinimumHeights ) < tempMinimumTotalHeight
                obj.MinimumTotalHeight = tempMinimumTotalHeight;
            else
                obj.MinimumTotalHeight = sum( obj.MinimumHeights );
            end
            
            % Now, propagate upstream
            obj.checkParentMinimumTotalHeight;
                      
        end % end updateMinimumTotalHeight
        
        
        function checkParentMinimumTotalHeight( obj )
            % checkParentMinimumTotalHeight  Propogates MinimumTotalHeight
            % upstream
            %
            % See if this object has a parent with a MinimumHeights property
            if isa( obj.Parent, 'uix.Box')
                if isa( obj.Parent, 'uix.HBox' )
                    % if parent is an HBox (no heights), pass through
                    obj.Parent.MinimumTotalHeight = obj.MinimumTotalHeight;
                    
                    % Go upstream
                    obj.Parent.checkParentMinimumTotalHeight;
                else
                    % Loop through parent's children and sum up min Heights
                    tempMinimumTotalHeight = 0;
                    for ii = 1:numel( obj.Parent.MinimumHeights )
                        if isa( obj.Parent.Children(ii), 'uix.Box' )
                            tempMinimumTotalHeight = tempMinimumTotalHeight + ...
                                obj.Parent.Children(ii).MinimumTotalHeight;
                        else
                            tempMinimumTotalHeight = tempMinimumTotalHeight + ...
                                obj.Parent.MinimumHeights(ii);
                        end
                    end
                    
                    % Check whether the sum of my MinimumHeights is greater than
                    % the sum of my children's TotalMinimumHeights
                    if sum( obj.Parent.MinimumHeights ) < tempMinimumTotalHeight
                        obj.Parent.MinimumTotalHeight = tempMinimumTotalHeight;
                    else
                        obj.Parent.MinimumTotalHeight = sum( obj.Parent.MinimumHeights );
                    end
                    
                    % Go upstream
                    obj.Parent.checkParentMinimumTotalHeight;
                end
                
            else
                % We have reached the top of the tree
                % If parent is ScrollingPanel, trigger redraw
                if isa( obj.Parent, 'uix.ScrollingPanel' )
                   obj.Parent.redraw; 
                end
            end   
        end % checkMinimumTotalHeight
        
        
        function updateMinimumTotalWidth( obj )
            % updateMinimumTotalWidth  Updates MinimumTotalWidth property
            %
            % See if this object has children with a MinimumWidths property
            minWidthChildren = arrayfun( @(x) ...
                isa( x, 'uix.HBox' ) || isa( x, 'uix.Grid' ), obj.Children );
            tempMinimumTotalWidth = 0;            
            if any( minWidthChildren )
                for ii = 1:numel( minWidthChildren )
                    
                    if true( minWidthChildren(ii) )
                        % Update this child's total minimum width
                        obj.Children(ii).updateMinimumTotalWidth;
                                                
                        % All lower tier children should be updated so get 
                        % the total for that tier
                        tempMinimumTotalWidth = tempMinimumTotalWidth ...
                            + obj.Children(ii).MinimumTotalWidth;
                    else
                        tempMinimumTotalWidth = tempMinimumTotalWidth + ...
                            obj.MinimumWidths(ii);
                    end
                end
            end
            
            % Check whether the sum of my MinimumWidths is greater than the 
            % sum of my children's TotalMinimumWidths
            if sum( obj.MinimumWidths ) < tempMinimumTotalWidth
                obj.MinimumTotalWidth = tempMinimumTotalWidth;
            else
                obj.MinimumTotalWidth = sum( obj.MinimumWidths );
            end
            
            % Now, propagate upstream
            obj.checkParentMinimumTotalWidth;
                      
        end % updateMinimumTotalWidth
        
        
        function checkParentMinimumTotalWidth( obj )
            % checkParentMinimumTotalWidth  Propogates MinimumTotalWidth
            % upstream
            %
            % See if this object has a parent with a MinimumWidths property
            if isa( obj.Parent, 'uix.Box' )
                % If parent is a VBox (ie. no MinimumWidths) pass through
                if isa( obj.Parent, 'uix.VBox' )
                    obj.Parent.MinimumTotalWidth = obj.MinimumTotalWidth;
                    
                    % Go upstream
                    obj.Parent.checkParentMinimumTotalWidth;
                else
                    % Loop through parent's children and sum up min widths
                    tempMinimumTotalWidth = 0;
                    for ii = 1:numel( obj.Parent.MinimumWidths )
                        if isa( obj.Parent.Children(ii), 'uix.Box' )
                            tempMinimumTotalWidth = tempMinimumTotalWidth + ...
                                obj.Parent.Children(ii).MinimumTotalWidth;
                        else
                            tempMinimumTotalWidth = tempMinimumTotalWidth + ...
                                obj.Parent.MinimumWidths(ii);
                        end
                    end
                    
                    % Check whether the sum of my MinimumWidths is greater than
                    % the sum of my children's TotalMinimumWidths
                    if sum( obj.Parent.MinimumWidths ) < tempMinimumTotalWidth
                        obj.Parent.MinimumTotalWidth = tempMinimumTotalWidth;
                    else
                        obj.Parent.MinimumTotalWidth = sum( obj.Parent.MinimumWidths );
                    end
                    
                    % Go upstream
                    obj.Parent.checkParentMinimumTotalWidth;
                end
                
            else
                % We have reached the top of the tree
                % If parent is ScrollingPanel, trigger redraw
                if isa( obj.Parent, 'uix.ScrollingPanel' )
                    obj.Parent.redraw;
                end
            end
        end % checkMinimumTotalWidth
        
        
    end
    
end % classdef