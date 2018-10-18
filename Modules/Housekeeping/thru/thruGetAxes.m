% This function makes spatial maps for each raw tiff stack for which there
% is no rotated video.

function thruGetAxes(labels, settings)
mkdir(settings.thruAxes);
rng shuffle
labels = labels(randperm(length(labels)));
for currentFile = labels'
    disp(['Manually segmenting axis: ' currentFile{1}])
    if (~exist([settings.thruAxes currentFile{1} '.mat'],'file'))||settings.force
        load([settings.thruRot currentFile{1} '.mat'], 'croppedVideo');
%         if exist([settings.thruMask currentFile{1} '.mat'], 'file')
            load([settings.thruMask currentFile{1} '.mat'], 'rotMask');
%         else
%             mkdir(settings.thruMask);
%             rotMask = all(croppedVideo, 3);
%             save([settings.thruMask currentFile{1} '.mat'], 'rotMask');
%         end
        
        rotMask2 = [rotMask,rotMask;rotMask,rotMask];
        croppedVideo = double(croppedVideo);
        annotation = [croppedVideo(:,:,1)/max(max(croppedVideo(:,:,1))),...
            max(croppedVideo,[],3)/max(max(max(croppedVideo,[],3)));...
            min(croppedVideo,[],3)/max(max(min(croppedVideo,[],3))) ...
            ,median(croppedVideo,3)/max(max(mean(croppedVideo,3)))];
        
        [AP, annotation] = manualSpline(annotation, rotMask2, 'red');
        [DV, annotation] = manualSpline(annotation, rotMask2, 'blue');
        if isempty(AP) || isempty(DV)
           continue 
        end
        imshow(annotation,'InitialMagnification',200)
        save([settings.thruAxes currentFile{1} '.mat'], 'AP', 'DV', 'annotation');
    end
end
end