function makeGraphs(dataTable)
%% Cluster Analysis
% Get data
% data = getData(structMaps, axesMat, maskMat, settings);
% 
% fields = fieldnames(data);
% for i = 1:length(fields)
%     data.(fields{i}) = double(data.(fields{i})');
% end

% laserPower = dataTable.laserPower;

% datatable = struct2table(data);

% newTable.A = dataTable.meanA;
% newTable.P = dataTable.meanP;

dataTable1 = dataTable;
dataTable1(dataTable1.category ~= 'control', :) = [];

% datatable.meanBasal = datatable.meanBasal .* (50 ./ laserPower');
% datatable.stdBasal = datatable.stdBasal .* (50 ./ laserPower');
% datatable = datatable(goodLaser, :);
dataTable1.PminusA = dataTable1.meanP - dataTable1.meanA;

% normalizedPredictors = table2array(dataTable1)';
% normalizedPredictors = normalizedPredictors - mean(normalizedPredictors, 2);
% normalizedPredictors = normalizedPredictors ./ mad(normalizedPredictors, [], 2);
% [coeff,score,latent,tsquared,explained,mu] = pca(normalizedPredictors([5:2:10,12:end],:));

% [~,U] = fcm(coef(:,1:3),2);
classes = kmeans(coeff(:,cumsum(explained)<95),2,'Replicates', 100);
% classes = clusterdata(coeff(:,1:3),2);
% size1 = nanmean(pouchSizes(classes == 1));
% size2 = nanmean(pouchSizes(classes == 2));
% size3 = nanmean(pouchSizes(classes == 3));
% if size1 > size2 
%     classes(classes == 1) = -1;
%     classes(classes == 2) = 1;
%     classes(classes == -1) = 2;
% end
% if size3 > size2
%     classes(classes == 3) = 2;
% else
%     classes(classes == 3) = 1;
% end
close all

%% Make graphs for Fig 3
% Obtain control data and prepare output
%[catFinalFig3, structMapsFig3, labelsFig3, maskFig3, axesFig3, pouchSizes3] = cleanDataset(category, categorical({'control'}), structMaps, labels, maskMat, axesMat, pouchSizes);
% if nanmean(pouchSizes(classes == 1)) > nanmean(pouchSizes(classes == 2))
%     classes(classes == 1) = 3;
%     classes(classes == 2) = 1;
%     classes(classes == 3) = 2;
% end

% Remove data where laser power was not 44%
% remove = ~goodLaser;
% labelsFig3(remove)    = [];
% catFinalFig3(remove)    = [];
% structMapsFig3(remove)  = [];
% maskFig3(remove)        = [];
% axesFig3(remove)        = [];
% pouchSizes3(remove)     = [];
% classes = 1 + (pouchSizes3' > 1.3e4) + (pouchSizes3' > 1.9e4);
classes = uint8(pouchSizes3' > 1.6e4) + 1;

%metadata = figure3graphs(pouchSizes3, structMapsFig3, axesFig3, maskFig3, settings, classes);

print([settings.outRough 'Graph.pdf'], '-dpdf', '-r600')
end

