function dy=fDiffSmoothStart(y,nStartPoints, nHalfWindow)
% Computes diff of a signal, smoothen it, and neglect the starting points
if ~exist('nHalfWindow','var'); nHalfWindow=10; end

% regular diff
dy=[0; diff(y)];
% using a linear slope for the first nStartPoints values
dy(1:nStartPoints)=linspace(0,dy(nStartPoints),nStartPoints);
% smoothing/filtering using moving average
dy= fMovingAverage(dy, nHalfWindow);

end
function y = fMovingAverage(x, n)
    sx = size(x);
    w = ones(2*n+1,1); % filter weights
    x = [x(:); zeros(n,1)];
    y = filter(w,1,x)./filter(w,1,ones(size(x)));
    y = y(n+1:end);
    y = reshape(y,sx);
end
