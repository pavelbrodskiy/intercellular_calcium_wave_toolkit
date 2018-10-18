

function [APmat, DVmat] = getAxes(labels, settings)
%% Process data to make spatial maps if they are not yet on hard drive
thruGetAxes(labels, settings);

%% Load spatial maps from hard drive
for i = 1:length(labels)
    load([settings.thruAxes labels{i} '.mat'], 'AP', 'DV');
    APmat{i} = AP;
    DVmat{i} = DV;
end
end

