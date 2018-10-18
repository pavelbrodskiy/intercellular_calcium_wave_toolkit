% This function loads an array of structures corresponding to a cell array
% of N labels. Each structure contains S fields (one per stat), each of
% which is a 2D matrix of doubles representing spatial bins.

function [structMaps, statsArray, coordsArray] = getSpatialMaps(labels, settings)
%% Process data to make spatial maps if they are not yet on hard drive
thruSegmentManually(labels, settings);
thruGetStats(labels, settings);

%% Load spatial maps from hard drive
for i = length(labels):-1:1
    if nargout <= 1
        load([settings.thruStats labels{i} '.mat'],'structMap');
        if isnumeric(structMap)
            continue
        end
        structMaps(i) = structMap;
    else
        load([settings.thruStats labels{i} '.mat']);
        if isnumeric(structMap)
            continue
        end
        structMaps(i) = structMap;
        statsArray(i) = stats;
        coordsArray{i} = coords;
    end
end
end

