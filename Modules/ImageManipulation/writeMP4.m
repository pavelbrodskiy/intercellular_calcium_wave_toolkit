function writeMP4(I, name)

I = double(I);

minWindow = prctile(I(:), 1);
maxWindow = prctile(I(:), 99.7);

I = double(I - minWindow);
I = I / (maxWindow - minWindow);
I = I * 255;
I = uint8(I);

% v = VideoWriter([name '.avi'],'Motion JPEG AVI');
v = VideoWriter([name '.avi'],'MPEG-4');
v.FrameRate = 100;
open(v)
[xMon, yMon, tMon] = size(I);
rescale = max([xMon, yMon]./[1088, 1920]);
new = round([xMon, yMon] / rescale);

for t = 1:tMon
    compressedFrame = imresize(I(:,:,t),new);
    writeVideo(v, compressedFrame);
end
close(v)


end

