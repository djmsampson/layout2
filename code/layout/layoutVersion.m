function [version, versionDate] = layoutVersion()
%layoutVersion  get the toolbox version and date
%
%  v = layoutVersion() returns just the version string
%
%  [v,d] = layoutVersion() returns both the version string and the date of
%  creation.  The date format is ISO8601, YYYY-MM-DD.
%
%  Examples:
%  >> [v,d] = layoutVersion()
%  v = '1.0'
%  d = '2010-05-28'
%
%  See also: layoutRoot

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $

% Issue warning
warning( 'uiextras:Deprecated', '%s  %s', ...
    'layoutVersion will be removed in a future release.', ...
    'Please use ver(''layout'') instead.' )

% Return information from ver
v = ver( 'layout' );
switch numel( v )
    case 0
        error( 'uix:UnknownError', 'Cannot find GUI Layout Toolbox.' )
    case 1
        version = v.Version;
        versionDate = datestr( datenum( v.Date, 'dd-mmm-yyyy' ), 'yyyy-mm-dd' );
    otherwise
        error( 'uix:UnknownError', '%s  %s', ...
            'Multiple versions of GUI Layout Toolbox are installed.', ...
            'Please uninstall versions that are not in use.' )
end

end % layoutVersion