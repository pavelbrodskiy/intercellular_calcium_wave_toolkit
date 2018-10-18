function geometry = generateGeometry(APAxis, DVAxis, mask, settings)
%% Clean Inputs
if ~any(mask(:))
    geometry = nan;
    return
end
mask = double(mask);
mask = imgaussfilt(mask, 5);
mask = mask > 0.5;
APAxis = fliplr(unique(APAxis,'rows','stable'))';
DVAxis = fliplr(unique(DVAxis,'rows','stable'))';

%% Extrapolate DV and AP axis
ap_p1=polyfit(APAxis(2,1:settings.extrapDistance),APAxis(1,1:settings.extrapDistance),1);
ap_p2=polyfit(APAxis(2,end-settings.extrapDistance:end),APAxis(1,end-settings.extrapDistance:end),1);
dv_p1=polyfit(DVAxis(1,1:settings.extrapDistance),DVAxis(2,1:settings.extrapDistance),1);
dv_p2=polyfit(DVAxis(1,end-settings.extrapDistance:end),DVAxis(2,end-settings.extrapDistance:end),1);

if APAxis(2,1) < APAxis(2,end)
    startPointAP = [polyval(ap_p1,0);            0];
    endPointAP   = [polyval(ap_p2,size(mask,1)); size(mask,1)];
else
    startPointAP = [polyval(ap_p1,size(mask,1)); size(mask,1)];
    endPointAP   = [polyval(ap_p2,0);            0];
end

if DVAxis(1,1) < DVAxis(1,end)
    startPointDV = [0;             polyval(dv_p1,0)];
    endPointDV   = [size(mask,2);  polyval(dv_p2,size(mask,2))];
else
    endPointDV   = [0;             polyval(dv_p2,0)];
    startPointDV = [size(mask,2);  polyval(dv_p1,size(mask,2))];
end

APAxis = [startPointAP, APAxis, endPointAP];
DVAxis = [startPointDV, DVAxis, endPointDV];
geometry.mask = mask;

%% Simplify input curves
maskPts = mask2poly(mask,'Exact','MINDIST');
maskPts = unique(maskPts,'rows','stable');
maskPts(1,:) = [];
APAxis = APAxis';
DVAxis = DVAxis';
if settings.simplifyTolMask > 0
    maskPts = dpsimplify(maskPts, settings.simplifyTolMask);
end
if settings.simplifyTolAxis > 0
    APAxis = dpsimplify(APAxis, settings.simplifyTolAxis);
    DVAxis = dpsimplify(DVAxis, settings.simplifyTolAxis);
end

%% Obtain precise coordinates of intersections
c = InterX(APAxis',DVAxis');
ns = InterX(APAxis',maskPts([1:end,1],:)');
ew = InterX(DVAxis',maskPts([1:end,1],:)');

