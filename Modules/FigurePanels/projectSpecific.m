function [medianStruct, metadata] = projectSpecific(category, structMaps, size, specificCat, binCutoffs)
%% Parse Inputs (lazy)
% cutoffs = (13:2:21)*1e3; % array for cutoff values for pouch size
sigFigs = 2;

%% Cut out short videos
% load('totalTime.mat','totalTime')
% category = category(totalTime > 200);
% structMaps = structMaps(totalTime > 200);
% size = size(totalTime > 200);

%% Separate out control data
isControl = category == specificCat; % Indices of control discs
controlStructMaps = structMaps(isControl); % Spatial maps of control discs
controlMaskSize = size(isControl); % Pouch area of control discs

%% Determine the cutoffs for each bin
if ~exist('cutoffs')
    cutoffs = [0 roundsd(prctile(controlMaskSize, binCutoffs), sigFigs) 1e20];
end

%% Find which bin each disc should go in
sizeBin = discretize(controlMaskSize, cutoffs);
nonNanMaps = controlStructMaps(~isnan(sizeBin));
nanNanSizeBin = sizeBin(~isnan(sizeBin));
catSizeBin = categorical(nanNanSizeBin, nanmin(nanNanSizeBin):nanmax(nanNanSizeBin));

%% Median projections of controls by size
[medianStruct, metadata.n, metadata.conditions] = medianProjectSpatialMaps(nonNanMaps, catSizeBin);

%% Statistically compare discs of different sizes
if nargout > 1
    fieldNames = fieldnames(controlStructMaps);
    
    for i = 1:length(fieldNames)
        disp(['Analyzing: ' fieldNames{i}])
        
        medianArray = cellMean({controlStructMaps.(fieldNames{i})}, 'median');
        
        [metadata.ANOVA.p{i},metadata.ANOVA.tbl{i},metadata.ANOVA.stats{i}] = anova1(medianArray, sizeBin);
        metadata.medianArray{i} = medianArray;
    end
    
    metadata.sizeBin = sizeBin;
    metadata.fieldNames = fieldNames;
    metadata.discSize = controlMaskSize;
    metadata.binSizes = cutoffs;
end