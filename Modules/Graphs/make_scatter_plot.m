function make_scatter_plot(dataTable, field, cats, field2, sizeRange, catLegend, field3, legendpos)
graphtype = 3;
if nargin < 4
    field2 = 'pouchSizes';
end
if nargin < 7
    field3 = [];
end
if nargin < 6
    catLegend = cats;
end
if nargin < 5 || isempty(sizeRange)
    sizeRange = [-inf, inf];
end
if nargin < 8
    legendpos = 'eastoutside';
end
dataTable(dataTable.pouchSizes < sizeRange(1) | dataTable.pouchSizes > sizeRange(2),:) = [];
colors = {'k','b','r','g','m','y'};
symbols = {'o','d','s','p','^','v','.'};
legendArray = {};
for i = 1:length(cats)
    catTmp = cats{i};
    for j = 1:length(catTmp)
    idx = dataTable.category == categorical(catTmp(j));
    if isempty(field3)
        scatter(dataTable(idx,:).(field2), dataTable(idx,:).(field),[symbols{j} colors{i}])
    else
        if graphtype == 1
            range = [min(dataTable(idx,:).(field3)), max(dataTable(idx,:).(field3))];
            scatter(dataTable(idx,:).(field2), dataTable(idx,:).(field), (0.1+(dataTable(idx,:).(field3)-range(1))/(range(2)-range(1)))*150,[symbols{j} colors{i}])
        elseif graphtype == 2
            stem3(dataTable(idx,:).(field2), dataTable(idx,:).(field), dataTable(idx,:).(field3),[symbols{j} colors{i}])
        else
            scatter3(dataTable(idx,:).(field2), dataTable(idx,:).(field), dataTable(idx,:).(field3),[symbols{j} colors{i}])
            
        end
    end
    hold on
    if nargin >= 6
        legendArray{end+1} = catLegend{i}{j};
        
    end
    end
end
if nargin >= 6 && ~strcmp(legendpos, 'none')
    legend(legendArray,'Location',legendpos); 
end
end
