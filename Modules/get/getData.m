
function data = getData(structMaps, axes, masks, settings)
% Obtain summary statistics
values = spatialMapMedian(structMaps, spatialCutoffs(axes, masks, settings, false), [0, 1], @(arg) {arg});

for i = size(values, 1):-1:1
    % Get A and P summary statistics for amplitude
	data.meanA(i) = nanmean(values(i,2).PeakRate{1});
    data.stdA(i) = nanstd(values(i,2).PeakRate{1});
    data.meanP(i) = nanmean(values(i,3).PeakRate{1});
    data.stdP(i) = nanstd(values(i,3).PeakRate{1});
    
    % Get summary statistics for whole pouch
    data.meanFreq(i) = nanmean(values(i,1).PeakRate{1});
    data.stdFreq(i) = nanstd(values(i,1).PeakRate{1});
    data.meanWHM(i) = nanmean(values(i,1).WHM{1});
    data.stdWHM(i) = nanstd(values(i,1).WHM{1});
    data.meanBasal(i) = nanmean(values(i,1).Basal{1});
    data.stdBasal(i) = nanstd(values(i,1).Basal{1});
end
end

