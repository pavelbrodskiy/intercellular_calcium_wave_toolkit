% This function reads in a tiff stack or hyperstack
%
% [video, video4D] = readTiff(filename)
%
% The function returns a max-projected video and the 4-D hyperstack

function [video, video4D] = readTiff(filename)
try % Try bioformats first, to handle hyperstacks (4D)
    volume = bfOpen3DVolume(filename);
    hashtable = char(volume{2});
    indZplanes = strfind(hashtable,'number-of-planes=');
    if isempty(indZplanes)
        indZplanes = 1;
        zPlanes = 1;
    else
        for i = 1:length(indZplanes)
            zPlanes(i) = str2num(hashtable(indZplanes(i) + 17));
        end
    end
    if max(zPlanes) ~= min(zPlanes)
        error('Z plane number not consistant')
    else
        video = volume{1};
        video = video{1};
        [x, y, z] = size(video);
        video4D = reshape(video, [x y zPlanes(1) z/zPlanes(1)]);
        video4D = uint16(permute(video4D, [1, 2, 4, 3]));
        video = max(video4D, [], 4);
    end
catch % Otherwise use MATLAB built-in function and assume number of 
      % dimensions is 2 or 3
    warning('Bioformats failed to read tiff stack. Using imread.')
    info = imfinfo(filename);
    num_images = numel(info);
    for k = num_images:-1:1
        video(:,:,k) = imread(filename, k);
    end
    video4D = video;
end