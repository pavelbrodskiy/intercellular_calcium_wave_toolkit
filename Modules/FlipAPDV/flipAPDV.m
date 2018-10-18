% This function flips the corresponding movies and masks based on the
% previously identified orientation

function flipAPDV(settings)
rotVideoUnflipped = settings.thruRotUnflipped;
rotMaskUnflipped = settings.thruMaskUnflipped;

%% Load datatable
tblTransform = readtable([settings.inTables 'flipAPDV.xlsx']);
% consensus = categorical(tblTransform.consensus);
labels = tblTransform.Label;

%% Find discs and segment them
for i = 1:length(labels)
    disp(['Manually flipping: ' labels{i}])
    
    if ~((exist([rotMaskUnflipped labels{i} '.mat'], 'file') && ...
            ~exist([settings.thruMask labels{i} '.mat'],'file')) || ...
    (exist([settings.thruRotRFP labels{i} '.mat'], 'file') && ...
            ~exist([settings.thruRotRFPFlipped labels{i} '.mat'],'file')))
         continue
     end
    
    load([rotVideoUnflipped labels{i} '.mat']);
    load([rotMaskUnflipped labels{i} '.mat']);
    if exist([settings.thruRotRFP labels{i} '.mat'], 'file')
    load([settings.thruRotRFP labels{i} '.mat']);
    load([settings.thruRotNormalized labels{i} '.mat']);
    end
    
    switch char(tblTransform.consensus(i))
        case categorical({'flip AP'})
            croppedVideo = flipud(croppedVideo);
            rotMask = flipud(rotMask);
            if exist([settings.thruRotRFP labels{i} '.mat'], 'file')
            croppedRFP = flipud(croppedRFP);
            croppedDfOverF = flipud(croppedDfOverF);
            end
        case categorical({'flip DV'})
            croppedVideo = fliplr(croppedVideo);
            rotMask = fliplr(rotMask);
            if exist([settings.thruRotRFP labels{i} '.mat'], 'file')
            croppedRFP = fliplr(croppedRFP);
            croppedDfOverF = fliplr(croppedDfOverF);
            end
        case categorical({'rotate 180'})
            croppedVideo = rot90(croppedVideo, 2);
            rotMask = rot90(rotMask, 2);
            if exist([settings.thruRotRFP labels{i} '.mat'], 'file')
            croppedRFP = rot90(croppedRFP);
            croppedDfOverF = rot90(croppedDfOverF);
            end
        case categorical({'no flip'})
            croppedVideo = croppedVideo;
            rotMask = rotMask;
            if exist([settings.thruRotRFP labels{i} '.mat'], 'file')
            croppedRFP = croppedRFP;
            croppedDfOverF = croppedDfOverF;
            end
        case categorical({'undetermined'})
            continue
        otherwise
            error('This is not a correct flip type')
    end
    
%     rotMaskUnflipped = ~all(rotVideoUnflipped == 0, 3);
    
    mkdir(settings.thruRot);
    mkdir(settings.thruMask);
    if exist([settings.thruRotRFP labels{i} '.mat'], 'file')
    mkdir(settings.thruRotRFPFlipped);
    mkdir(settings.thruRotNormalizedFlipped);
    end
    
    save([settings.thruRot labels{i} '.mat'], 'croppedVideo');
    save([settings.thruMask labels{i} '.mat'], 'rotMask');
    if exist([settings.thruRotRFP labels{i} '.mat'], 'file')
    save([settings.thruRotRFPFlipped labels{i} '.mat'], 'croppedRFP');
    save([settings.thruRotNormalizedFlipped labels{i} '.mat'], 'croppedDfOverF');
    end
end

    
