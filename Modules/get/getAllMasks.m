% Returns a matrix where the rows are different bins and the columns are
% timepoints. Gets all of the profiles.

function getAllMasks(settings)

labels = getLabels(settings);

labelIndex = 1:length(labels);
for i = 1:length(labelIndex)
    disp(['Loading video ' num2str(i) ' | ' labels{labelIndex(i)}]);
    
    imgArray{i} = imread([settings.inExperimentalData labels{labelIndex(i)} '.tif']);
    load([settings.thruRawMask labels{labelIndex(i)} '.mat'],'mask');
    maskArray{i} = mask;
end

save(settings.matMasks, 'imgArray', 'maskArray', '-v7.3')

end

