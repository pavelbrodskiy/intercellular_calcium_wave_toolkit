% Determines how much to rotate video from mask so that long axis is
% horizontal. Rotation must be less than 90 degrees.

function [rotVideo, rotMask] = refineRotation(video, mask)
orientation = regionprops(mask,'Orientation');
orientation = -orientation.Orientation;
if orientation > 90
    orientation = orientation - 90;
elseif orientation < -90
    orientation = orientation + 90;
end
rotMask1 = imrotate(mask, orientation);
for t = size(video,3):-1:1
    rotVideo1(:,:,t) = imrotate(video(:,:,t), orientation);
end
stats = regionprops(rotMask1,'BoundingBox');
videoCrop = stats.BoundingBox + [-5, -5, 10, 10];
rotMask = imcrop(rotMask1, videoCrop);
for t = size(video,3):-1:1
    rotVideo(:,:,t) = imcrop(rotVideo1(:,:,t), videoCrop);
end
end

