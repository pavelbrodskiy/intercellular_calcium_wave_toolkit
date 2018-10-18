% Opens each mask indicated by the string array labels, finds the area in
% um^2, and returns it as an array. Assumes that the masks are all 20x.

function [maskSize, aspectRatio] = getPouchSizes(labels, settings)

for i = length(labels):-1:1
    if exist([settings.thruMask labels{i} '.mat'], 'file')
        load([settings.thruMask labels{i} '.mat'], 'rotMask');
    elseif exist([settings.thruMaskUnflipped labels{i} '.mat'], 'file')
        load([settings.thruMaskUnflipped labels{i} '.mat'], 'rotMask');
    else
        maskSize(i) = NaN;
        aspectRatio(i) = NaN;
        continue
    end
    stats = regionprops(rotMask, 'MajorAxis', 'MinorAxis');
    maskSize(i) = sum(sum(rotMask)) * settings.scale.x20^2;
    if maskSize(i)
        aspectRatio(i) = stats(1).MajorAxisLength/stats(1).MinorAxisLength;
    else
        aspectRatio(i) = nan;
    end
end

end

