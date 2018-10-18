% Take the outline of a mask, and stamp it onto every frame of a video in
% white.

function video = stampMask(video, mask, skip)
if nargin < 3
    skip = [];
end
[a,b] = gradient(mask);
c = a+b;
c = imdilate(c, strel('disk',1)) > 0;
d = repmat(c, [1,1,size(video, 3)]);
d(:,:,skip) = 0;
video(d) = max(video(:));
end

