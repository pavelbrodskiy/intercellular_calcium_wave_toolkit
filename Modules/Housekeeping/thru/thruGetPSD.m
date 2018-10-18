

function thruGetPSD(labels, settings)
mkdir(settings.thruPSD);
for currentFile = labels'
    disp(['Extracting PSDs: ' currentFile{1}])
    if (~exist([settings.thruPSD currentFile{1} '.mat'],'file'))||settings.force
        load([settings.thruRot currentFile{1} '.mat'], 'croppedVideo');
        load([settings.thruMask currentFile{1} '.mat'], 'rotMask');
        [PSD, freq] = makePSDs(croppedVideo, rotMask, settings);
        save([settings.thruPSD currentFile{1} '.mat'], 'PSD', 'freq');
    end
end
end