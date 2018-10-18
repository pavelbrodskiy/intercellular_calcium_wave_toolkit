

function [PSDs, freqs] = getPSD(labels, settings)
%% Process data to make spatial maps if they are not yet on hard drive
thruGetPSD(labels, settings);

%% Load spatial maps from hard drive
for i = 1:length(labels)
    disp(['Loading PSDs: ' labels{i}])
    load([settings.thruPSD labels{i} '.mat'],'PSD','freq');
    PSDs{i} = PSD;
    freqs{i} = freq;
end
end

