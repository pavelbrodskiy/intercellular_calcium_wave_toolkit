% This function runs manual segmentation on each raw tiff stack for which 
% there is no rotated video.

function thruSegmentRotatedManually(labels, settings)
mkdir(settings.thruMask);
for currentFile = labels'
    disp(['Performing manual segmentation: ' currentFile{1}])
    if ~exist([settings.thruMask currentFile{1} '.mat'],'file')||settings.force
        load([settings.thruRot currentFile{1} '.mat'], 'croppedVideo');
        [mask, ~] = selectRoI(rescale2RGB(croppedVideo(:,:,1)));
        save([settings.thruMask currentFile{1} '.mat'], 'mask');
    end
end
end

