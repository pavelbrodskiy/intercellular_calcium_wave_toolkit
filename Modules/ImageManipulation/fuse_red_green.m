% RGB = fuse_red_green(red_video, green_video)
% red_video and green_video are x by y by t matricies
%
% Generates an RGB video from red and green video normalized to min and max
% of each channel.

function RGB = fuse_red_green(red_video, green_video)
red_normalized = mat2gray(red_video);
green_normalized = mat2gray(green_video);

red_normalized = uint8(red_normalized * 255);
green_normalized = uint8(green_normalized * 255);

red_normalized = permute(red_normalized, [1,2,4,3]);
green_normalized = permute(green_normalized, [1,2,4,3]);

RGB = cat(3, red_normalized, green_normalized, green_normalized * 0);











