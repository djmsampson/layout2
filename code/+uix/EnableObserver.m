classdef ( Hidden, Sealed ) EnableObserver < handle
    
    properties( SetAccess = private )
        Subject
        Enable = true
    end
    
    properties( Access = private )
        Ancestors
        EnableListeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        EnableChange
    end
    
    methods
        
        function obj = EnableObserver( in )
            
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
            
            % Force update
            obj.update()
            
            % Create listeners
            enableListeners = event.listener.empty( [0 1] );
            cbEnableChange = @obj.onEnableChange;
            for ii = 1:numel( ancestry )
                ancestor = ancestry(ii);
                enableListeners(ii,:) = event.proplistener( ancestor, ...
                    findprop( ancestor, 'Enable' ), 'PostSet', ...
                    cbEnableChange );
            end
            
            % Store listeners
            obj.EnableListeners = enableListeners;
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function update( obj )
            
            % Identify new value
            ancestry = [obj.Ancestors; obj.Subject];
            tf = arrayfun( @(x)isprop(x,'Enable'), ancestry );
            enables = get( ancestry(tf), 'Enable' );
            newEnable = all( strcmp( enables, 'on' ) );
            
            % Store new value
            obj.Enable = newEnable;
            
        end % update
        
    end % operations
    
    methods( Access = private )
        
        function onEnableChange( obj, ~, ~ )
            
            % Update
            obj.update()
            
            % Raise event
            notify( obj, 'EnableChange' )
            
        end % onEnableChange
        
    end % event handlers
    
end % classdef