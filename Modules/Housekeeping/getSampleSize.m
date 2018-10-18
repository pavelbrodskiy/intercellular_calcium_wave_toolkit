function [n, N, conditionTable] = getSampleSize(labels, category, catList)
%% Lazy parameter declaration
if nargin < 3
    catList = unique(category);
end

catList = [catList(:)'];

%% Make tables
for i = 1:length(catList)
    idx = find(category == catList(i))';
    dates = {};
    for j = idx'
        tmpLabel = labels{j};
        idxPeriod = strfind(tmpLabel, '.');
        dates{end+1} = tmpLabel(idxPeriod(1)-2:idxPeriod(1)+8);
    end
    N(i) = length(unique(dates));
    n(i) = length(idx);
end

conditionTable = table(catList', n', N','VariableNames', {'Condition','SampleSize','ImagingSessions'});