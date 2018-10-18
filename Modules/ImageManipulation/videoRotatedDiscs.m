% This function makes a montage of rotated videos for the list of labels

function videoRotatedDiscs(labels, category, rescale, videoName, settings)
for k = length(labels):-1:1
    pathArray{k} = [settings.thruRot labels{k} '.mat'];
end

montage = montageAll(labels, pathArray, 'catagories', category, 'rescale', rescale, 'normEachDisc', true);

v = VideoWriter([settings.outRough settings.uniqueIdentifier '_montageVideo_' videoName '.mp4'],'MPEG-4');
v.FrameRate = 12;
open(v)
[xMon, yMon, ~, tMon] = size(montage);
rescale = max([xMon, yMon]./[1088, 1920]);
new = round([xMon, yMon] / rescale);

for t = 1:tMon
    compressedFrame = imresize(montage(:,:,:,t),new);
    writeVideo(v, compressedFrame);
end

close(v)
end