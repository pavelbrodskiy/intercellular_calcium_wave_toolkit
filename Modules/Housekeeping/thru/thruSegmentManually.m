% This function runs manual segmentation on each raw tiff stack for which 
% there is no rotated video.

function thruSegmentManually(labels, settings)
mkdir(settings.thruRawMask);
mkdir(settings.thruMaskUnflipped);
mkdir(settings.thruRotUnflipped);
for currentFile = labels'
    disp(['Performing manual segmentation: ' currentFile{1}])
    if ~exist([settings.thruMaskUnflipped currentFile{1} '.mat'],'file')|| ...
            settings.force
        if exist([settings.thruRawMask currentFile{1} '.mat'],'file')
            continue
        end
        if ~exist([settings.inExperimentalData currentFile{1} '.tif'], 'file')
            continue
        end
        try
            video = readTiff([settings.inExperimentalData currentFile{1} '.tif']);
        catch
            continue
        end
        [mask, ~] = selectRoI(rescale2RGB(video(:,:,1)));
        [croppedVideo, rotMask] = refineRotation(video, mask);
        [croppedVideo, rotMask] = determineAP(croppedVideo, rotMask);
        imshow(croppedVideo(:,:,1),[],'InitialMagnification', 200);
        save([settings.thruRawMask currentFile{1} '.mat'], 'mask');
        save([settings.thruMaskUnflipped currentFile{1} '.mat'], 'rotMask');
        save([settings.thruRotUnflipped currentFile{1} '.mat'], 'croppedVideo');
    end
end
end

