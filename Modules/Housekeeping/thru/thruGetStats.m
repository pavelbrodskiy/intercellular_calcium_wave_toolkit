% This function makes spatial maps for each raw tiff stack for which there
% is no rotated video.

function thruGetStats(labels, settings)
mkdir(settings.thruStats);
for currentFile = labels'
    disp(['Extracting spatial maps: ' currentFile{1}])
    if (~exist([settings.thruStats currentFile{1} '.mat'],'file'))||settings.force
        if ~exist([settings.thruRotUnflipped currentFile{1} '.mat'],'file') && ...
            ~exist([settings.thruRot currentFile{1} '.mat'],'file')
        continue
        end
        if ~exist([settings.thruRot currentFile{1} '.mat'], 'file')
            load([settings.thruRotUnflipped currentFile{1} '.mat'], 'croppedVideo');
            load([settings.thruMaskUnflipped currentFile{1} '.mat'], 'rotMask');
        elseif exist([settings.thruMask currentFile{1} '.mat'], 'file')
            load([settings.thruRot currentFile{1} '.mat'], 'croppedVideo');
            load([settings.thruMask currentFile{1} '.mat'], 'rotMask');
        else
           continue 
        end
        if exist([settings.thruRotRFPFlipped currentFile{1} '.mat'],'file') && ...
                exist([settings.thruRotNormalizedFlipped currentFile{1} '.mat'],'file')
            load([settings.thruRotRFPFlipped currentFile{1} '.mat'], 'croppedRFP');
            load([settings.thruRotNormalizedFlipped currentFile{1} '.mat'], 'croppedDfOverF');
            [structMap, coords, stats] = makeSpatialMaps(croppedVideo, rotMask, settings, croppedRFP, croppedDfOverF);
            save([settings.thruStats currentFile{1} '.mat'], 'structMap', 'coords', 'stats', '-v7.3');
        else
            [structMap, coords, stats] = makeSpatialMaps(croppedVideo, rotMask, settings);
            save([settings.thruStats currentFile{1} '.mat'], 'structMap', 'coords', 'stats', '-v7.3');
        end
    end
end
end