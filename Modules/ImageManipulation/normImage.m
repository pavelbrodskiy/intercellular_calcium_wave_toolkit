% normalizes image to percentiles, and returns 8-bit image

function normI = normImage(I, pct)
    I = double(I);
    minmax = prctile(I(:), pct);
    I = I - minmax(1);
    I = I / (minmax(2)-minmax(1));
    I = I * 255;
    normI = uint8(I);
end

