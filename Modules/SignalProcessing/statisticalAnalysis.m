function [ANOVA, stud, wilc, data] = statisticalAnalysis(structMaps, category, catList, maskMat, axesMat, pouchSizes, sizeBins, settings)

%% Get means
for i = 1:length(structMaps)
    for j = 1:length(settings.fieldNames)
        medians(i,j) = nanmedian(nanmedian(structMaps(i).(settings.fieldNames{j})));
    end
end

ANOVA = false;

%% Perform ANOVA on categorical data
% relevantMedians = [];
% relevantCategories = [];
% for i = 1:length(catList)
%     relevantMedians = [relevantMedians; medians(category == catList(i),:)];
%     relevantCategories = [relevantCategories; repmat(catList(i),[sum(category == catList(i)),1])];
% end
% 
% for j = 1:length(settings.fieldNames)
%     [ANOVA.p(j),ANOVA.tbl{j},ANOVA.stats{j}] = anova1(relevantMedians(:,j),relevantCategories, false);
% end
% ANOVA.fieldNames = settings.fieldNames;

%% Categorical tests for figure 4
for i = 1:length(catList)
    for j = 1:length(catList)
        for k = 1:length(settings.fieldNames)
            [~, stud.Fig4(i,j,k)] = ttest2(medians(category == catList(i),k), medians(category == catList(j),k));
            wilc.Fig4(i,j,k) = ranksum(medians(category == catList(i),k), medians(category == catList(j),k));
        end
    end
end


for i = 1:length(catList)
    for k = 1:length(settings.fieldNames)
        data.means(i,k) = nanmean(medians(category == catList(i),k));
        data.stds(i,k) = nanstd(medians(category == catList(i),k));
    end
end
% for k = 1:length(settings.fieldNames)
%     clear tmpMat
%     tmpMat = zeros(size(stud.Fig4(:,:,k)));
%     tmpMat(stud.Fig4(:,:,k) < 0.05) = 1;
%     tmpMat(stud.Fig4(:,:,k) < 0.01) = 2;
%     tmpMat(stud.Fig4(:,:,k) < 0.001) = 3;
%     
%     HeatMap(tmpMat, 'RowLabels', cellstr(catList), 'ColumnLabels', cellstr(catList))
% end

%% Compare A and P
values = spatialMapMedian(structMaps, spatialCutoffs(axesMat, maskMat, settings, false), [0, 1], @nanmedian);
for i = 1:length(catList)
    for k = 1:length(settings.fieldNames)
        [~, stud.Fig3(i,k)] = ttest(...
            [values(category == catList(i),2).(settings.fieldNames{k})], ...
            [values(category == catList(i),3).(settings.fieldNames{k})]);
        wilc.Fig3(i,k) = signrank(...
            [values(category == catList(i),2).(settings.fieldNames{k})], ...
            [values(category == catList(i),3).(settings.fieldNames{k})]);
    end
end

%% Get size bin categories
sizeBin = zeros(size(pouchSizes))';
for i = 1:length(sizeBins) - 1
    sizeBin(pouchSizes > sizeBins(i) & pouchSizes <= sizeBins(i+1)) = i;
    stud.sizeBin{i} = [num2str(sizeBins(i)) ' to ' num2str(sizeBins(i+1))];
end

stud.binIdentity = sizeBin;

for i = unique(sizeBin)'
    if ~i
        continue
    end
    for k = 1:length(settings.fieldNames)
        isControl = category == categorical({'control'});
        isSize = i == sizeBin';
        field = settings.fieldNames{k};
        [~, stud.Fig3size(i,k)] = ttest(...
            [values(isControl & isSize, 2).(field)], ...
            [values(isControl & isSize, 3).(field)]);
        wilc.Fig3size(i,k) = signrank(...
            [values(isControl & isSize, 2).(field)], ...
            [values(isControl & isSize, 3).(field)]);
    end
end



% for i = unique(sizeBin)'
%     for k = 1:length(settings.fieldNames)
%         isControl = category == categorical({'control'});
%         isSize = i == sizeBin';
%         field = settings.fieldNames{k};
%         [~, stud.Fig3size(i,k)] = ttest(...
%             [values(isControl & isSize, 2).(field)], ...
%             [values(isControl & isSize, 3).(field)]);
%         wilc.Fig3size(i,k) = signrank(...
%             [values(isControl & isSize, 2).(field)], ...
%             [values(isControl & isSize, 3).(field)]);
%     end
% end

%% Perform ANOVA on categorical data
% relevantMedians = [];
% relevantCategories = [];
% for i = 1:length(catList)
%     relevantMedians = [relevantMedians; medians(category == catList(i),:)];
%     relevantCategories = [relevantCategories; repmat(catList(i),[sum(category == catList(i)),1])];
% end
% 
% for j = 1:length(settings.fieldNames)
%     [ANOVA.p(j),ANOVA.tbl{j},ANOVA.stats{j}] = anova1(relevantMedians(:,j),relevantCategories, false);
% end
% ANOVA.fieldNames = settings.fieldNames;










    