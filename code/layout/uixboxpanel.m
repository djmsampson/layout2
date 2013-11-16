function obj = uixboxpanel( varargin )

% Check inputs
uix.pvchk( varargin )

% Construct
obj = uix.BoxPanel( varargin{:} );

% Auto-parent
if ~ismember( 'Parent', varargin(1:2:end) )
    obj.Parent = gcf;
end

end % uixboxpanel