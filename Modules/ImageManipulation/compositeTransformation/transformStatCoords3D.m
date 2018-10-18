function transformed = transformStatCoords3D(imageStack, oldGeometry, newGeometry)
%% Interpolate the original sampled values onto new x and y positions
[X_new, Y_new, T_new] = meshgrid(1:size(newGeometry.compositeMask,2),1:size(newGeometry.compositeMask,1),1:size(imageStack,3));
[X_old, Y_old, T_old] = meshgrid(1:size(imageStack,2),1:size(imageStack,1),1:size(imageStack,3));
% idx = find(oldGeometry.mask(:)) + (0:size(imageStack,3)-1)*length(oldGeometry.mask(:))';
% idx = idx(:);

oldGeometry = makeCompositeGeometry(oldGeometry);

oldInterpolant = griddedInterpolant(Y_old,X_old,T_old,imageStack,'linear','nearest');

sampled_v = oldInterpolant(repmat(oldGeometry.controlPoints(:,2),[size(imageStack,3),1]),...
    repmat(oldGeometry.controlPoints(:,1),[size(imageStack,3),1]),...
    floor(1:(1/length(newGeometry.controlPoints(:,2))):(1 - (1/length(oldGeometry.controlPoints(:,2))) + size(imageStack,3)))');
newInterpolant = scatteredInterpolant(repmat(newGeometry.controlPoints(:,1),[size(imageStack,3),1]),...
    repmat(newGeometry.controlPoints(:,2),[size(imageStack,3),1]),...
    floor(1:(1/length(oldGeometry.controlPoints(:,2))):(1 - (1/length(oldGeometry.controlPoints(:,2))) + size(imageStack,3)))',...
    sampled_v,'linear','nearest');
transformed = newInterpolant(X_new,Y_new,T_new);

transformed(repmat(~newGeometry.compositeMask,[1,1,size(imageStack,3)])) = NaN;