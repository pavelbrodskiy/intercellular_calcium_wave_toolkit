% This function runs manual segmentation on each raw tiff stack for which 
% there is no rotated video.

function thruSegmentManually(labels, settings)
mkdir(settings.thruRawMask);
mkdir(settings.thruMask);
mkdir(settings.thruRot);
for currentFile = labels'
    disp(['Performing manual segmentation: ' currentFile{1}])
    if ~exist([settings.thruMask currentFile{1} '.mat'],'file')|| ...
            ~exist([settings.thruRot currentFile{1} '.mat'],'file')|| ...
            settings.force
        video = readTiff([settings.inExperimentalData currentFile{1} '.tif']);
        [mask, ~] = selectRoI(rescale2RGB(video(:,:,1)));
        [croppedVideo, rotMask] = refineRotation(video, mask);
%       [croppedVideo, rotMask] = determineAP(croppedVideo, rotMask); %use
%       identifyOrientation for flipping the disc
        imshow(croppedVideo(:,:,1),[]);
        save([settings.thruRawMask currentFile{1} '.mat'], 'mask');
        save([settings.thruMask currentFile{1} '.mat'], 'rotMask');
        save([settings.thruRot currentFile{1} '.mat'], 'croppedVideo');
    end
end
end

