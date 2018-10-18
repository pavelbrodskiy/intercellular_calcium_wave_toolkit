% This function makes a figure panel for control data with discs falling
% into different size bins.

function metadata = figCompareAP(structMaps, name, category, catList, settings, sizeBins, pouchSizes, doGraphs, type)
%% Parse Inputs (Lazy)
fieldNames = settings.fieldNames;
fieldLabels = settings.fieldLabels;
if nargin < 6 || isempty(pouchSizes) || isempty(sizeBins)
    sizeBins = [0, inf];
    pouchSizes = ones(size(structMaps));
end
if size(sizeBins) == 1
    numSizeBins = sizeBins + 1;
    sortSize = sort(pouchSizes);
    idxSort = round(linspace(1,length(pouchSizes),numSizeBins));
    sizeBins = sortSize(idxSort);
    sizeBins = [-inf roundsd(sizeBins(2:end-1), 2) inf];
end
if nargin < 9
    type = 'violin';
end
if nargin < 8
    doGraphs = true;
end
%sizeBins = [roundsd(sizeBins(1), 2, 'floor') roundsd(sizeBins(2:end-1), 2) roundsd(sizeBins(end), 2, 'ceil')];

%% Clean Dataset
keep = zeros(size(category));
% catList = unique(catList);
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
    clear newCat
    for j = 1:length(catList)
        for i = 1:length(sizeBins)-1
            newCat(j,i) = categorical({[char(catList(j)), ' ' num2str(sizeBins(i)) ' to ' num2str(sizeBins(i+1))]});
        end
    end
    for i = 1:length(category)
        categorySizeBin(i) = newCat(category(i)==catList,sizeBin(i));
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
    
    metadata.rawData{i,j} = data;
    if doGraphs
        
    handles = plotSpread(data,[],[],cellstr(finalCatList),5,[1,(1:length(finalCatList)-1)+2]);
    handles{3}.XTickLabelRotation = 90;
    
    ylabel(fieldLabels{i});
    end
end
if doGraphs
print([settings.outRough settings.uniqueIdentifier '_' name '_summaryStatGraph.png'],'-dpng','-r600')
end

%% Make graph for each set of positional information
if size(values, 2) > 1
for i = 1:length(fieldNames)
    nMat = [];
    close all
    
    data = {};
    finalCatList = categorical();
    for j = 1:length(catList)
        n = sum(categorySizeBin == catList(j));
        if n > 0
            nMat(end+1) = n;
            tmp = [];
            for k = find(categorySizeBin == catList(j))
                tmp(end+1,:) = [values(k,2:end).(fieldNames{i})];
            end
            data{end+1} = tmp;
            finalCatList(end+1) = catList(j);
        end
    end
    
    metadata.finalCatList = finalCatList;
    
    [~, p, test] = graphCompareViolin(data, finalCatList, type);
    
    metadata.p{i} = p;
    metadata.test{i} = test;
    metadata.n = nMat;
    
    if doGraphs
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 3 2];
    ylabel(settings.fieldLabels{i});
    %gca.XTickLabelRotation=45;
    
    print([settings.outRough settings.uniqueIdentifier '_' fieldNames{i} '_' name '_summaryStatGraph.png'],'-dpng','-r600')
    print2eps([settings.outRough settings.uniqueIdentifier '_' fieldNames{i} '_' name '_summaryStatGraph.eps'])
    end
end
%     for j = 1:length(finalCatList)
%         close all
%         if doGraphs
%             handles = plotSpread(data{j},[],[],{'Anterior', 'AP Boundary', 'Posterior'}, 5);
%             handles{3}.XTickLabelRotation = 90;
%             
%             ylabel(fieldLabels{i});
%             
%             print([settings.outRough settings.uniqueIdentifier '_' name '_' fieldNames{i} '_' char(finalCatList(j)) '.png'],'-dpng','-r600')
%         end
%         % Signifigance testing
%         tmpData = data{j};
%         metadata.n(j,i) = size(tmpData, 1);
%         metadata.means{i,j} = tmpData;
%         switch size(tmpData,2)
%             case 2
%                 [~, metadata.pAP(j,i)] = ttest(tmpData(:,1), tmpData(:,2));
%             case 3
%                 [~, metadata.pAnterior(j,i)] = ttest(tmpData(:,1), tmpData(:,2));
%                 [~, metadata.pPosterior(j,i)] = ttest(tmpData(:,2), tmpData(:,3));
%                 [~, metadata.pAP(j,i)] = ttest(tmpData(:,1), tmpData(:,3));
%             otherwise
%                 error('more than three compartments')
%         end
%     end
end

metadata.sdfsdf = [];

% metadata.nTests = length(fieldNames)*length(finalCatList);
% metadata.pAdjusted = cat(3, metadata.pAnterior, metadata.pPosterior, metadata.pAP) * metadata.nTests;

% metadata.resultsTable = table({metadata.finalCatList', metadata.pAnterior
















