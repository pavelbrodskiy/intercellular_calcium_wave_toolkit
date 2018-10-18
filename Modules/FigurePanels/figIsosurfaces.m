function metadata = figIsosurfaces(settings, category, labels, currentCat, threshs)
%% Parse Inputs (Lazy)
if nargin < 5
    threshs = [0.01, 0.05, 0.1:0.1:0.9, 0.95, 0.99];
end
if nargin < 4
    currentCat = unique(category);
end

%% Initialization
settings.outRough = [settings.outRough, 'isoSurfaces' filesep];

%% Make isosurface
close all
for curCat = unique(currentCat)'
    for i = find(category==curCat)'
        disp(['Making Isosurface ' labels{i}]);
        dirName = [settings.outRough, char(category(i)), '_', labels{i} filesep];
        mkdir(dirName);
        load([settings.thruRot, labels{i}, '.mat'])
        load([settings.thruMask, labels{i}, '.mat'])
        pouchIsosurface(croppedVideo, rotMask, dirName, threshs, settings)
    end
end

metadata = [];