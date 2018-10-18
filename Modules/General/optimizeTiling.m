% Determine the best layout of tiles for n images with dimensions x*y,
% conforming to a specific output ratio.

function [M, N] = optimizeTiling(x, y, n)
error('Not working yet')
r = 16/9; % Ratio of width to height for final image
p.r = r;
p.x = x;
p.y = y;

fObj = @(MN, p) ((p.x/MN(1))/(p.y/MN(2))-p.r).^2 + (MN(1).*MN(2)).^2;
fObjective = @(MN) fObj(MN, p);
fCon = @(MN, n) deal(MN(1)*MN(2)+n,[]);
fConstraint = @(MN) fCon(MN, n);

x0 = [1,1]; % Make a starting guess at the solution
MN = ga(fObjective,2,[],[],[],[],[1,1],[n,n],... 
   fConstraint,[]);

M = MN(1);
N = MN(2);