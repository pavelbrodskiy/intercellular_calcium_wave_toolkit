

function metadata = figure3graphs(pouchSize, structMaps, axes, masks, settings, classes)
metadata.h = figure;

% Sort data by pouch size
[pouchSize, idx] = sort(pouchSize);

structMaps = structMaps(idx);
axes = axes(idx);
masks = masks(idx);
classes = classes(idx);

% Obtain summary statistics
values = spatialMapMedian(structMaps, spatialCutoffs(axes, masks, settings, false), [0, 1], @(arg) {arg});

for i = size(values, 1):-1:1
    % Get A and P summary statistics for amplitude
	meanA(i) = nanmean(values(i,2).AmpNorm{1});
    stdA(i) = nanstd(values(i,2).AmpNorm{1});
    meanP(i) = nanmean(values(i,3).AmpNorm{1});
    stdP(i) = nanstd(values(i,3).AmpNorm{1});
    
    % Get summary statistics for whole pouch
    meanFreq(i) = nanmean(values(i,1).PeakRate{1});
    stdFreq(i) = nanstd(values(i,1).PeakRate{1});
    meanWHM(i) = nanmean(values(i,1).WHM{1});
    stdWHM(i) = nanstd(values(i,1).WHM{1});
    meanBasal(i) = nanmean(values(i,1).Basal{1});
    stdBasal(i) = nanstd(values(i,1).Basal{1});
end

%% Figure 3b
close all
subplot(2,2,1)
classes_AP = (classes - 1) * 2 + 1;
classes_AP = [classes_AP; classes_AP + 1];
catClassesAP = categorical(classes_AP, 1:6, {'Small A', 'Small P', 'Medium A', 'Medium P', 'Large A', 'Large P'});
AP_table = table(catClassesAP, [meanA, meanP]');
a = unique(catClassesAP);
colors = [0,0,0;0,0,0;1,0,0;1,0,0;0,0,1;0,0,1];
colors = colors(1:length(a),:);
UnivarScatter(AP_table, 'PointStyle', '.', 'PointSize', 86, 'Width', 0.9, ...
    'Compression', 15, 'MarkerEdgeColor', colors)

%% Figure 3c
subplot(2,2,2)
modelfun = @(b,x)(b(1)+0*x);
plotWithRegression(pouchSize, meanFreq, stdFreq, modelfun, 0, classes, [], [0,inf,0,inf])
ylabel('Frequency (mHz)')

%% Figure 3d
subplot(2,2,3)
modelfun = @(b,x)(b(1)+b(2)*exp(-b(3)*x));
plotWithRegression(pouchSize, meanWHM, stdWHM, modelfun, [0;2000;1e-5], classes, [], [0,inf,0,inf])
ylabel('WHM (s)')

%% Figure 3e
subplot(2,2,4)
modelfun = @(b,x)(b(1)+b(2)*exp(-b(3)*x));
plotWithRegression(pouchSize, meanBasal, stdBasal, modelfun, [0;2000;1e-5], classes, [], [0,inf,0,2.1e3])
% set(gca,'XScale','log');
ylabel('Basal Intensity (au)')

end
