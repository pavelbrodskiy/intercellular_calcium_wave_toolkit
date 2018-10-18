function showAnnotations(label, settings)
%% Lazy inputs
if iscell(label)
    label = label{1};
end
% Should error out if label is not string

%% Load in mask, axes, and rotated video
load([settings.thruMask label, '.mat']);
load([settings.thruRot label, '.mat']);
load([settings.thruAxes label, '.mat']);

%% Determine positions of axes
maskCoord = mask2poly(rotMask,'Exact')';
maskCoord(:,1) = [];

[~, idx1] = min((maskCoord(1,:)-AP(1,1)).^2+(maskCoord(2,:)-AP(2,1)).^2);
[~, idx2] = min((maskCoord(1,:)-AP(1,end)).^2+(maskCoord(2,:)-AP(2,end)).^2);
AP = [(maskCoord(:,idx1)), AP, (maskCoord(:,idx2))];

[~, idx1] = min((maskCoord(1,:)-DV(1,1)).^2+(maskCoord(2,:)-DV(2,1)).^2);
[~, idx2] = min((maskCoord(1,:)-DV(1,end)).^2+(maskCoord(2,:)-DV(2,end)).^2);
DV = [(maskCoord(:,idx1)), DV, (maskCoord(:,idx2))];

%% Make z projection
croppedVideo = rescale2RGB(max(croppedVideo, [], 3));
croppedVideo(end:end+12, :, :) = max(croppedVideo(:));

%% Plot annotations
imshow(croppedVideo);
hold on
plot(maskCoord(1,:),maskCoord(2,:),'-r','LineWidth',1.5)
plot(AP(1,:),AP(2,:),'-b','LineWidth',1.5)
plot(DV(1,:),DV(2,:),'-g','LineWidth',1.5)
plot(AP(1,2:end-1),AP(2,2:end-1),'ob','LineWidth',1.5)
plot(DV(1,2:end-1),DV(2,2:end-1),'og','LineWidth',1.5)

%% Add label
text(round(size(croppedVideo,2)/2),size(croppedVideo,1)-6,label,'HorizontalAlignment','center')


end