% Input a cell array, find max dimensions and pad each element to size,
% then return a cell array.

function padded = padStack(unpadded, nanPad, finalSize)

if nargin < 2
    nanPad = true;
end

if nargin < 3
    xsize = [];
    ysize = [];
    
    for i = 1:length(unpadded)
        xsize(end+1) = size(unpadded{i}, 1);
        ysize(end+1) = size(unpadded{i}, 2);
    end
    
    finalSize = [max(xsize), max(ysize)];
end

for i = 1:length(unpadded)
    padded{i} = padToSize(unpadded{i}, finalSize, nanPad);
end

end

