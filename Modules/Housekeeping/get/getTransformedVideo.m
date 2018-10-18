% This function loads an array of structures corresponding to a cell array
% of N labels. Each structure contains S fields (one per stat), each of
% which is a 2D matrix of doubles representing spatial bins.

function transformedVideos = getTransformedVideo(labels, settings)
%% Process data to make spatial maps if they are not yet on hard drive
thruGetTransformedVideo(labels, settings);

%% Load spatial maps from hard drive
for i = 1:length(labels)
    load([settings.thruTransformedVideo labels{i} '.mat']);
    transformedVideos{i} = transformedVideo;
end
end

