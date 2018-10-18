% Obtains a list of all experiments conducted from the reference
% spreadsheet. Removes categories specified by keepCat. Removes videos
% shorter than minimum length set in settings. Removes videos in the manual
% reject file.

function [labels, category, finalCat, metadata, fluttering] = getLabels(settings, rejectFlutter, keepCat)
metadata.flag = 0;
if nargin < 2
   rejectFlutter = false; 
end

%% Obtain a list of the experiments that are in the analysis folder.
[~, labelTabel] = xlsread(settings.labelTabel);
labels = labelTabel(:,1);
category = categorical(labelTabel(:,2))';
finalCat = categorical(labelTabel(:,3))';

%% Remove videos shorter than the minimum length
timeMat = getTime(labels, settings);
labels(timeMat < settings.minTime) = [];
category(timeMat < settings.minTime) = [];
finalCat(timeMat < settings.minTime) = [];

%% Identify videos in the reject table
if exist(settings.rejectTabel, 'file')
    rejectTable = readtable(settings.rejectTabel);
    if ~isempty(rejectTable)
        indexReject = ismember(labels,rejectTable.Label);
        
        flutterTabel = readtable(settings.flutterTabel);
        indexFlutter = ismember(labels,flutterTabel.Label);
        if rejectFlutter
            index = find(indexReject | indexFlutter);
        else
            index = find(indexReject);
        end
    else
       indexReject = zeros(1, length(labels), 'logical');
       indexFlutter = zeros(1, length(labels), 'logical');
       index = [];
    end
end
indexReject = indexReject';
if ~rejectFlutter
    indexFlutter = zeros(1, length(labels), 'logical');
end

%% Calculate sample sizes
catList = unique(category);
if nargin <= 2
    metadata.rough.category = catList;
    for i = 1:length(catList)
        metadata.rough.nTotal(i) = sum(catList(i) == category);
        metadata.rough.nFlutter(i) = sum(catList(i) == category(indexFlutter));
        metadata.rough.nReject(i) = sum(catList(i) == category(indexReject));
        metadata.rough.n(i) = sum(catList(i) == category(~(indexReject | indexFlutter)));
    end
end

catList = unique(finalCat);
if nargin <= 2
    metadata.final.category = catList;
    for i = 1:length(catList)
        metadata.final.nTotal(i) = sum(catList(i) == finalCat);
        metadata.final.nFlutter(i) = sum(catList(i) == finalCat(indexFlutter));
        metadata.final.nReject(i) = sum(catList(i) == finalCat(indexReject));
        metadata.final.n(i) = sum(catList(i) == finalCat(~(indexReject | indexFlutter)));
    end
end

%% Remove videos in the reject table
if exist(settings.rejectTabel, 'file') 
    labels(index) = [];
    category(index) = [];
    finalCat(index) = [];
end

%% Remove unneeded labels if requested
if nargin > 2
    keep = false(size(category));
    for tmpCat = unique(keepCat)
        keep(category == tmpCat) = 1;
    end
    
    labels = labels(keep);
    finalCat = finalCat(keep);
    category = category(keep);
    indexFlutter = indexFlutter(keep);
    indexReject = indexReject(keep);
    indexReject = indexReject';
    
    metadata.final.category = unique(finalCat);
    
    indexReject = indexReject';
    
    for i = 1:length(metadata.final.category)
        metadata.final.nTotal(i) = sum(metadata.final.category(i) == finalCat);
        metadata.final.nFlutter(i) = sum(metadata.final.category(i) == finalCat(indexFlutter));
        metadata.final.nReject(i) = sum(metadata.final.category(i) == finalCat(indexReject));
        metadata.final.n(i) = sum(metadata.final.category(i) == finalCat(~(indexReject | indexFlutter)));
    end
    
    metadata.rough.category = unique(category);
    
    for i = 1:length(metadata.rough.category)
        metadata.rough.nTotal(i) = sum(metadata.rough.category(i) == category);
        metadata.rough.nFlutter(i) = sum(metadata.rough.category(i) == category(indexFlutter));
        metadata.rough.nReject(i) = sum(metadata.rough.category(i) == category(indexReject));
        metadata.rough.n(i) = sum(metadata.rough.category(i) == category(~(indexReject | indexFlutter)));
    end
end

category = category';
metadata.flag = 1;
fluttering = indexFlutter;
end

