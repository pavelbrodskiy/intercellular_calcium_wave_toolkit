% This function makes spatial maps for each raw tiff stack for which there
% is no rotated video.

function thruGetTime(labels, settings)
mkdir(settings.thruTime);
initialized = false;
for currentFile = labels'
    disp(['Measuring Times: ' currentFile{1}])
    if (~exist([settings.thruTime currentFile{1} '.mat'],'file'))||settings.force
        if exist([settings.thruRot currentFile{1} '.mat'])
            load([settings.thruRot currentFile{1} '.mat']);
            time = size(croppedVideo, 3);
            save([settings.thruTime currentFile{1} '.mat'], 'time');
        end
    end
end
end