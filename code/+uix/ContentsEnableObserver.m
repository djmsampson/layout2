classdef ( Hidden, Sealed ) ContentsEnableObserver < handle
    
    properties( SetAccess = private )
        Subject
        ContentsEnable = true
    end
    
    properties( Access = private )
        Ancestors
        ContentsEnableListeners = event.listener.empty( [0 1] )
    end
    
    events( NotifyAccess = private )
        ContentsEnableChange
    end
    
    methods
        
        function obj = ContentsEnableObserver( in )
            
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
            
            % Force update
            obj.update()
            
            % Create listeners
            tf = arrayfun( @(x)isprop(x,'ContentsEnable'), ancestry );
            index = find( tf );
            contentsEnableListeners = event.listener.empty( [0 1] );
            cbContentsEnableChange = @obj.onContentsEnableChange;
            for jj = 1:numel( index )
                ancestor = ancestry(index(jj));
                contentsEnableListeners(jj,:) = event.proplistener( ...
                    ancestor, findprop( ancestor, 'ContentsEnable' ), ...
                    'PostSet', cbContentsEnableChange );
            end
            
            % Store listeners
            obj.ContentsEnableListeners = contentsEnableListeners;
            
        end % constructor
        
    end % structors
    
    methods( Access = private )
        
        function update( obj )
            
            % Identify new value
            ancestry = [obj.Ancestors; obj.Subject];
            tf = arrayfun( @(x)isprop(x,'ContentsEnable'), ancestry );
            contentsEnables = get( ancestry(tf,:), {'ContentsEnable'} );
            newContentsEnable = all( strcmp( contentsEnables, 'on' ) );
            
            % Store new value
            obj.ContentsEnable = newContentsEnable;
            
        end % update
        
    end % operations
    
    methods( Access = private )
        
        function onContentsEnableChange( obj, ~, ~ )
            
            % Update
            obj.update()
            
            % Raise event
            notify( obj, 'ContentsEnableChange' )
            
        end % onContentsEnableChange
        
    end % event handlers
    
end % classdef