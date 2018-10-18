% This function makes spatial maps for each raw tiff stack for which there
% is no rotated video.

function thruGetGeometry(labels, settings)
mkdir(settings.thruGeometry);
for currentFile = labels'
    disp(['Generating geometry: ' currentFile{1}])
    if (~exist([settings.thruGeometry currentFile{1} '.mat'],'file'))||settings.force
        [AP, DV] = getAxes(currentFile(1), settings);
        load([settings.thruMask currentFile{1} '.mat'], 'rotMask');
        geometry = generateGeometry(AP{1}, DV{1}, rotMask, settings);
        save([settings.thruGeometry currentFile{1} '.mat'], 'geometry', '-v7.3');
    end
end
end