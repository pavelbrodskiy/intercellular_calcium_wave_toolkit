% This function takes a cell array of spatial maps, and finds the mean
% value for each element. Then plots mean and standard deviation as a bar
% graph, and labels each bar. Each bar is a category (ie IP3R RNAi).

function [hFig, means] = graphSummaryStatsRaw(imageArray, catList, pIN, category)
    medianArray = cellMean(imageArray, 'median');
    
    means = {};
    catListPared = [];
    for j = 1:length(catList)
        if any(category == catList(j))
            means{end+1} = medianArray(category == catList(j));
            catListPared(end+1) = catList(j);
        else
            warning(['Category ' char(catList(j)) ' has no values'])
        end
    end
    
    hFig = figureBarGraph(catListPared, means, pIN);
end

