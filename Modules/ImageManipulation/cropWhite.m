% Crops out white space or nan padding around an image.

function cropped = cropWhite(image)
image2D = nanmin(image, [], 3);
edges = isnan(image2D)|(image2D==255);
edges = ~edges;
cropped = image(max(edges, [], 2), max(edges, [], 1), :);
end

