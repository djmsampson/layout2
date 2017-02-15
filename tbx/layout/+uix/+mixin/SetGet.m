classdef ( Hidden, Abstract ) SetGet < matlab.mixin.SetGet
    %uix.SetGet  Abstract class providing customizable set and get methods
    
    %  Copyright 2015-2017 The MathWorks, Inc.
    %  $Revision: 116 $  $Date: 2015-07-29 05:19:35 +0100 (Wed, 29 Jul 2015) $
    
    methods( Sealed )
        
        function varargout = set( obj, varargin )
            %set  Set properties
            %
            %  set(s,p,v) sets the property p of the server s to the value
            %  v.
            %
            %  set(s,p1,v1,p2,v2,...) sets property p1 to value v1, etc.
            %
            %  v = set(s,p) returns the possible values v of the property p
            %  of the server s.
            %
            %  v = set(s) returns a structure containing all possible
            %  values of all settable properties.
            
            switch nargin
                case 1
                    % Iterate over settable properties, getting possible
                    % values for each
                    mc = metaclass( obj );
                    mpl = mc.PropertyList;
                    v = struct(); % initialize
                    for ii = 1:numel( mpl )
                        mp = mpl(ii); % this meta.property
                        if strcmp( mp.SetAccess, 'public' ) && ~mp.Hidden
                            p = mp.Name; % this property name
                            v.(p) = obj.getPossibleValues( p ); % delegate
                        end
                    end
                    varargout = {v}; % return
                case 2
                    % Check that specified property is settable, and if so,
                    % get possible values
                    p = varargin{1};
                    mp = findprop( obj, p );
                    if isempty( mp )
                        error( 'There is no property ''%s'' of class %s. ', ...
                            p, class( obj ) )
                    elseif ~strcmp( mp.SetAccess, 'public' )
                        error( 'Property ''%s'' of class %s is not settable.', ...
                            p, class( obj ) )
                    else
                        v = obj.getPossibleValues( p ); % delegate
                    end
                    varargout = {v}; % return
                otherwise
                    % Call superclass method
                    nargoutchk( 0, 0 )
                    set@matlab.mixin.SetGet( obj, varargin{:} )
            end
            
        end % set
        
    end % public methods
    
    methods( Access = protected )
        
        function v = getPossibleValues( ~, ~ )
            %getPossibleValues  Get possible property values
            %
            %  v = s.getPossibleValues(p) gets the possible values v of the
            %  property p from the server s.
            
            v = {}; % default
            
        end % getPossibleValues
        
    end % helpers
    
end % classdef