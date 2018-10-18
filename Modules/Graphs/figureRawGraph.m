% String cell array of category labels, and cell array of values. Input
% parser needs to be implemented.

function hBarGraph = figureRawGraph(catagories, values)
%% Inputs (lazy)
ttest = true;
n = false;

%% Initialization
dataTable = Table(values, catagories);



%% Get bar heights, error bars, and astriscs
for i = 1:length(values)
    tempValues = (values{i} - normSubtract) / normDivide;
    nonNumbers = isnan(tempValues)|isinf(tempValues);
    if any(nonNumbers)
        warning('NaN or inf detected and removed');
        tempValues(nonNumbers) = [];
    end
    values{i} = tempValues;
    meanVal(i) = mean(tempValues);
    stdVal(i) = std(tempValues);
    n(i) = length(tempValues);
end

%% Perform signifigance testing
if tTest
    for i = find(~cellfun(@isempty,values))
        [~, p] = ttest2(rawDataControl,values{i});
        p = p * (length(meanVal) - 1);
        if p < signifiganceCutoffs(3)
            astriscs{i} = '***';
        elseif  p < signifiganceCutoffs(2)
            astriscs{i} = '**';
        elseif  p < signifiganceCutoffs(1)
            astriscs{i} = '*';
        else
            astriscs{i} = '';
        end
    end
end

%% Plot supercategories
currentPosition = 1;
superCatList = unique(supercategories);
hBarGraph = figure;
hold on

tickLabels = {};

for j = superCatList
    idxCat = supercategories == j;
    
    tmpMeans = meanVal(idxCat);
    tmpStds = stdVal(idxCat);
    tmpLabels = labels(idxCat);
    
    if tTest
        tmpAsrr = astriscs(idxCat);
    end
    
    if reSort
        [~, idx] = sort(tmpMeans);
    else
        idx = 1:length(tmpMeans);
    end
    
    sortedMeans = tmpMeans(idx);
    sortedStds = tmpStds(idx);
    tickLabels = [tickLabels tmpLabels(idx)'];
    if tTest
        sortedAsrr = tmpAsrr(idx);
    end
    
    xs = currentPosition:(length(sortedMeans) + currentPosition - 1);
    errorbar(xs, sortedMeans, sortedStds,'black.', 'LineWidth', 1);
    bar(xs, sortedMeans, colorList{j})
    
    if tTest % Mean value, plus error bar, plus 1% of range
        astriscPositions = sortedMeans + sortedStds + 0.01 * (max(meanVal));
%         astriscPositions = sortedMeans + (2*(sortedMeans>0)-1) .* (sortedStds + 0.01 * (max(meanVal)));
        text(xs, astriscPositions, sortedAsrr, 'HorizontalAlignment', 'center','FontSize',fontSize)
    end
    if listN
%         NPositions = sortedMeans + (2*(sortedMeans>0)-1) .* (sortedStds + 0.08 * (max(meanVal)));
        NPositions = sortedMeans + sortedStds + 0.09 * (max(meanVal));
        text(xs, NPositions, strread(num2str(n),'%s'), 'HorizontalAlignment', 'center','FontSize',fontSize)
    end
    currentPosition = length(sortedMeans) + currentPosition;
end

set( gca, ...
    'FontName'          , 'Arial'               , ...
    'Box'               , 'on'                  , ...
    'TickDir'           , 'in'                  , ...
    'TickLength'        , [0 0]                 , ...
    'ygrid'             , 'on'                  , ...
    'xcolor'            , 'k'                   , ...
    'ycolor'            , 'k'                   , ...
    'LineWidth'         , 1                     , ...
    'XTickLabel'        , tickLabels            , ...
    'XTick'             , 1:length(tickLabels)  , ...
    'XTickLabelRotation', textAngle             , ...
    'FontSize'          , fontSize                    );

axis([0, length(supercategories)+1, min([0, (meanVal+(2*(meanVal>0)-1) .*stdVal)*1.1]), max((meanVal+stdVal)*1.1)]);


end
