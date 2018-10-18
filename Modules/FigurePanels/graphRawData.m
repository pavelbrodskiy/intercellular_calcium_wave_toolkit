% This function makes a figure panel for control data with discs falling
% into different size bins.

function metadata = graphRawData(structMaps, name, category, catList, settings, sizeBins, pouchSizes)
%% Parse Inputs (Lazy)
fieldNames = settings.fieldNames;
fieldLabels = settings.fieldLabels;
doGraphs = true;
if nargin < 6
    sizeBins = [0, inf];
    pouchSizes = ones(size(structMaps));
end

%% Clean Dataset
keep = zeros(size(category));
catList = unique(catList);
for currentCat = unique(catList)'
    keep(category == currentCat) = 1;
end
structMaps(~keep) = [];
category(~keep) = [];
AP = settings.AP;
AP(~keep,:) = [];
structMapsReduced = reduceStructFields(structMaps, fieldNames);

%% Split dataset by bin size
sizeBin = zeros(size(pouchSizes))';
for i = 1:length(sizeBins) - 1
    sizeBin(pouchSizes > sizeBins(i) & pouchSizes <= sizeBins(i+1)) = i;
end
if length(sizeBins) > 2
    for i = 1:length(category)
        categorySizeBin(i) = categorical({[char(category(i)), ' ' num2str(sizeBins(sizeBin(i))) ' to ' num2str(sizeBins(sizeBin(i)+1))]});
    end
    catList = unique(categorySizeBin);
else
    categorySizeBin = category;
end

%% Get map medians
values = spatialMapMedian(structMapsReduced, AP, settings.DV);

%% Make graph for each field
for i = 1:length(fieldNames)
    fieldVals = [values(:,1).(fieldNames{i})];
    
    data = {};
    finalCatList = categorical();
    for j = 1:length(catList)
        if sum(categorySizeBin == catList(j)) > 0
            data{end+1} = fieldVals(categorySizeBin == catList(j));
            finalCatList(end+1) = catList(j);
        end
    end
    
    metadata.rawData{i} = data;
    metadata.cats{i} = finalCatList;
    
    if doGraphs
    handles = plotSpread(data,[],[],cellstr(finalCatList),5,[1,(1:length(finalCatList)-1)+2]);
    handles{3}.XTickLabelRotation = 90;
    
    ylabel(fieldLabels{i});
    
    print([settings.outRough settings.uniqueIdentifier '_' name '_' fieldNames{i} '.png'],'-dpng','-r600')

    end
end

%% Make graph for each set of positional information
if size(values, 2) > 1
for i = 1:length(fieldNames)
    close all
    
    data = {};
    finalCatList = categorical();
    for j = 1:length(catList)
        if sum(categorySizeBin == catList(j)) > 0
            tmp = [];
            for k = find(categorySizeBin == catList(j))
                tmp(end+1,:) = [values(k,2:end).(fieldNames{i})];
            end
            data{end+1} = tmp;
            finalCatList(end+1) = catList(j);
        end
    end
    
    metadata.finalCatList = finalCatList;
    
    for j = 1:length(finalCatList)
        close all
        if doGraphs
            handles = plotSpread(data{j},[],[],{'Anterior', 'AP Boundary', 'Posterior'}, 5);
            handles{3}.XTickLabelRotation = 90;
            
            ylabel(fieldLabels{i});
            
            print([settings.outRough settings.uniqueIdentifier '_' name '_' fieldNames{i} '_' char(finalCatList(j)) '.png'],'-dpng','-r600')
        end
        % Signifigance testing
        tmpData = data{j};
        metadata.n(j,i) = size(tmpData, 1);
        metadata.means{i,j} = tmpData;
        switch size(tmpData,2)
            case 2
                [~, metadata.pAP(j,i)] = ttest(tmpData(:,1), tmpData(:,2));
            case 3
                [~, metadata.pAnterior(j,i)] = ttest(tmpData(:,1), tmpData(:,2));
                [~, metadata.pPosterior(j,i)] = ttest(tmpData(:,2), tmpData(:,3));
                [~, metadata.pAP(j,i)] = ttest(tmpData(:,1), tmpData(:,3));
            otherwise
                error('more than three compartments')
        end
    end
end
end
metadata.nTests = length(fieldNames)*length(finalCatList);
% metadata.pAdjusted = cat(3, metadata.pAnterior, metadata.pPosterior, metadata.pAP) * metadata.nTests;

% metadata.resultsTable = table({metadata.finalCatList', metadata.pAnterior
















