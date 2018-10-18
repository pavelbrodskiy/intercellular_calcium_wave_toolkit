% This function runs manual segmentation on each raw tiff stack for which 
% there is no rotated video.

function thruProcessRFP(labels, settings)
mkdir(settings.thruRotRFP);
mkdir(settings.thruRotNormalized);
for currentFile = labels'
    disp(['Processing RFP signal: ' currentFile{1}])
    if (exist([settings.inRFP currentFile{1} '.tif'],'file')) && ...
            (~exist([settings.thruRotRFP currentFile{1} '.mat'],'file')) && ...
            (~exist([settings.thruRotNormalized currentFile{1} '.mat'],'file')) || ...
            settings.force
        gfp = readTiff([settings.inExperimentalData currentFile{1} '.tif']);
        rfp = readTiff([settings.inRFP currentFile{1} '.tif']);
        load([settings.thruRawMask currentFile{1} '.mat']);
        
        f_over_f = double(gfp) ./ double(rfp);
        df_over_f = f_over_f - min(f_over_f, [], 3);
        
        [croppedVideo, rotMask] = refineRotation(rfp, mask);
        [croppedRFP, ~] = determineAP(croppedVideo, rotMask);
        
        [croppedVideo, rotMask] = refineRotation(df_over_f, mask);
        [croppedDfOverF, ~] = determineAP(croppedVideo, rotMask);
        
        save([settings.thruRotRFP currentFile{1} '.mat'], 'croppedRFP');
        save([settings.thruRotNormalized currentFile{1} '.mat'], 'croppedDfOverF');
    end
end
end

