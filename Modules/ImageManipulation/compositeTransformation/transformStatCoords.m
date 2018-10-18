% [transformed, newGeometry] = transformStatCoords(statValues, coords, geometries, newGeometry)
% [transformed, newGeometry] = transformStatCoords(dataTable, field)
%
% Given initial geometry, sample values and their coordinates, obtain an
% "average" geometry and transform values onto it. Then obtain average
% transformed value and return "average" geometry. "Average" geometry may
% be supplied. Inputs may be provided as table with relevant field listed.

function [transformed, newGeometry] = transformStatCoords(statValues, coords, geometries, newGeometry)
%% Parse datatable
if istable(statValues)
    field = coords;
    coords = statValues.coords;
    geometries = [statValues.geometries];
    statValues = {statValues.statsArray.(field)}; 
end

%% Generate composite geometry
if nargin < 4
    newGeometry = makeCompositeGeometry(geometries);
end

%% Interpolate the original sampled values onto new x and y positions
[X_new, Y_new] = meshgrid(1:size(newGeometry.compositeMask,2),1:size(newGeometry.compositeMask,1));

transformed = zeros(size(X_new, 1), size(X_new, 2), length(geometries));
skip = [];
for i = 1:length(geometries)
    if isempty(geometries(i).mask)
        skip(end+1) = i;
        continue
    end
    oldGeometry = makeCompositeGeometry(geometries(i));
    
    oldInterpolant = scatteredInterpolant(coords{i}(:,2),coords{i}(:,1),statValues{i}','linear','nearest');
    sampled_v = oldInterpolant(oldGeometry.controlPoints(:,1),oldGeometry.controlPoints(:,2));
    newInterpolant = scatteredInterpolant(newGeometry.controlPoints(:,1),newGeometry.controlPoints(:,2),sampled_v,'linear','nearest');
    transformed(:,:,i) = newInterpolant(X_new,Y_new);
end
transformed(:,:,skip) = NaN;
transformed(repmat(~newGeometry.compositeMask,[1,1,length(geometries)])) = NaN;