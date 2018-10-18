% This function makes spatial maps for each raw tiff stack for which there
% is no rotated video.

function thruGetTransformedVideo(labels, settings)
mkdir(settings.thruTransformedVideo);
for currentFile = labels'
    disp(['Transforming Video: ' currentFile{1}])
    if (~exist([settings.thruTransformedVideo currentFile{1} '.mat'],'file'))||settings.force
        [AP, DV] = getAxes(currentFile(1), settings);
        load([settings.thruRotCropped currentFile{1} '.mat'], 'croppedRotated');
        transformedVideo = transformVideo(geometries, settings);
        save([settings.thruTransformedVideo currentFile{1} '.mat'], 'transformedVideo', '-v7.3');
    end
end
end