c = uniquetol(c', 0.1, 'ByRows', true);
ns = uniquetol(ns', 0.1, 'ByRows', true);
ew = uniquetol(ew', 0.1, 'ByRows', true);

if size(ns, 1) ~= 2 || size(ew, 1) ~= 2 || size(c, 1) ~= 1
    error('N, S, E, W, or C was not found')
end

%% Determine which are N, S, E, and W
if ns(1,2) < ns(2,2)
    n = ns(1,:); s = ns(2,:);
else
    n = ns(2,:); s = ns(1,:);
end
if ew(1,1) > ew(2,1)
    e = ew(1,:); w = ew(2,:);
else
    e = ew(2,:); w = ew(1,:);
end

%% Assign coordinate system to geometry structure
geometry.N = n;
geometry.S = s;
geometry.E = e;
geometry.W = w;
geometry.C = c;
geometry.NW = reinterpolateShort(maskPts([1:end,1],:), n, w, settings);
geometry.NE = reinterpolateShort(maskPts([1:end,1],:), n, e, settings);
geometry.SW = reinterpolateShort(maskPts([1:end,1],:), s, w, settings);
geometry.SE = reinterpolateShort(maskPts([1:end,1],:), s, e, settings);
geometry.NC = reinterpolate(APAxis, n, c, settings);
geometry.SC = reinterpolate(APAxis, s, c, settings);
geometry.EC = reinterpolate(DVAxis, e, c, settings);
geometry.WC = reinterpolate(DVAxis, w, c, settings);

%% Use coordinate system to generate new grid (precise on DV axis)
[geometry.WCp, geometry.ECp] = drawmeridians(geometry.NC, geometry.SC, ...
    geometry.NW, geometry.NE, geometry.SW, geometry.SE, geometry.WC, ...
    geometry.EC, settings);

%% Use coordinate system to generate new grid (precise on AP axis)
EN = flipud(geometry.NE);
ES = flipud(geometry.SE);
WS = flipud(geometry.SW);
WN = flipud(geometry.NW);

[geometry.NCp, geometry.SCp] = drawmeridians(geometry.WC, geometry.EC, ...
    WS, WN, ES, EN, geometry.SC, geometry.NC, settings);

if any(isnan(geometry.SCp(:))) || max(geometry.SCp(:)) > max(size(mask)) * 2 || ...
        any(isnan(geometry.NCp(:))) || max(geometry.NCp(:)) > max(size(mask)) * 2
        geometry = nan;
    return
%     showGeometry(geometry)
%     error('Something went wrong')
end
end

%% Interpolate a curve between the selected points
function newCurve = reinterpolate(curve, p1, p2, settings)
if size(curve, 1) > 3
    method = 'linear';
else
    method = 'linear';
end

[~,~,t1] = distance2curve(curve,p1,method);
[~,~,t2] = distance2curve(curve,p2,method);
newCurve = interparc(linspace(t1,t2,settings.maskPoints),curve(:,1),curve(:,2),'linear');
end

%% Interpolate the shortest curve between the selected points
function newCurve = reinterpolateShort(curve, p1, p2, settings)
[~,~,t1] = distance2curve(curve,p1,'linear');
[~,~,t2] = distance2curve(curve,p2,'linear');

if abs(t2-t1) < 0.5
    pts = linspace(t1,t2,settings.maskPoints);
else
    ratio = t1/(1-t2);
    pts1 = min(settings.maskPoints-2, settings.maskPoints*ratio);
    pts2 = max(2, settings.maskPoints - pts1);
    if t1 < 0.5
        pts = [linspace(t1,0,pts1), ...
            linspace(1,t2,pts2)];
    else
        pts = [linspace(t1,1,pts1), ...
            linspace(0,t2,pts2)];
    end
end

newCurve = interparc(pts,curve(:,1),curve(:,2),'linear');
end

%% Draw meridians using affine transform with WCE as the equator
function [WCp, ECp] = drawmeridians(NC, SC, NW, NE, SW, SE, WC, EC, settings)
    Cp = [interparc(linspace(0,1,settings.meridians),NC(:,1),NC(:,2),'linear'); ...
        flipud(interparc(linspace(0,1,settings.meridians),SC(:,1),SC(:,2),'linear'))];
    Cp(settings.meridians,:) = [];
    
    Wp = [interparc(linspace(0,1,settings.meridians),NW(:,1),NW(:,2),'linear'); ...
        flipud(interparc(linspace(0,1,settings.meridians),SW(:,1),SW(:,2),'linear'))];
    Wp(settings.meridians,:) = [];
    
    Ep = [interparc(linspace(0,1,settings.meridians),NE(:,1),NE(:,2),'linear'); ...
        flipud(interparc(linspace(0,1,settings.meridians),SE(:,1),SE(:,2),'linear'))];
    Ep(settings.meridians,:) = [];
    
    W = Wp(settings.meridians,:);
    C = Cp(settings.meridians,:);
    E = Ep(settings.meridians,:);
    
    WCp = zeros(size(WC, 1), size(WC, 2), size(Ep, 1), 'double');
    ECp = zeros(size(WC, 1), size(WC, 2), size(Ep, 1), 'double');
    
    for i = 1:size(Ep, 1)
        [A,b] = calculate_affine(W,C,E,Wp(i,:),Cp(i,:),Ep(i,:));
        for j = 1:size(WC, 1)
            WCp(j,:,i) = A*WC(j,:)'+b;
            ECp(j,:,i) = A*EC(j,:)'+b;
        end
    end
end

%% Affine transform to compute the position of meridians
function [A,b] = calculate_affine(W,C,E,Wp,Cp,Ep)
wx=W(1); wy=W(2);
cx=C(1); cy=C(2);
ex=E(1); ey=E(2);
wpx=Wp(1); wpy=Wp(2);
cpx=Cp(1); cpy=Cp(2);
epx=Ep(1); epy=Ep(2);

A=zeros(2,2);
A(1,1)=((wy-ey)*(wpx-cpx)-(wy-cy)*(wpx-epx))/((wy-ey)*(wx-cx)-(wx-ex)*(wy-cy)+1e-8);
A(1,2)=((wx-cx)*(wpx-epx)-(wx-ex)*(wpx-cpx))/((wy-ey)*(wx-cx)-(wx-ex)*(wy-cy)+1e-8);
A(2,1)=((wy-ey)*(wpy-cpy)-(wy-cy)*(wpy-epy))/((wy-ey)*(wx-cx)-(wx-ex)*(wy-cy)+1e-8);
A(2,2)=((wx-cx)*(wpy-epy)-(wx-ex)*(wpy-cpy))/((wy-ey)*(wx-cx)-(wx-ex)*(wy-cy)+1e-8);

b=0.5*(Wp'+Cp'-A*(W'+C'));
end