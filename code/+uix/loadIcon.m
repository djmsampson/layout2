function cdata = loadIcon(imagefilename,bgcol)
%loadIcon  Load an icon and set the transparent color
%
%   cdata = uix.loadIcon(filename) loads the icon from the specified
%   filename.  For PNG files with transparency, the transparent pixels are
%   set to NaN.  For other files, pixels that are pure green are set to
%   transparent (i.e., "green screen").  The resulting cdata is an RGB
%   double array.
%
%   cdata = uix.loadIcon(filename,bgcol) tries to merge the color data with
%   the specified background colour bgcol.  Fully transparent pixels are
%   still set to NaN, but partially transparent pixels are merged with the
%   background.
%
%   See also: imread

error( nargchk( 1, 2, nargin ) );
if nargin < 2
    bgcol = get( 0, 'DefaultUIControlBackgroundColor' );
end

% First try normally
this_dir = fileparts( mfilename( 'fullpath' ) );
icon_dir = fullfile( this_dir, 'Resources' );
if exist( imagefilename, 'file' )
    [cdata,map,alpha] = imread( imagefilename );
elseif exist( fullfile( icon_dir, imagefilename ), 'file' )
    [cdata,map,alpha] = imread( fullfile( icon_dir, imagefilename ));
else
    error( 'GUILayout:loadIcon:FileNotFound', 'Cannot open file ''%s''.', imagefilename );
end

if ~isempty( map )
    cdata = ind2rgb( cdata, map );
end

% Convert to double before applying transparency
cdata = convertToDouble( cdata );

[rows,cols,depth] = size( cdata ); %#ok<NASGU>
if ~isempty( alpha )
    alpha = convertToDouble( alpha );
    f = find( alpha==0 );
    if ~isempty( f )
        cdata(f) = nan;
        cdata(f + rows*cols) = nan;
        cdata(f + 2*rows*cols) = nan;
    end
    
    % Now blend partial alphas
    f = find( alpha(:)>0 & alpha(:)<1 );
    if ~isempty(f)
        cdata(f) = cdata(f).*alpha(f) + bgcol(1)*(1-alpha(f));
        cdata(f + rows*cols) = cdata(f + rows*cols).*alpha(f) + bgcol(2)*(1-alpha(f));
        cdata(f + 2*rows*cols) = cdata(f + 2*rows*cols).*alpha(f) + bgcol(3)*(1-alpha(f));
    end
    
else
    % Instead do a "green screen", treating anything pure-green as transparent
    f = find((cdata(:,:,1)==0) & (cdata(:,:,2)==1) & (cdata(:,:,3)==0));
    cdata(f) = nan;
    cdata(f + rows*cols) = nan;
    cdata(f + 2*rows*cols) = nan;
    
end

%-------------------------------------------------------------------------%
function cdata = convertToDouble( cdata )
% Convert an image to double precision in the range 0 to 1
switch lower( class( cdata ) )
    case 'double'
        % Do nothing
    case 'single'
        cdata = double( cdata );
    case 'uint8'
        cdata = double( cdata ) / 255;
    case 'uint16'
        cdata = double( cdata ) / 65535;
    case 'int8'
        cdata = ( double( cdata ) + 128 ) / 255;
    case 'int16'
        cdata = ( double( cdata ) + 32768 ) / 65535;
    otherwise
        error( 'GUILayout:LoadIcon:BadCData', ...
            'Image data of type ''%s'' is not supported.', class( cdata ) );
end