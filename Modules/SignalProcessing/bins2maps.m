% This function takes a 1xN structure array with a 2xN position array and
% generates a scalar structure containing spatial maps of the 1xN array.
%
% INPUTS:
% structArray [1xN struct]  with k fields
% posArray    [2xN int]     x, y coordinates for each structArray element
% 
% OUTPUTS:
% structMaps  [struct]      with k fields, containing m x n maps where
%   m is the max of the x coordinates and n is the max of the y coordinates
%   in posArray.

function structMaps = bins2maps(structArray, posArray, settings)
    fields = fieldnames(structArray(1));

    minCoord = min(posArray, [], 2);
    posArray = posArray - repmat(minCoord, [1, size(posArray, 2)]) + 1;
    
    xMax = max(posArray(1,:));
    yMax = max(posArray(2,:));
    
    for k = 1:length(fields) % Make a map for each field
        tempMap = nan([xMax, yMax]);
        curField = fields{k};
        
        % Only make maps for fields that contain numbers
        if ~isnumeric(structArray(1).(curField))
            continue
        end
        
        % Make map for current field
        curArray = [structArray.(curField)];
        for i = 1:length(curArray)
            tempMap(posArray(1,i), posArray(2,i)) = curArray(i);
        end
        
        %resize = settings.analysis.binSize / settings.sizeStandard;
%         tempMap = imresize(tempMap, resize, 'nearest');
        
        structMaps.(curField) = tempMap;
    end
end

