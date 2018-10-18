% Input image, intensity scale, and size scale
% image: raw image to resize, must be 2D or 3D video. If the video is 3D,
% the highest intensity slice is selected.
% scale: 1x2 array with minimum and maximum intensity. Empty set means
% autoscaling
% resize: 1x2 array with final dimensions, or scalar representing how to
% resize the image. 1 means no resizing.
% resizeType: string. 'nearest' is better for upscaling, 'quadratic' 
% is better for downscaling.

function RGB = rescale2RGB(varargin)
%% Parse inputs
p = inputParser;
addRequired(p,'image', @(arg) ~isempty(arg)&&isnumeric(arg)||islogical(arg));
addParameter(p,'scale', [], @isnumeric)
addParameter(p,'resize', 1, @isnumeric)
addParameter(p,'map', gray(256), @isnumeric)
addParameter(p,'resizeType', '', @ischar)
addParameter(p,'greyscaleOnly', true, @islogic)

parse(p,varargin{:});

image = p.Results.image;
scale = p.Results.scale;
resize = p.Results.resize;
resizeType = p.Results.resizeType;
map = p.Results.map;
greyscaleOnly = p.Results.greyscaleOnly;

if length(size(image)) == 3
   RGB = image;
   return
end

%% Process inputs
if length(size(image)) == 3
    spaceProj = squeeze(sum(sum(image,1), 2));
    [~, strongestTime] = max(spaceProj);
    image = image(:,:,strongestTime);
end

if isempty(scale)
    Minimum = min(image(:));
    Maximum = max(image(:));
else
    Minimum = scale(1);
    Maximum = scale(2);
end

%% Resize image build later
image = double(image);
if isempty(resizeType)
    resizeType = 'nearest'; % Replace with method selecting nearest for upscaling and quadratic for downscaling
end
image = imresize(image, resize, resizeType);

% if resize ~= 1
%     if length(resize) == 1
%         image = imresize(image, resize, resizeType);
%     else
%         
%     end
% else
%     
% end

%% Rescale image

image = double(image);
image = image - double(Minimum);
image = image / double(Maximum);
image = image * 255;

%% Apply color
nanInd = repmat(isnan(image),[1,1,3]);
RGB = uint8(ind2rgb(uint8(image), uint8(map*255)));
RGB(nanInd) = 255;  

end

