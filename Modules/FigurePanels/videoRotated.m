function videoRotated(labels, category, settings, catList)
thruSegmentManually(labels, settings);
rescale = 1; % Switch back to 1 on good computer

%% Make montage (open, pad, and place in montage array)
for i = 1:length(catList)
    currentCat = catList(i);
    activeLabels = currentCat == category;
    name = strrep(char(currentCat), '/', '-');
    videoRotatedDiscs(labels(activeLabels), category(activeLabels), rescale, name, settings)
    
    %% Process and save montage
%     v = VideoWriter([settings.output settings.uniqueIdentifier '_montageVideo_' char(superCategory) '.mp4'],'MPEG-4');
%     v.FrameRate = 12;
%     open(v)
%     [xMon, yMon, ~, tMon] = size(activeMontage);
%     rescale = max([xMon, yMon]./[1088, 1920]);
%     new = round([xMon, yMon] / rescale);
%     
%     for t = 1:tMon
%         compressedFrame = imresize(activeMontage(:,:,:,t),new);
%         writeVideo(v, compressedFrame);
%     end
%     close(v)
%     clear 'activeMontage'
end