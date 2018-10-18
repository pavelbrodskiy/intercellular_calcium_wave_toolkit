% This script generates spatial maps for grids of square RoIs superimposed
% on wing disc videos that have been rotated and cropped to standard
% orientation. Then a composite is generated where the individual samples
% have been mapped onto a wing disc pouch coordinate system. This analysis
% can be run on any summary statistic that can be extracted from intensity
% over time.

function [PSD, freq] = makePSDs(croppedVideo, mask, settings)
mask = logical(mask);
mask = repmat(mask, [1, 1, size(croppedVideo, 3)]);

video = double(croppedVideo);
video(~mask) = NaN;

videoBins = videoCutter(video, settings);

t = (0:(size(video,3)-1))*10;

for j = length(videoBins):-1:1
    I = squeeze(mean(mean(videoBins{j},2),1))';
    [PSD(j,:), freq(j,:)] = spectralDensityEstimate(I, t);
end

end