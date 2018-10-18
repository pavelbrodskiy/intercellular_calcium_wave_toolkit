% Input an array of structMaps 1xN (where N is the number of individual 
% samples) with their respective categories. Then for each category, get a
% median projection, and return a cell-array of the median projections.

function [median, sampleSize, conditions] = medianProjectSpatialMaps(structMaps, category)
method = 2;
fields = fieldnames(structMaps(1));
conditions = unique(category);
if any(conditions == categorical({'control'}))
    conditions(conditions == categorical({'control'})) = [];
    conditions = [categorical({'control'}) conditions];
end
conditions = categorical(conditions, conditions);
for i = 1:length(fields)
    disp(['Mean projecting field ' num2str(i) ' of ' num2str(length(fields))]);
    for k = conditions
        imageArray = {structMaps.(fields{i})};
        rawStack = makeStackDiffSizes(imageArray, 'center');
        rawStack(:,:,category ~= k) = [];
        %rawStack(rawStack==0) = NaN;
        switch method
            case 1
                median(k).(fields{i}) = nanmedian(rawStack,3);
            case 2
                masks = zeros(size(rawStack));
                masks(~isnan(rawStack)) = 1;
                maskComposite = mean(double(masks),3);
                maskComposite = maskComposite > (size(masks,3) / 2);
                maskComposite = repmat(maskComposite, [1,1,size(masks,3)]);
                tmpComposite = nanmedian(rawStack,3);
                tmpComposite(~maskComposite) = nan;
                median(k).(fields{i}) = tmpComposite;
            otherwise
                error('no method')
        end
    end
    for k = conditions
        sampleSize(k) = sum(category == k);
    end
end
end

