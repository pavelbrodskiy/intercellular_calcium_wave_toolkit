% This function makes spatial maps for each raw tiff stack for which there
% is no rotated video.

function thruGetStats(labels, settings)
mkdir(settings.thruStats);
for currentFile = labels'
    disp(['Extracting spatial maps: ' currentFile{1}])
    if (~exist([settings.thruStats currentFile{1} '.mat'],'file'))||settings.force
        load([settings.thruRot currentFile{1} '.mat'], 'croppedVideo');
        load([settings.thruMask currentFile{1} '.mat'], 'rotMask');
        [structMap, coords, stats] = makeSpatialMaps(croppedVideo, rotMask, settings);
        save([settings.thruStats currentFile{1} '.mat'], 'structMap', 'coords', 'stats', '-v7.3');
    end
end
end