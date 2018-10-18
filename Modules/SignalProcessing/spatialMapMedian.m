function [values, metadata] = spatialMapMedian(spatialMaps, AP, DV, f)
%% Lazy Parameters
strel1 = strel('disk',2);

if nargin < 2
    AP = [0, 1];
end
if nargin < 3
    DV = [0, 1];
end
if nargin < 4
    f = @nanmedian;
end

if size(AP, 1) == 1
    AP = repmat(AP, [length(spatialMaps), 1]);
end
if size(DV, 1) == 1
    DV = repmat(DV, [length(spatialMaps), 1]);
end

%% Extract medians
fieldNames = fieldnames(spatialMaps);
discs = length(spatialMaps);

for i = 1:length(fieldNames)
    for j = 1:discs
        if all(isnan(spatialMaps(j).Amp))
            for k = 1:size(values, 2)
                values(j,k).(fieldNames{i}) = NaN;
                
            end
            continue
        end
        
        mask = ~isnan(spatialMaps(j).Amp);
        mask([1,end],:) = 0;
        mask(:,[1,end]) = 0;
        mask = imerode(mask,strel1);
        
        map = spatialMaps(j).(fieldNames{i});
        
        values(j,1).(fieldNames{i}) = medianBounds(mask, map, [0,1], [0,1],f);
        if AP(j,1) ~= 0 || AP(j,2) ~= 1
            for k = 1:size(AP,2) - 1
                values(j,k+1).(fieldNames{i}) = medianBounds(mask, map, AP(j,k:k+1), [0,1],f);
            end
        end
        if DV(j,1) ~= 0 || DV(j,2) ~= 1
            for k = 1:size(DV,2) - 1
                values(j,k+1+length(AP)).(fieldNames{i}) = medianBounds(mask, map, [0,1], DV(j,k:k+1),f);
            end
        end
    end
end

end

