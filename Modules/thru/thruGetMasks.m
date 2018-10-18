% This function makes spatial maps for each raw tiff stack for which there
% is no rotated video.

function thruGetMasks(labels, settings)
mkdir(settings.thruMask);
for currentFile = labels'
    disp(['Manually segmenting axis: ' currentFile{1}])
    if (~exist([settings.thruMask currentFile{1} '.mat'],'file'))||settings.force
        load([settings.thruRot currentFile{1} '.mat'], 'croppedVideo');
        load([settings.thruMask currentFile{1} '.mat'], 'rotMask');
        annotation = [croppedVideo(:,:,1),max(croppedVideo,[],3);min(croppedVideo,[],3),median(croppedVideo,3)];
        [AP, annotation] = manualSpline(annotation, rotMask, 'red');
        [DV, annotation] = manualSpline(annotation, rotMask, 'blue');
        imshow(annotation)
        draw now
        save([settings.thruAxes currentFile{1} '.mat'], 'AP', 'DV', 'annotation');
    end
end
end