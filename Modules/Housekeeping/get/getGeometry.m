% This function loads an array of structures corresponding to a cell array
% of N labels. Each structure contains S fields (one per stat), each of
% which is a 2D matrix of doubles representing spatial bins.

function geometries = getGeometry(labels, settings, force)
%% Process data to make spatial maps if they are not yet on hard drive
if force
    thruSegmentManually(labels, settings);
    thruGetGeometry(labels, settings)
end

%% Load spatial maps from hard drive
for i = 1:length(labels)
    if exist([settings.thruGeometry labels{i} '.mat'], 'file')
        load([settings.thruGeometry labels{i} '.mat'], 'geometry');
        if isnumeric(geometry)
            continue;
        end
        geometries(i) = geometry;
    end
end

if isnumeric(geometry) || ~exist([settings.thruGeometry labels{i} '.mat'], 'file')
	geometries(length(labels)).NW = []; 
end
end

