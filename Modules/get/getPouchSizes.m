% Opens each mask indicated by the string array labels, finds the area in
% um^2, and returns it as an array. Assumes that the masks are all 20x.

function [maskSize, aspectRatio] = getPouchSizes(labels, settings)

for i = length(labels):-1:1
    load([settings.thruMask labels{i} '.mat'], 'rotMask');
    stats = regionprops(rotMask, 'MajorAxis', 'MinorAxis');
    maskSize(i) = sum(sum(rotMask)) * settings.scale.x20^2;
    if maskSize
        aspectRatio(i) = stats.MajorAxisLength/stats.MinorAxisLength;
    else
        aspectRatio(i) = nan;
    end
end

end

