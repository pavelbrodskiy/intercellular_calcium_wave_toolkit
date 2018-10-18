function compositeGeometry = makeCompositeGeometry(geometries)
controlPoints = cat(1,cat(4, geometries.NCp), cat(4, geometries.SCp));
G = nanmean(nanmean(controlPoints, 3), 1);
transControlPoints = controlPoints - G + nanmean(G, 4);
controlPointsComposite = nanmean(transControlPoints, 4);

a = controlPointsComposite(:,1,:);
b = controlPointsComposite(:,2,:);
compositeGeometry.controlPoints(:,1) = a(:);
compositeGeometry.controlPoints(:,2) = b(:);
compositeGeometry.controlPoints = compositeGeometry.controlPoints - min(compositeGeometry.controlPoints) + 1;

% maskMat = padStack({geometries.mask},false);
% meanMask = mean(double(cat(3,maskMat{:})),3);
% compositeGeometry.meanMask = meanMask > 0.5;

dt=delaunayTriangulation(compositeGeometry.controlPoints);
k=convexHull(dt);
maskPolygon = dt.Points(k,:);
compositeGeometry.compositeMask = poly2mask(maskPolygon(:,1),maskPolygon(:,2),ceil(max(maskPolygon(:,2))),ceil(max(maskPolygon(:,1))));

if any(maskPolygon(:) < 1)
    error('Negative Mask')
end
end