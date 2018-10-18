% Returns a matrix where the rows are different bins and the columns are
% timepoints. Gets all of the profiles.

function getAllProfiles(settings)

labels = getLabels(settings);

labelIndex = 1:length(labels);
intensityProfiles = nan(5000000, 361);
k = 1;

for i = 1:length(labelIndex)
    clear video
    
    disp(['Loading video ' num2str(i) ' of ' num2str(length(labelIndex)) ' | ' labels{labelIndex(i)}]);
    
    load([settings.thruRot labels{labelIndex(i)} '.mat'],'croppedVideo');
    load([settings.thruMask labels{labelIndex(i)} '.mat'],'rotMask');
    
    mask = rotMask;
    boundBox = regionprops(mask,'BoundingBox');
    
    for slice = 1:size(croppedVideo, 3)
        video(:,:,slice) = imcrop(squeeze(croppedVideo(:,:,slice) .* mask), boundBox.BoundingBox);
    end
    
    [videoBins, ~] = videoCutter(video, settings);
    
    for j = 1:length(videoBins)
        profile  = squeeze(nanmean(nanmean(videoBins{j})));
        intensityProfiles(k, 1:length(profile)) = profile;
        k = k + 1;
    end
end

save(settings.matProfiles, 'intensityProfiles', '-v7.3')

end

