function obj = hbox( varargin )

% Construct
obj = uix.HBox( varargin{:} );

% Auto-parent
if isempty( obj.Parent )
    obj.Parent = gcf;
end

end % hbox