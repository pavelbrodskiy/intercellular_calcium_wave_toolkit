function transformed = transformSpatialMap(rawImageMat, geometries)
%% Generate composite geometry
newGeometry = makeCompositeGeometry(geometries);

%% Interpolate the original sampled values onto new x and y positions
% [X_new, Y_new] = meshgrid(floor(min(newGeometry.controlPoints(:,1))):ceil(max(newGeometry.controlPoints(:,1))),floor(min(newGeometry.controlPoints(:,2))):ceil(max(newGeometry.controlPoints(:,2))));
[X_new, Y_new] = meshgrid(1:size(newGeometry.compositeMask,2),1:size(newGeometry.compositeMask,1));

transformed = zeros(size(X_new, 1), size(X_new, 2), length(geometries));
for i = 1:length(geometries)
    rawImage = rawImageMat{i};
    oldGeometry = makeCompositeGeometry(geometries(i));
    [X, Y] = meshgrid(1:size(rawImage,2),1:size(rawImage,1));
    oldInterpolant = scatteredInterpolant(X(:),Y(:),rawImage(:),'linear','nearest');
    sampled_v = oldInterpolant(oldGeometry.controlPoints(:,1),oldGeometry.controlPoints(:,2));
    newInterpolant = scatteredInterpolant(newGeometry.controlPoints(:,1),newGeometry.controlPoints(:,2),sampled_v,'linear','nearest');
    transformed(:,:,i) = newInterpolant(X_new,Y_new);
end

transformed = transformed .* newGeometry.compositeMask;