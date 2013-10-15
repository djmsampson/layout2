function obj = hbox( varargin )

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.HBox( varargin{:} );

% Auto-parent
if ~ismember( varargin(1:2:end), 'Parent' )
    obj.Parent = gcf;
end

end % hbox