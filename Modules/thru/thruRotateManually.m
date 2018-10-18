% This function runs manual rotation on each raw tiff stack for which there
% is no rotated video.

function thruRotateManually(labels, settings)
mkdir(settings.thruRot);
for currentFile = labels'
    disp(['Performing manual rotation: ' currentFile{1}])
    if (~exist([settings.thruRot currentFile{1} '.mat'],'file'))||settings.force
        manuallyRotate(currentFile{1}, settings);
    end
end
end