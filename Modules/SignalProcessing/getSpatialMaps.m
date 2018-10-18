% This script generates spatial maps for grids of square RoIs superimposed
% on wing disc videos that have been rotated and cropped to standard
% orientation. Then a composite is generated where the individual samples
% have been mapped onto a wing disc pouch coordinate system. This analysis
% can be run on any summary statistic that can be extracted from intensity
% over time.

%% Clear the workspace
error('You havent written this yet');
clearvars
settings = prepareWorkspace();

%% Declare operational parameters
[labels, category] = getLabels(settings);
binSizePixels = 2;
rescaleSize = 1;
dilationElement = strel('diamond', 0);
maxSize = [1500, 1500];

%% Extract spatial maps
for k = length(labels):-1:1
    disp(['Getting spatial maps: ' labels{k} '']);
    
    % Load the cropped and rotated videos
    load([settings.thruRot labels{k} '.mat'],'croppedVideo');
    load([settings.thruSeg labels{k} '.mat'],'mask');
    boundBox = regionprops(mask,'BoundingBox');
    maskArray{k} = mask;
    
    clear 'video'
    for slice = 1:size(croppedVideo, 3)
        video(:,:,slice) = imcrop(squeeze(croppedVideo(:,:,slice) .* mask), boundBox.BoundingBox);
    end

    % Pad the videos
%     video = padToSize(video, maxSize);
    [m, n, t] = size(video);
    
    % Extract summary statistics for each video bin
    anal = settings.analysis;
    anal.binDimension = binSizePixels;
    [videoBins, binCoords] = videoCutter(video, anal); % Make video bins
    
    % Make maps of summary statistics from video bins
    clear 'stats'
    for i = length(videoBins):-1:1
        stats(i) = extractStatisticsFromBin(videoBins{i}, settings);
    end
    
    structMaps(k) = bins2maps(stats, binCoords');
end

saveName = [settings.outAnalysis 'Spatial map dump ' settings.uniqueIdentifier '.mat'];
save(saveName,'maskArray','labels','category','binSizePixels','rescaleSize','dilationElement','maxSize','structMaps');
