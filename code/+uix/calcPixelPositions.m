function pPositions = calcPixelPositions( pTotal, mSizes, pMinimumSizes, pPadding, pSpacing )
%calcPixelPositions  Calculate child positions in pixels
%
%  positions = uix.calcPixelPositions(total,sizes,minSizes,padding,spacing)
%  computes child positions given total available size (in pixels), child
%  sizes (in pixels and/or relative), minimum child sizes (in pixels),
%  padding (in pixels) and spacing (in pixels).  positions is an n-by-2
%  matrix, where n is the number of children, with the first column
%  corresponding to left/bottom, and the second column corresponding to
%  width/height.
%
%  Notes:
%  * All children are at least as large as the minimum specified size
%  * Relative sizes are respected for children larger than then minimum
%  specified size
%  * Children may extend beyond the total available size if the minimum
%  sizes, padding and spacing are too large

%  Copyright 2009-2013 The MathWorks, Inc.
%  $Revision: 383 $ $Date: 2013-04-29 11:44:48 +0100 (Mon, 29 Apr 2013) $

n = numel( mSizes ); % number of children

if n == 0
    
    pPositions = zeros( [n 2] );
    
else
    
    % Initialize
    pSizes = NaN( [n 1] );
    
    % Allocate absolute sizes
    a = mSizes >= 0; % absolute
    s = mSizes < pMinimumSizes; % small
    pSizes(a&~s) = mSizes(a&~s);
    pSizes(a&s) = pMinimumSizes(a&s);
    
    % Allocate relative sizes
    pTotalRelative = max( pTotal - 2 * pPadding - (n-1) * pSpacing - ...
        sum( pSizes(a) ), 0 );
    s = pTotalRelative * mSizes / sum( mSizes(~a) ) < pMinimumSizes; % small
    pSizes(~a&s) = pMinimumSizes(~a&s);
    pTotalRelative = max( pTotal - 2 * pPadding - (n-1) * pSpacing - ...
        sum( pSizes(a|s) ), 0 );
    pSizes(~a&~s) = pTotalRelative * mSizes(~a&~s) / sum( mSizes(~a&~s) );
    
    % Compute positions
    pPositions = [cumsum( [0; pSizes(1:end-1,:)] ) + pPadding + ...
        pSpacing * transpose( 0:n-1 ), pSizes];
    
end % getPixelPositions