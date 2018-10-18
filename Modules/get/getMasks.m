function mask = getMasks(labels, settings)
%% Process data to make spatial maps if they are not yet on hard drive
getAllMasks(settings);
thruRotateManually(labels, settings);

%% Load from hard drive
for i = 1:length(labels)
    load([settings.thruMask labels{i} '.mat'], 'rotMask');
    mask{i} = rotMask;
end
end

