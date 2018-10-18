function psi = psitemp2(centers,x,dis)
%This function is the psi cubic spline function
if nargin<3
    dis = pdist2(centers,x);
end
r=dis.*dis;
r(r==0)=1;
psi=r.*log(r);
end