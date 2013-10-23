function [version, versionDate] = layoutVersion()
%layoutVersion  get the toolbox version and date
%
%   v = layoutVersion() returns just the version string
%
%   [v,d] = layoutVersion() returns both the version string and the date of
%   creation.  The date format is ISO8601, YYYY-MM-DD.
%
%   Examples:
%   >> [v,d] = layoutVersion()
%   v = '1.0'
%   d = '2010-05-28'
%
%   See also: layoutRoot

%   Copyright 2009-2013 The MathWorks Ltd.

% Issue warning
warning( 'uiextras:Deprecated', 'layoutVersion is deprecated.  Please use ver(''layout'') instead.' )

% Return information from ver
v = ver( 'layout' );
version = v.Version;
versionDate = datestr( datenum( v.Date, 'dd-mmm-yyyy' ), 'yyyy-mm-dd' );

end % layoutVersion