% Takes a cell array of images of different sizes, pads them, and combines
% them into a stack.

function stack = makeStackDiffSizes(cellArray, method)
sizeMax = [0, 0];
for i = 1:length(cellArray)
    sizeTemp = size(cellArray{i});
    sizeMax = max([sizeMax; sizeTemp]);
end

switch method
    case 'center'
        for i = 1:length(cellArray)
            stack(:,:,i) = padToSize(cellArray{i}, sizeMax);
        end
    case 'post'
         for i = 1:length(cellArray)
            stack(:,:,i) = padarray(cellArray{i}, sizeMax-size(cellArray{i}),'post');
         end
    otherwise
        error('Input should be center or post');
end
end

