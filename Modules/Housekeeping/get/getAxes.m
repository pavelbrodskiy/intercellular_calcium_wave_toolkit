

function [APmat, DVmat] = getAxes(labels, settings, force)
%% Process data to make spatial maps if they are not yet on hard drive\
if force
    thruGetAxes(labels, settings);
end

%% Load spatial maps from hard drive
for i = 1:length(labels)
    if exist([settings.thruAxes labels{i} '.mat'], 'file')
        load([settings.thruAxes labels{i} '.mat'], 'AP', 'DV');
    else
        AP = NaN;
        DV = NaN;
    end
    APmat{i} = AP;
    DVmat{i} = DV;
end
end

