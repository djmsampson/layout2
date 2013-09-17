function [pPositions, pSizes] = calcPixelPositions( pTotal, mSizes, pMinimumSizes, pPadding, pSpacing )

n = numel( mSizes ); % number of children

if n == 0
    
    pSizes = zeros( [n 2] );
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