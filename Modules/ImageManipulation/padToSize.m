% This function pads an image or video to a final size by adding an equal
% number of zeros to each side.

function paddedI = padToSize(I, finalSize, nanPad, maxPad)

    if nargin < 3
        nanPad = true;
    end

    if nargin < 4
        maxPad = false;
    end

    if nanPad || maxPad
        initialZeros = I == 0;
    end
    
    [m, n, t] = size(I);
    left = (finalSize(1)-m) / 2;
    right = (left - round(left)) * 2 + left;
    left = round(left);
    
    up = (finalSize(2)-n) / 2;
    down = (up - round(up)) * 2 + round(up);
    up = round(up);
    
    pad1 = round([left, up, 0]);
    pad2 = round([right, down, 0]+1e-5);
    
    paddedI = padarray(I,pad1,'pre');
    paddedI = padarray(paddedI,pad2,'post');
    
    if nanPad
        paddedZeros = padarray(initialZeros,pad1,'pre');
        paddedZeros = padarray(paddedZeros,pad2,'post');
        paddedI(paddedI == 0) = NaN;
        paddedI(paddedZeros) = 0;
    end
    
    if maxPad
        paddedZeros = padarray(initialZeros,pad1,'pre');
        paddedZeros = padarray(paddedZeros,pad2,'post');
        paddedI(paddedI == 0) = max(paddedI(:));
        paddedI(paddedZeros) = 0;
    end
    
%     if sum([size(paddedI,1) size(paddedI,2)] ~= finalSize)
%         error('Final padded size does not match input')
%     end
end

