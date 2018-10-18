

function timeMat = getTime(labels, settings)
%% Process data to make spatial maps if they are not yet on hard drive
thruGetTime(labels, settings);

%% Load spatial maps from hard drive
for i = 1:length(labels)
    if exist([settings.thruTime labels{i} '.mat'])
        load([settings.thruTime labels{i} '.mat']);
        timeMat(i) = time;
    else
        timeMat(i) = NaN;
    end
end
end

