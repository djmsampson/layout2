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
            else
                ancestors = in;
                assert( all( ishghandle( ancestors ) ) && ...
                    ndims( ancestors ) == 2 && iscolumn( ancestors ) && ...
                    ~isempty( ancestors ), 'uix.InvalidArgument', ...
                    'Ancestry must be a vector of graphics objects.' ) %#ok<ISMAT>
                subject = ancestors(end);
                cParents = get( ancestors, {'Parent'} );
                assert( isequal( ancestors(1:end-1,:), ...
                    vertcat( cParents{2:end} ) ), ...
                    'uix:InvalidArgument', 'Inconsistent ancestry.' )
                assert( isequal( cParents{1}, ROOT ) || isempty( cParents{1} ), ...
                    'uix:InvalidArgument', 'Incomplete ancestry.' )
            end
            
            % Store subject, ancestors
            obj.Subject = subject;
            obj.Ancestors = ancestors;
            
            % Stop early for unrooted subjects
            if ~isequal( ancestors(1).Parent, ROOT ), return, end
            
            % Force update
            obj.update()
            
            % Create listeners
            cbVisibleChange = @obj.onVisibleChange;
            for ii = 1:numel( ancestors )
                ancestor = ancestors(ii);
                visibleListeners(ii,:) = event.proplistener( ancestor, ...
                    findprop( ancestor, 'Visible' ), 'PostSet', ...
                    cbVisibleChange ); %#ok<AGROW>
            end
            
            % Store listeners
            obj.VisibleListeners = visibleListeners;
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function update( obj )
            
            % Get old value
            oldVisible = obj.Visible;
            
            % Identify new value
            visibles = get( obj.Ancestors, 'Visible' );
            newVisible = all( strcmp( visibles, 'on' ) );
            
            % Store new value
            obj.Visible = newVisible;
            
            % Raise event
            if ~isequal( oldVisible, newVisible )
                notify( obj, 'VisibilityChange' )
            end
            
        end % update
        
    end % operations
    
    methods( Access = private )
        
        function onVisibleChange( obj, ~, ~ )
            
            % Update
            obj.update()
            
        end % onVisibleChange
        
    end % event handlers
    
end % classdef