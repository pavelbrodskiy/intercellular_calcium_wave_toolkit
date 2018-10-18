% This function takes an array of .mat or .tif paths to read images or
% videos from, or a cell array of images or videos, and generates a montage
% with metadata stamped on including the lable of the videos. Montage is
% MxN where N = 2M and is the smallest value that can display all videos.
% Videos are output one column at a time, top to bottom, in order of the
% array. Inputs must be same size.
%
% montage = montageAll(labels, pathArray) THIS IS NOT YET IMPLEMENTED
% montage = montageAll(labels, vidArray)
% montage = montageAll(..., colormap)
%
% Could add 1. padding of videos 2. global vs local rescaling 3) add
% timestamp 4. option to supress output 5. rescaling manually or by
% percentile 6. resizing images so that the final matrix is not massive
%
% montage is MxNx3xT where M and N are the dimensions of the final montage,
% and T is the length of the longest video in the montage if it is a video.

function montage = montageAll(varargin)
%% Parse inputs
p = inputParser;
addRequired(p,'labels', @iscellstr);
addRequired(p,'inArray');
addParameter(p,'binSize', 1, @isinteger)
addOptional(p,'catagories', categorical([]), @iscategorical)
addParameter(p,'map', gray(256), @isnumeric)
addParameter(p,'rescale', 1, @isnumeric)
addParameter(p,'sortByLabel', false, @islogical)
addParameter(p,'normEachDisc', false, @islogical)
addParameter(p,'intensityScale', [], @isnumeric)
addParameter(p,'settings', getSettings(), @isstructure)
addParameter(p,'maxStackLength', 361, @isinteger)
addParameter(p,'FontSize', 20, @isinteger)
addParameter(p,'prctRange', [1, 99], @isnumeric)

parse(p,varargin{:});

labels = p.Results.labels;
inArray = p.Results.inArray;
binSize = p.Results.binSize;
categories = p.Results.catagories;
map = p.Results.map;
rescale = p.Results.rescale;
sortByLabel = p.Results.sortByLabel;
normEachDisc = p.Results.normEachDisc;
intensityScale = p.Results.intensityScale;
settings = p.Results.settings;
maxStackLength = p.Results.maxStackLength;
FontSize = p.Results.FontSize;
prctRange = p.Results.prctRange;

%% Error handling
if length(labels) ~= length(inArray)
    error('labels should be same length as vidArray');
end

if (length(categories) ~= length(inArray)) && ~isempty(categories)
    error('categories should be same length as vidArray');
end

thruSegmentManually(labels, settings);

%%
if iscellstr(inArray)
    imagesLoaded = false;
else
    vidArray = inArray;
    imagesLoaded = true;
end

if ~isempty(intensityScale)
    minValue = intensityScale(1);
    maxValue = intensityScale(2);
end

if imagesLoaded
    sizeMax = [0, 0];
    for i = 1:length(vidArray)
        temp = (vidArray{i});
        sizeMax = max([sizeMax; size(squeeze(temp(:,:,1)))]);
    end
    vidFirst = vidArray{1};
    [m, n, t] = size(vidFirst);
    vals = vidFirst(:);
    vals(isnan(vals)) = [];
    if isempty(intensityScale)
        minValue = prctile(vals(:),prctRange(1));
        maxValue = prctile(vals(:),prctRange(2));
    end
else
    for i = 1:length(inArray)
        [~,name,~] = fileparts(inArray{i});
        load([settings.thruMask name '.mat'], 'rotMask');
        maskArray{i} = rotMask;
    end
    sizeMax = [0, 0];
    for i = 1:length(inArray)
        sizeMax = max([sizeMax; size(maskArray{i})]);
    end
    if isempty(intensityScale)
        minValue = 200;
        maxValue = 2000;
    end
end

dimTemp = round(sqrt((length(labels))/2) + 0.5);
dims = round([dimTemp dimTemp*2]);

