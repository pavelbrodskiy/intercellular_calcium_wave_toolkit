% Determine which side is A, P, D, and V, then rotate and flip into
% canonical orientation. A is left, P is right, V is top, D is bottom.

function [croppedVideo, rotMask] = determineAP(croppedVideo, rotMask)
top = rotMask(1:30,:);
bottom = rotMask((end-29):end,:);
right = rotMask(:,(end-29):end);
left = rotMask(:,1:30);

if sum(bottom(:)) > sum(top(:))
    rotMask = flipud(rotMask);
    croppedVideo = flipud(croppedVideo);
end
if sum(left(:)) > sum(right(:))
    rotMask = fliplr(rotMask);
    croppedVideo = fliplr(croppedVideo);
end
end

