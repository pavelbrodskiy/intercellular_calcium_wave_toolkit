% This function makes a figure panel for control data with discs falling
% into different size bins.

function metadata = graphSsRegression(structMaps, name, category, catList, settings, pouchSizes, sizeBins)
%% Parse Inputs (Lazy)
fieldNames = settings.fieldNames;
fieldLabels = settings.fieldLabels;
if nargin < 6
    sizeBins = [0, inf];
    pouchSizes = ones(size(structMaps));
end
if nargin < 7
    sizeBins = [0, inf];
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
    subplot(2,2,i)
    fieldVals = [values(:,1).(fieldNames{i})];
    
    wholeMean = {};
    finalCatList = categorical();
    for j = 1:length(catList)
        if sum(categorySizeBin == catList(j)) > 0
            wholeMean{end+1} = fieldVals(categorySizeBin == catList(j));
            finalCatList(end+1) = catList(j);
        else
            continue
        end
        
        scatter(pouchSizes(categorySizeBin == catList(j)), wholeMean{j}, '.');
        p = polyfit(pouchSizes(categorySizeBin == catList(j)), wholeMean{j},1);
        f = polyval(p,linspace(min(pouchSizes(categorySizeBin == catList(j))),max(pouchSizes(categorySizeBin == catList(j))),1000));
        hold on
        plot(linspace(min(pouchSizes(categorySizeBin == catList(j))),max(pouchSizes(categorySizeBin == catList(j))),1000),f,'--r')
        xlabel('Pouch size (\um^2)')
        ylabel(fieldLabels{i});
    
        metadata.size{j} = pouchSizes(categorySizeBin == catList(j));
        metadata.fieldMean{i,j} = wholeMean{j};
        metadata.R2(j, i) = corr(pouchSizes(categorySizeBin == catList(j))', wholeMean{j}');
        print([settings.outRough settings.uniqueIdentifier '_' name '_' char(catList(j)) '.png'],'-dpng','-r600')
    end
        
end

    
%% Make graph for each set of positional information
close all
for i = 1:length(fieldNames)
    subplot(2,2,i)
    
    data = {};
    finalCatList = categorical();
    for j = 1:length(catList)
        if sum(categorySizeBin == catList(j)) > 0
            tmp = [];
            for k = find(categorySizeBin == catList(j))
                tmp(end+1,:) = [values(k,2:end).(fieldNames{i})];
            end
            sizes = pouchSizes(categorySizeBin == catList(j));
            data{end+1} = tmp;
            finalCatList(end+1) = catList(j);
        end
    end
    
    for j = 1:length(data)
        tmp = data{j};
        metadata.compartmentData{j, i} = data{j};
        
        ratios = (tmp(:,2) - tmp(:,1)) ./ tmp(:,1);
        ratios(tmp(:,1) == 0 | tmp(:,2) == 0) = 1;
        
        scatter(sizes, ratios, '.');
        p = polyfit(sizes', ratios,1);
        f = polyval(p,linspace(min(sizes),max(sizes),1000));
        hold on
        plot(linspace(min(sizes),max(sizes),1000),f,'--r')
        xlabel('Pouch size (\um^2)')
        ylabel(['(A-P)/mean of ' fieldLabels{i}]);
    
        
        metadata.R2ratio(j, i) = corr(sizes', ratios);
    end
    metadata.finalCatList = finalCatList;
end

print([settings.outRough settings.uniqueIdentifier '_' name '_' fieldNames{i} '_' char(finalCatList(j)) '_ratio.png'],'-dpng','-r600')
        



















