function means = cellMean(cellArray, type)

switch type
    case 'mean'
        for i = 1:length(cellArray)
            tempArray = cellArray{i};
            means(i) = nanmean(tempArray(:));
        end
    case 'median'
        for i = 1:length(cellArray)
            tempArray = cellArray{i};
            means(i) = nanmedian(tempArray(:));
        end
end

end

