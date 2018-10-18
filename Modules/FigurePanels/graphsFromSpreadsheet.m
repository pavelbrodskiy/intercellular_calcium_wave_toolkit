% This function makes a figure panel for control data with discs falling
% into different size bins.

function metadata = graphsFromSpreadsheet(structMaps, sheet, category, settings)
%% Parse Inputs (Lazy)
fieldNames = settings.fieldNames;
fieldLabels = settings.fieldLabels;

%% Read instructions
sheetName = [settings.inTables sheet];
[~, labelTabel] = xlsread(sheetName);
catList = categorical(labelTabel(:,1));

%% Lazy Input for figure-making function
pIN = settings.pIN;
pIN.labels = labelTabel(:,1);

%% Processes inputs
structMapsReduced = reduceStructFields(structMaps, fieldNames);

%% Prune category list
for j = 1:length(category)
    catTemp = find(category(j) == catList);
    if isempty(catTemp)
        cadIdx(j) = NaN;
    else
        cadIdx(j) = catTemp;
    end
end

%% Make graph for each field
for i = 1:length(fieldNames)
    disp(['Making graph for: ' fieldNames{i}])
    close all
    [hFig, metadata(i).means] = graphSummaryStats({structMapsReduced.(fieldNames{i})}, catList, pIN, category);

    ylabel(fieldLabels{i});
    
    graphSize = [0 0 0.2*length(metadata(i).means) 3];

    set(gcf, 'PaperPositionMode', 'auto','Units','inches','Position',graphSize);
    print([settings.outRough, settings.uniqueIdentifier, sheet, ' ', fieldNames{i}, 'GenotypeGraph.png'],'-dpng','-r600');
    %saveas(gcf,[settings.outRough, settings.uniqueIdentifier, sheet, ' ', fieldNames{i}, 'GenotypeGraph.eps'],'epsc')
end