% This script generates spatial maps for grids of square RoIs superimposed
% on wing disc videos that have been rotated and cropped to standard
% orientation. Then a composite is generated where the individual samples
% have been mapped onto a wing disc pouch coordinate system. This analysis
% can be run on any summary statistic that can be extracted from intensity
% over time.

function [structMap, binCoordsActual, stats] = makeSpatialMaps(croppedVideo, mask, settings, croppedRFP, croppedDfOverF)
mask = logical(mask);
mask = repmat(mask, [1, 1, size(croppedVideo, 3)]);

video = double(croppedVideo);
video(~mask) = NaN;
video(:,:,(settings.maxTime+1):end) = [];

[videoBins, binCoords, binCoordsActual] = videoCutter(video, settings);

if nargin > 3
    video = double(croppedRFP);
    video(~mask) = NaN;
    video(:,:,(settings.maxTime+1):end) = [];
    
    [RFPBins, ~, ~] = videoCutter(video, settings);
    
    video = double(croppedDfOverF);
    video(~mask) = NaN;
    video(:,:,(settings.maxTime+1):end) = [];
    
    [DfOverF_Bins, ~, ~] = videoCutter(video, settings);
end

failed = zeros(1,length(videoBins));
for i = length(videoBins):-1:1
    if isnumeric(videoBins)
        failed(i) = i;
        continue
    end
    I = squeeze(mean(mean(videoBins{i},2),1));
    if all(isnan(I))
        failed(i) = i;
        continue
    end
    if nargin > 3 && length(RFPBins) == length(videoBins)
        RFP = squeeze(mean(mean(RFPBins{i},2),1));
        dF_over_f = squeeze(mean(mean(DfOverF_Bins{i},2),1));
    else
        RFP = nan(size(I));
        dF_over_f = nan(size(I));
    end
    stats(i) = extractStats(I, settings, RFP, dF_over_f);
end

if any(~failed)
    structMap = bins2maps(stats(~failed), binCoords(~failed,:)', settings);
    fieldNames = fieldnames(stats(1));
    fieldNames(strcmp(fieldNames, 'basaldFoverF')) = [];
    clear statsNew
    for j = 1:length(fieldNames)
        statsNew.(fieldNames{j}) = [stats.(fieldNames{j})];
    end
    stats = statsNew;
else
    structMap = nan;
    binCoordsActual = nan;
    stats = nan;
end
end
% end