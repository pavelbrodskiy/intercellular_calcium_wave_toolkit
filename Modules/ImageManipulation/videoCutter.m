function [videoBins, binCoords, binCoordsActual] = videoCutter(video, settings)

[xDim, yDim, ~] = size(video);

maxProj = max(video,[],3);
regionShape = squeeze(maxProj > 0);

binNumber = 1;
x = 1;
binDimension = settings.analysis.binSize;
for i = 1:binDimension:(xDim-binDimension)
    y = 1;
    for j = 1:binDimension:(yDim-binDimension)
        %         if min(min(regionShape(i:(i+binDimension-1),(j:(j+binDimension-1)))))
        if ~any(isnan(video(i:(i+binDimension-1),(j:(j+binDimension-1)),1)))
            % Video bin compression would go here if I wanted to compress
            % the videos
            videoBins{binNumber} = video(i:(i+binDimension-1),(j:(j+binDimension-1)),:);
            binCoords(binNumber, 1) = x;
            binCoords(binNumber, 2) = y;
            binCoordsActual(binNumber, 1) = mean([i,(i+binDimension-1)]);
            binCoordsActual(binNumber, 2) = mean([j,(j+binDimension-1)]);
            binNumber = binNumber + 1;
            %         end
        end
        y = y + 1;
    end
    x = x + 1;
end

if binNumber == 2
    videoBins{1} = video;
    binCoords(binNumber, 1:2) = 1;
end
if binNumber == 1
    videoBins = nan;
    binCoords = nan;
    binCoordsActual = nan;
end
end