if sortByLabel && ~imagesLoaded
    tempSort = [cellstr(categories)',labels];
    tempSort = sortrows(tempSort);
    labels = cellstr(tempSort(:,2));
    categories = categorical(tempSort(:,1));
end

if ispc
    userview = memory;
    neededBytes = round(dims(1)*sizeMax(1)/rescale)*round(dims(2)*sizeMax(2)/rescale)*3*maxStackLength;
    if userview.MaxPossibleArrayBytes < neededBytes
        unscaledBytes = round(dims(1)*sizeMax(1))*round(dims(2)*sizeMax(2))*3*maxStackLength;
        recommendation = sqrt(unscaledBytes / userview.MaxPossibleArrayBytes);
        error(['not enough memory, rescale should be over: ' num2str(recommendation)])
    end
end

%% Make montage (open, pad, and place in montage array)
montage = zeros(round(dims(1)*sizeMax(1)/rescale), round(dims(2)*sizeMax(2)/rescale), 3, maxStackLength, 'uint8');

% Add videos to the montage one at a time
column = 0;
row = 0;
for k = 1:length(labels)
    if column >= dims(1)
        column = 0;
        row = row + 1;
    end
    
    disp(['Montaging: ' labels{k} ', row x column: ' num2str([row column])]);
    
    if ~imagesLoaded
        if sum(strfind(inArray{1},'.mat'))
            disp(['loading: ' inArray{k}]);
            if exist(inArray{k},'file')
                load(inArray{k}, 'croppedVideo');
                curVideo = double(croppedVideo);
                clear 'croppedVideo'
            else
                continue
            end
        else
            disp(['loading: ' inArray{k}]);
            curVideo = double(readTiff(inArray{k}));
        end
    else
        curVideo = double(vidArray{k});
    end
    
    % Convert video into RGB
    curVideo = padToSize(curVideo, sizeMax);
    clear temp
    for slice = size(curVideo,3):-1:1
        temp(:,:,slice) = imresize(curVideo(:,:,slice),1/rescale);
    end
    curVideo = temp;
    if ~normEachDisc
    elseif islogical(curVideo)
        minValue = 0;
        maxValue = 1;
    else
        minValue = prctile(curVideo(:),prctRange(1));
        maxValue = prctile(curVideo(:),prctRange(2));
    end
    curVideo = double(curVideo);
    curVideo(curVideo == 0) = NaN;
    curVideo = curVideo - minValue;
    curVideo = (curVideo - minValue) / (maxValue - minValue);
    curVideo2 = uint8(curVideo * 255);
    [~, ~, t2] = size(curVideo2);
    for slice = t2:-1:1
        temp = ind2rgb(curVideo2(:,:,slice),map);
        tempNaN = isnan(curVideo(:,:,1));
        temp(repmat(tempNaN(:),[1,3])) = 0;
        temp = imresize(temp,binSize,'nearest');
        curVideoRGB(:,:,:,slice) = temp;
    end

    [m, n, ~] = size(curVideoRGB);
    
    % Add text label
    for slice = 1:t2
        curVideoRGB(:,:,:,slice) = insertText(curVideoRGB(:,:,:,slice),[round(m/2), 1],labels{k},'AnchorPoint','CenterTop','BoxOpacity',0,'TextColor','red','FontSize',FontSize);
    end
    
    % Add second text label
    if ~isempty(categories)
        for slice = 1:t2
            curVideoRGB(:,:,:,slice) = insertText(curVideoRGB(:,:,:,slice),[round(m/2), 37],char(categories(k)),'AnchorPoint','CenterTop','BoxOpacity',0,'TextColor','yellow','FontSize',FontSize);
        end
    end
    
    curVideoRGB = curVideoRGB * 255;
    
    % Place in montage
    xPos = column*(m+1)+2;
    yPos = row*(n+1)+2;
    
    montage(xPos:(xPos+m-1),yPos:(yPos+n-1), :, 1:size(curVideoRGB, 4)) = curVideoRGB;
    for tTemp = (size(curVideoRGB, 4)+1):maxStackLength
        montage(xPos:(xPos+m-1),yPos:(yPos+n-1), :, tTemp) = curVideoRGB(:,:,:,1);
    end
    montage(xPos-1,:,:) = 255;
    montage(:,yPos-1,:) = 255;
    montage(xPos+m,:,:) = 255;
    montage(:,yPos+n,:) = 255;
    
    clear 'video' 'croppedVideo' 'curVideoRGB' 'curVideo'
    
    column = column + 1;
end

montage(end+1,:,:) = 255;
montage(:,end+1,:) = 255;

end