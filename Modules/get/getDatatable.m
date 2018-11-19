% dataTable = getDatatableNoAxes(settings, catList, force)
% Returns all available analysis of ICWs given the directories in the
% settings struct and given the values in the relevant metadata tables. If
% catList is specified, only processes selected categories. If force is
% not specified or is false, skips unprocessed data to save time.

function dataTable = getDatatable(settings, catList, force)
%% Parse inputs
if nargin == 1 || isempty(catList)
    [labels, category, catFinal] = getLabels(settings, false);
    catList = unique(category);
else
    [labels, category, catFinal] = getLabels(settings, false, catList);
end
if nargin < 3
    force = false;
end

%% If no labels, then return nothing
if isempty(labels)
    dataTable = [];
    return
end

%% Get data
[structMaps, statsArray, coords] = getSpatialMaps(labels, settings); % Spatial map
pouchSizes = getPouchSizes(labels, settings);
[APMat, DVMat] = getAxes(labels, settings, force);
geometries = getGeometry(labels, settings, force);

for i = 1:length(labels)
    if exist([settings.thruMask labels{i}, '.mat'], 'file')
        load([settings.thruMask labels{i}, '.mat'])
    else
        rotMask = NaN;
    end
    maskMat{i,1} = rotMask;
end

settings.outRough = settings.outFinal;
mkdir(settings.outRough);

%% Calcium sigunature measurement
% Obtain summary statistics
values_spatial = spatialMapMedian(structMaps, spatialCutoffs(APMat, maskMat, settings), [0, 1], @(arg) {arg});
fields = fieldnames(values_spatial);

% Generate averages for summary statistics and for anterior and posterior
% compartments
for i = size(values_spatial, 1):-1:1
    for j = 1:length(fields)
        if all(isnumeric(values_spatial(i,1).(fields{j}))) || all(isnan(values_spatial(i,1).(fields{j}){1}))
            meanDataTable(i,j) = nan;
            stdDataTable(i,j) = nan;
        else
            meanDataTable(i,j) = nanmean(values_spatial(i,1).(fields{j}){1});
            stdDataTable(i,j) = nanstd(values_spatial(i,1).(fields{j}){1});
        end
        if all(isnumeric(values_spatial(i,2).(fields{j}))) || all(isnan(values_spatial(i,2).(fields{j}){1}))
            meanDataTable_A(i,j) = nan;
            stdDataTable_A(i,j) = nan;
        else
            meanDataTable_A(i,j) = nanmean(values_spatial(i,2).(fields{j}){1});
            stdDataTable_A(i,j) = nanstd(values_spatial(i,2).(fields{j}){1});
        end
        if all(isnumeric(values_spatial(i,3).(fields{j}))) || all(isnan(values_spatial(i,3).(fields{j}){1}))
            meanDataTable_P(i,j) = nan;
            stdDataTable_P(i,j) = nan;
        else
            meanDataTable_P(i,j) = nanmean(values_spatial(i,3).(fields{j}){1});
            stdDataTable_P(i,j) = nanstd(values_spatial(i,3).(fields{j}){1});
        end
    end
end

%% Make table
dataTable = cat(2, table(labels, category, catFinal', pouchSizes', structMaps', APMat', DVMat', geometries', coords', statsArray', ...
    'VariableNames', {'labels','category','catFinal','pouchSizes','structMaps','APMat','DVMat','geometries', 'coords', 'statsArray'}), ...
                   array2table(meanDataTable, 'VariableNames', cellfun(@(x) ['mean_' x],fields, 'UniformOutput', false)), ...
                   array2table(meanDataTable_A, 'VariableNames', cellfun(@(x) ['mean_A_' x],fields, 'UniformOutput', false)), ...
                   array2table(meanDataTable_P, 'VariableNames', cellfun(@(x) ['mean_P_' x],fields, 'UniformOutput', false)), ...
                   array2table(stdDataTable, 'VariableNames', cellfun(@(x) ['std_' x],fields, 'UniformOutput', false)), ...
                   array2table(stdDataTable_A, 'VariableNames', cellfun(@(x) ['std_A_' x],fields, 'UniformOutput', false)), ...
                   array2table(stdDataTable_P, 'VariableNames', cellfun(@(x) ['std_P_' x],fields, 'UniformOutput', false)));

%% Import qualitative table and merge with data table
if exist(settings.qualitativeTabel, 'file')
    tblQualitative = readtable(settings.qualitativeTabel);
    tblQualitative.label = categorical(tblQualitative.label);
    tblQualitative.annotation = categorical(tblQualitative.annotation);
    annotationCats = unique(tblQualitative.annotation);
    tblQual = table();
    tblQual.labels = unique(tblQualitative.label);
    ignoreCats = any(annotationCats' == settings.ignoreCats');
    for i = 1:length(annotationCats)
        for j = 1:length(tblQual.labels)
            count(i,j) = sum(tblQualitative.label == tblQual.labels(j) & ...
                tblQualitative.annotation == annotationCats(i));
        end
    end
    for i = 1:length(annotationCats)
        tblQual.(['count_' char(annotationCats(i))]) = count(i,:)';
    end
    for i = 1:length(annotationCats)
        tblQual.(['frac_' char(annotationCats(i))]) = count(i,:)' ./ sum(count(~ignoreCats, :), 1)';
    end
    tblQual.labels = cellstr(tblQual.labels);
    dataTable = outerjoin(dataTable, tblQual, 'MergeKeys', true);
end

%% If Laser Power table exists, adds metadata to data table
if exist(['Inputs' filesep 'laserPower.csv'],'file')
    tblLaserPower = readtable(['Inputs' filesep 'laserPower.csv']);
    dataTable = outerjoin(dataTable, tblLaserPower, 'MergeKeys', true);
end

%% Unique row identifier is set to sample label
dataTable.Row = dataTable.labels;

%% Replace undefined categories
if ~isempty(catList) % If categories are specified, only return those in catList
    dataTable(isundefined(dataTable.category)&isundefined(dataTable.catFinal),:) = [];
else % If categories not specified, return everything
    dataTable.category(isundefined(dataTable.category)) = categorical({'undefined'});
    dataTable.catFinal(isundefined(dataTable.catFinal)) = categorical({'undefined'});
end
end

