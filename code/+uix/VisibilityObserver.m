classdef ( Hidden, Sealed ) VisibilityObserver < handle
    
    properties( SetAccess = private )
        Subject
        Visible = false
    end
    
    properties( Access = private )
        Ancestors
        VisibleListeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        VisibilityChange
    end
    
    methods
        
        function obj = VisibilityObserver( in )
            
            persistent ROOT
            if isequal( ROOT, [] ), ROOT = groot(); end
            
            % Handle inputs
            if isscalar( in )
                subject = in;
                assert( ishghandle( subject ) && ...
                    isequal( size( subject ), [1 1] ) && ...
                    ~isequal( subject, ROOT ), ...
                    'uix.InvalidArgument', ...
                    'Subject must be a graphics object.' )
                ancestors = uix.ancestors( subject );
                ancestry = [ancestors; subject];
            else
                ancestry = in;
                assert( all( ishghandle( ancestry ) ) && ...
                    ndims( ancestry ) == 2 && iscolumn( ancestry ) && ...
                    ~isempty( ancestry ), 'uix.InvalidArgument', ...
                    'Ancestry must be a vector of graphics objects.' ) %#ok<ISMAT>
                cParents = get( ancestry, {'Parent'} );
                assert( isequal( ancestry(1:end-1,:), ...
                    vertcat( cParents{2:end} ) ), ...
                    'uix:InvalidArgument', 'Inconsistent ancestry.' )
                assert( isequal( cParents{1}, ROOT ) || isempty( cParents{1} ), ...
                    'uix:InvalidArgument', 'Incomplete ancestry.' )
                subject = ancestry(end,:);
                ancestors = ancestry(1:end-1,:);
            end
            
            % Store subject, ancestors
            obj.Subject = subject;
            obj.Ancestors = ancestors;
            
            % Stop early for unrooted subjects
            if isempty( ancestors ) || ~isequal( ancestors(1).Parent, ROOT ), return, end
            
            % Force update
            obj.update()
            
            % Create listeners
            visibleListeners = event.listener.empty( [0 1] );
            cbVisibleChange = @obj.onVisibleChange;
            for ii = 1:numel( ancestry )
                ancestor = ancestry(ii);
                visibleListeners(ii,:) = event.proplistener( ancestor, ...
                    findprop( ancestor, 'Visible' ), 'PostSet', ...
                    cbVisibleChange );
            end
            
            % Store listeners
            obj.VisibleListeners = visibleListeners;
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function update( obj )
            
            % Identify new value
            ancestry = [obj.Ancestors; obj.Subject];
            visibles = get( ancestry, 'Visible' );
            newVisible = all( strcmp( visibles, 'on' ) );
            
            % Store new value
            obj.Visible = newVisible;
            
        end % update
        
    end % operations
    
    methods( Access = private )
        
        function onVisibleChange( obj, ~, ~ )
            
            % Update
            obj.update()
            
            % Raise event
            notify( obj, 'VisibilityChange' )
            
        end % onVisibleChange
        
    end % event handlers
    
end % classdef