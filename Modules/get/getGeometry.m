% This function loads an array of structures corresponding to a cell array
% of N labels. Each structure contains S fields (one per stat), each of
% which is a 2D matrix of doubles representing spatial bins.

function geometries = getGeometry(labels, settings)
%% Process data to make spatial maps if they are not yet on hard drive
thruSegmentManually(labels, settings);
thruGetGeometry(labels, settings)

%% Load spatial maps from hard drive
for i = 1:length(labels)
    load([settings.thruGeometry labels{i} '.mat']);
    if isnumeric(geometry)
        continue
    end
    geometries(i) = geometry;
end
end

